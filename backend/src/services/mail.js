const dns = require('dns');
const nodemailer = require('nodemailer');
const Company = require('../models/Company');

// Prefer IPv4 when SMTP is used. Render free instances often cannot
// reach Gmail over IPv6 (ENETUNREACH 2607:f8b0:...:587).
if (typeof dns.setDefaultResultOrder === 'function') {
  dns.setDefaultResultOrder('ipv4first');
}

const SMTP_CONNECT_TIMEOUT_MS = Number(process.env.SMTP_CONNECT_TIMEOUT_MS || 12000);
const SMTP_SOCKET_TIMEOUT_MS = Number(process.env.SMTP_SOCKET_TIMEOUT_MS || 15000);
const SMTP_TOTAL_TIMEOUT_MS = Number(process.env.SMTP_TOTAL_TIMEOUT_MS || 20000);

function isResendConfigured() {
  return Boolean(process.env.RESEND_API_KEY);
}

function isSmtpConfigured() {
  return Boolean(process.env.SMTP_USER && process.env.SMTP_PASS);
}

function isMailConfigured() {
  return isResendConfigured() || isSmtpConfigured();
}

function withTimeout(promise, ms, label) {
  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => {
      const error = new Error(`${label} timed out after ${ms}ms`);
      error.code = 'SMTP_TIMEOUT';
      reject(error);
    }, ms);
  });

  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
}

function escapeHtml(value = '') {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

async function resolveInbox() {
  if (process.env.MAIL_TO) return process.env.MAIL_TO;

  const company = await Company.findOne().select('email name').lean();
  return company?.email || process.env.SMTP_USER;
}

function buildBodies(inquiry) {
  const subjectLine =
    inquiry.subject?.trim() ||
    `New ${inquiry.inquiryType || 'general'} inquiry from ${inquiry.name}`;

  const textBody = [
    'New website contact inquiry',
    '',
    `Name: ${inquiry.name}`,
    `Email: ${inquiry.email}`,
    `Phone: ${inquiry.phone || '-'}`,
    `Company: ${inquiry.companyName || '-'}`,
    `Inquiry type: ${inquiry.inquiryType || 'general'}`,
    `Subject: ${inquiry.subject || '-'}`,
    `Source: ${inquiry.source || 'website'}`,
    '',
    'Message:',
    inquiry.message,
  ].join('\n');

  const htmlBody = `
    <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #111;">
      <h2 style="margin-bottom: 8px;">New website contact inquiry</h2>
      <p><strong>Name:</strong> ${escapeHtml(inquiry.name)}</p>
      <p><strong>Email:</strong> ${escapeHtml(inquiry.email)}</p>
      <p><strong>Phone:</strong> ${escapeHtml(inquiry.phone || '-')}</p>
      <p><strong>Company:</strong> ${escapeHtml(inquiry.companyName || '-')}</p>
      <p><strong>Inquiry type:</strong> ${escapeHtml(inquiry.inquiryType || 'general')}</p>
      <p><strong>Subject:</strong> ${escapeHtml(inquiry.subject || '-')}</p>
      <hr style="border: none; border-top: 1px solid #ddd; margin: 16px 0;" />
      <p style="white-space: pre-wrap;">${escapeHtml(inquiry.message)}</p>
    </div>
  `;

  const autoReplyText = [
    `Hi ${inquiry.name},`,
    '',
    'Thanks for contacting SRJ Tech. We received your message and will get back to you soon.',
    '',
    '— SRJ Tech Team',
    'srjtechsupport@gmail.com',
  ].join('\n');

  const autoReplyHtml = `
    <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #111;">
      <p>Hi ${escapeHtml(inquiry.name)},</p>
      <p>Thanks for contacting <strong>SRJ Tech</strong>. We received your message and will get back to you soon.</p>
      <p>— SRJ Tech Team<br/>srjtechsupport@gmail.com</p>
    </div>
  `;

  return { subjectLine, textBody, htmlBody, autoReplyText, autoReplyHtml };
}

/**
 * HTTPS email provider — works on Render free (SMTP ports often time out).
 * https://resend.com
 */
async function sendViaResend(inquiry) {
  const inbox = await resolveInbox();
  // Resend rejects unverified domains (e.g. @gmail.com). Until a custom
  // domain is verified, always send from their onboarding address.
  const configuredFrom =
    process.env.RESEND_FROM ||
    process.env.MAIL_FROM ||
    'SRJ Tech Website <onboarding@resend.dev>';
  const from = /@gmail\.com>?$/i.test(configuredFrom)
    ? 'SRJ Tech Website <onboarding@resend.dev>'
    : configuredFrom;
  const { subjectLine, textBody, htmlBody, autoReplyText, autoReplyHtml } =
    buildBodies(inquiry);

  const sendOne = async (payload) => {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const body = await response.json().catch(() => ({}));
    if (!response.ok) {
      const error = new Error(
        body.message || body.name || `Resend HTTP ${response.status}`
      );
      error.code = 'RESEND_ERROR';
      error.status = response.status;
      throw error;
    }
    return body;
  };

  const companyMail = await withTimeout(
    sendOne({
      from,
      to: [inbox],
      reply_to: inquiry.email,
      subject: `[SRJ Tech] ${subjectLine}`,
      text: textBody,
      html: htmlBody,
    }),
    SMTP_TOTAL_TIMEOUT_MS,
    'Resend send'
  );

  let autoReplyId = null;
  if (process.env.MAIL_AUTO_REPLY !== 'false') {
    try {
      const autoReply = await withTimeout(
        sendOne({
          from,
          to: [inquiry.email],
          subject: 'We received your message — SRJ Tech',
          text: autoReplyText,
          html: autoReplyHtml,
        }),
        SMTP_TOTAL_TIMEOUT_MS,
        'Resend auto-reply'
      );
      autoReplyId = autoReply.id || null;
    } catch (autoReplyError) {
      // Inbox notification matters more than visitor auto-reply.
      console.warn('Resend auto-reply skipped:', autoReplyError.message);
    }
  }

  return {
    provider: 'resend',
    to: inbox,
    messageId: companyMail.id || '',
    autoReplyId,
  };
}

async function createSmtpTransport() {
  const hostname = process.env.SMTP_HOST || 'smtp.gmail.com';
  const port = Number(process.env.SMTP_PORT || 587);
  const secure =
    process.env.SMTP_SECURE !== undefined
      ? process.env.SMTP_SECURE === 'true'
      : port === 465;

  // Resolve to a literal IPv4 address so nodemailer cannot fall back to IPv6.
  const { address } = await dns.promises.lookup(hostname, { family: 4 });

  return nodemailer.createTransport({
    host: address,
    port,
    secure,
    auth: {
      user: process.env.SMTP_USER,
      pass: String(process.env.SMTP_PASS || '').replace(/\s+/g, ''),
    },
    connectionTimeout: SMTP_CONNECT_TIMEOUT_MS,
    greetingTimeout: SMTP_CONNECT_TIMEOUT_MS,
    socketTimeout: SMTP_SOCKET_TIMEOUT_MS,
    tls: {
      minVersion: 'TLSv1.2',
      servername: hostname,
    },
  });
}

async function sendViaSmtp(inquiry) {
  const transporter = await createSmtpTransport();
  const inbox = await resolveInbox();
  const from =
    process.env.MAIL_FROM ||
    `"SRJ Tech Website" <${process.env.SMTP_USER}>`;
  const { subjectLine, textBody, htmlBody, autoReplyText, autoReplyHtml } =
    buildBodies(inquiry);

  try {
    return await withTimeout(
      (async () => {
        await transporter.verify();

        const companyMail = await transporter.sendMail({
          from,
          to: inbox,
          replyTo: inquiry.email,
          subject: `[SRJ Tech] ${subjectLine}`,
          text: textBody,
          html: htmlBody,
        });

        let autoReplyId = null;
        if (process.env.MAIL_AUTO_REPLY !== 'false') {
          const autoReply = await transporter.sendMail({
            from,
            to: inquiry.email,
            subject: 'We received your message — SRJ Tech',
            text: autoReplyText,
            html: autoReplyHtml,
          });
          autoReplyId = autoReply.messageId;
        }

        return {
          provider: 'smtp',
          to: inbox,
          messageId: companyMail.messageId,
          autoReplyId,
        };
      })(),
      SMTP_TOTAL_TIMEOUT_MS,
      'SMTP send'
    );
  } finally {
    transporter.close();
  }
}

/**
 * Sends website inquiry to company inbox and optional auto-reply to visitor.
 * Prefers Resend (HTTPS) on Render; falls back to SMTP for local/dev.
 */
async function sendContactInquiryEmail(inquiry) {
  if (!isMailConfigured()) {
    const error = new Error(
      'Email is not configured. Set RESEND_API_KEY (recommended on Render) or SMTP_USER/SMTP_PASS.'
    );
    error.code = 'SMTP_NOT_CONFIGURED';
    throw error;
  }

  if (isResendConfigured()) {
    return sendViaResend(inquiry);
  }

  return sendViaSmtp(inquiry);
}

module.exports = {
  isSmtpConfigured,
  isResendConfigured,
  isMailConfigured,
  sendContactInquiryEmail,
};

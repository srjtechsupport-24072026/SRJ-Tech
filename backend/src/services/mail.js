const nodemailer = require('nodemailer');
const Company = require('../models/Company');

const SMTP_CONNECT_TIMEOUT_MS = Number(process.env.SMTP_CONNECT_TIMEOUT_MS || 12000);
const SMTP_SOCKET_TIMEOUT_MS = Number(process.env.SMTP_SOCKET_TIMEOUT_MS || 15000);
const SMTP_TOTAL_TIMEOUT_MS = Number(process.env.SMTP_TOTAL_TIMEOUT_MS || 20000);

function isSmtpConfigured() {
  return Boolean(process.env.SMTP_USER && process.env.SMTP_PASS);
}

function createTransport() {
  const port = Number(process.env.SMTP_PORT || 465);
  const secure =
    process.env.SMTP_SECURE !== undefined
      ? process.env.SMTP_SECURE === 'true'
      : port === 465;

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port,
    secure,
    auth: {
      user: process.env.SMTP_USER,
      // Gmail app passwords are often pasted with spaces; strip them.
      pass: String(process.env.SMTP_PASS || '').replace(/\s+/g, ''),
    },
    connectionTimeout: SMTP_CONNECT_TIMEOUT_MS,
    greetingTimeout: SMTP_CONNECT_TIMEOUT_MS,
    socketTimeout: SMTP_SOCKET_TIMEOUT_MS,
    tls: {
      // Avoid hanging forever on TLS negotiation quirks from some hosts
      minVersion: 'TLSv1.2',
    },
  });
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

/**
 * Sends website inquiry to company inbox and optional auto-reply to visitor.
 * Always fails fast on SMTP issues so the API never hangs waiting for Gmail.
 */
async function sendContactInquiryEmail(inquiry) {
  if (!isSmtpConfigured()) {
    const error = new Error(
      'Email is not configured. Set SMTP_USER and SMTP_PASS on the API service.'
    );
    error.code = 'SMTP_NOT_CONFIGURED';
    throw error;
  }

  const transporter = createTransport();
  const inbox = await resolveInbox();
  const from =
    process.env.MAIL_FROM ||
    `"SRJ Tech Website" <${process.env.SMTP_USER}>`;

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

  const sendAll = async () => {
    // Fail early if the SMTP server is unreachable / blocked
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
        text: [
          `Hi ${inquiry.name},`,
          '',
          'Thanks for contacting SRJ Tech. We received your message and will get back to you soon.',
          '',
          '— SRJ Tech Team',
          'srjtechsupport@gmail.com',
        ].join('\n'),
        html: `
          <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #111;">
            <p>Hi ${escapeHtml(inquiry.name)},</p>
            <p>Thanks for contacting <strong>SRJ Tech</strong>. We received your message and will get back to you soon.</p>
            <p>— SRJ Tech Team<br/>srjtechsupport@gmail.com</p>
          </div>
        `,
      });
      autoReplyId = autoReply.messageId;
    }

    return {
      to: inbox,
      messageId: companyMail.messageId,
      autoReplyId,
    };
  };

  try {
    return await withTimeout(sendAll(), SMTP_TOTAL_TIMEOUT_MS, 'SMTP send');
  } finally {
    transporter.close();
  }
}

module.exports = {
  isSmtpConfigured,
  sendContactInquiryEmail,
};

const nodemailer = require('nodemailer');
const Company = require('../models/Company');

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
      pass: process.env.SMTP_PASS,
    },
  });
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
 */
async function sendContactInquiryEmail(inquiry) {
  if (!isSmtpConfigured()) {
    const error = new Error(
      'Email is not configured. Set SMTP_USER and SMTP_PASS in backend/.env'
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
}

module.exports = {
  isSmtpConfigured,
  sendContactInquiryEmail,
};

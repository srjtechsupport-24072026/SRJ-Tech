const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Contact = require('../models/Contact');
const Company = require('../models/Company');
const { sendContactInquiryEmail } = require('../services/mail');

const router = express.Router();

function digitsOnly(value = '') {
  return String(value).replace(/\D/g, '');
}

function buildContactDetails(company) {
  const phoneDigits = digitsOnly(company.whatsapp || company.phone);
  const channels = [];

  if (company.email) {
    channels.push({
      id: 'email',
      label: 'Email',
      value: company.email,
      hint: 'Best for project briefs and docs',
      actionLabel: 'Send email',
      href: `mailto:${company.email}`,
    });
  }

  if (company.phone) {
    channels.push({
      id: 'phone',
      label: 'Phone',
      value: company.phone,
      hint: 'Call us during business hours',
      actionLabel: 'Call now',
      href: `tel:${digitsOnly(company.phone)}`,
    });
  }

  if (phoneDigits) {
    channels.push({
      id: 'whatsapp',
      label: 'WhatsApp',
      value: company.phone || `+${phoneDigits}`,
      hint: 'Quick chats and follow-ups',
      actionLabel: 'Chat on WhatsApp',
      href: `https://wa.me/${phoneDigits}`,
    });
  }

  return {
    companyName: company.name,
    email: company.email,
    phone: company.phone,
    whatsapp: company.whatsapp || company.phone,
    address: company.address,
    city: company.city,
    country: company.country,
    businessHours: company.businessHours,
    responseTime: company.responseTime,
    supportNote: company.supportNote,
    social: company.social || {},
    channels,
    inquiryTypes: [
      { id: 'general', label: 'General inquiry' },
      { id: 'project', label: 'New project' },
      { id: 'support', label: 'Support' },
      { id: 'partnership', label: 'Partnership' },
    ],
  };
}

/** Public contact details for website UI */
router.get('/details', async (_req, res) => {
  try {
    const company = await Company.findOne().lean();
    if (!company) {
      return res.status(404).json({ message: 'Contact details not found. Run npm run seed.' });
    }
    res.json(buildContactDetails(company));
  } catch (error) {
    res.status(500).json({ message: 'Failed to load contact details', error: error.message });
  }
});

/** Submit inquiry from website form */
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').trim().isEmail().withMessage('Valid email is required'),
    body('message').trim().isLength({ min: 10 }).withMessage('Message must be at least 10 characters'),
    body('subject').optional().trim(),
    body('phone').optional().trim(),
    body('companyName').optional().trim(),
    body('inquiryType')
      .optional()
      .isIn(['general', 'project', 'support', 'partnership'])
      .withMessage('Invalid inquiry type'),
    body('source').optional().trim(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const payload = {
        name: req.body.name,
        email: req.body.email,
        phone: req.body.phone || '',
        companyName: req.body.companyName || '',
        subject: req.body.subject || '',
        inquiryType: req.body.inquiryType || 'general',
        message: req.body.message,
        source: req.body.source || 'website',
      };

      // Persist first so a slow/blocked SMTP server never loses the inquiry.
      const contact = await Contact.create(payload);

      let emailDelivered = false;
      let emailWarning = null;

      try {
        const mailResult = await sendContactInquiryEmail(payload);
        emailDelivered = true;
        await Contact.findByIdAndUpdate(contact._id, {
          emailDelivered: true,
          emailMessageId: mailResult.messageId || '',
          emailError: '',
        });
      } catch (mailError) {
        console.error('Contact email failed:', mailError.message);
        emailWarning =
          mailError.code === 'SMTP_NOT_CONFIGURED'
            ? 'Message saved, but email delivery is not configured on the server.'
            : mailError.code === 'SMTP_TIMEOUT'
              ? 'Message saved, but email delivery timed out. Our team can still see it in the inbox database.'
              : 'Message saved, but email delivery failed. Please try again or email us directly.';

        await Contact.findByIdAndUpdate(contact._id, {
          emailDelivered: false,
          emailError: mailError.message,
        });
      }

      // Always acknowledge the saved inquiry. Email is best-effort so the
      // website never hangs when Gmail/SMTP is unreachable from Render.
      res.status(201).json({
        message: emailDelivered
          ? 'Thanks for reaching out. Your message was sent to our team.'
          : emailWarning ||
            'Thanks for reaching out. Our team will get back to you soon.',
        id: contact._id,
        inquiryType: contact.inquiryType,
        status: contact.status,
        emailDelivered,
      });
    } catch (error) {
      res.status(500).json({ message: 'Failed to submit contact form', error: error.message });
    }
  }
);

/** List inquiries (for internal/admin use) */
router.get(
  '/messages',
  [
    query('status').optional().isIn(['new', 'read', 'replied', 'archived']),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  async (req, res) => {
    try {
      const filter = {};
      if (req.query.status) filter.status = req.query.status;
      const limit = Number(req.query.limit) || 50;

      const [items, total, newCount] = await Promise.all([
        Contact.find(filter).sort({ createdAt: -1 }).limit(limit).lean(),
        Contact.countDocuments(filter),
        Contact.countDocuments({ status: 'new' }),
      ]);

      res.json({ items, total, newCount });
    } catch (error) {
      res.status(500).json({ message: 'Failed to load messages', error: error.message });
    }
  }
);

/** Update inquiry status */
router.patch('/messages/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    if (!['new', 'read', 'replied', 'archived'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const contact = await Contact.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).lean();

    if (!contact) {
      return res.status(404).json({ message: 'Message not found' });
    }

    res.json(contact);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update status', error: error.message });
  }
});

module.exports = router;

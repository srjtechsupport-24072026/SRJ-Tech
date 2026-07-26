const mongoose = require('mongoose');

const contactSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true },
    phone: { type: String, default: '', trim: true },
    companyName: { type: String, default: '', trim: true },
    subject: { type: String, default: '', trim: true },
    inquiryType: {
      type: String,
      enum: ['general', 'project', 'support', 'partnership'],
      default: 'general',
    },
    message: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: ['new', 'read', 'replied', 'archived'],
      default: 'new',
    },
    source: { type: String, default: 'website' },
    emailDelivered: { type: Boolean, default: false },
    emailError: { type: String, default: '' },
    emailMessageId: { type: String, default: '' },
  },
  { timestamps: true }
);

contactSchema.index({ createdAt: -1 });
contactSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('Contact', contactSchema);

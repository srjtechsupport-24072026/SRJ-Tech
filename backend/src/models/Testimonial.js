const mongoose = require('mongoose');

const testimonialSchema = new mongoose.Schema(
  {
    quote: { type: String, required: true },
    authorName: { type: String, required: true },
    authorRole: { type: String, default: '' },
    companyName: { type: String, default: '' },
    rating: { type: Number, min: 1, max: 5, default: 5 },
    avatarUrl: { type: String, default: '' },
    order: { type: Number, default: 0 },
    featured: { type: Boolean, default: true },
    published: { type: Boolean, default: true },
  },
  { timestamps: true }
);

testimonialSchema.index({ order: 1 });
testimonialSchema.index({ featured: 1, published: 1 });

module.exports = mongoose.model('Testimonial', testimonialSchema);

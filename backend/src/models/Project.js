const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    slug: { type: String, required: true, unique: true },
    summary: { type: String, required: true },
    description: { type: String, default: '' },
    client: { type: String, default: '' },
    industry: { type: String, default: '' },
    year: { type: String, default: '' },
    technologies: { type: [String], default: [] },
    highlights: { type: [String], default: [] },
    imageUrl: { type: String, default: '' },
    projectUrl: { type: String, default: '' },
    order: { type: Number, default: 0 },
    featured: { type: Boolean, default: true },
    published: { type: Boolean, default: true },
  },
  { timestamps: true }
);

projectSchema.index({ order: 1 });
projectSchema.index({ featured: 1, published: 1 });

module.exports = mongoose.model('Project', projectSchema);

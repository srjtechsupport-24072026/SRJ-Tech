const mongoose = require('mongoose');

const pageSchema = new mongoose.Schema(
  {
    slug: { type: String, required: true, unique: true, index: true },
    title: { type: String, required: true },
    subtitle: { type: String, default: '' },
    sections: [
      {
        heading: { type: String, default: '' },
        body: { type: String, default: '' },
        order: { type: Number, default: 0 },
      },
    ],
    published: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Page', pageSchema);

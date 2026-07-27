const express = require('express');
const Testimonial = require('../models/Testimonial');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const filter = { published: true };
    if (req.query.featured === 'true') filter.featured = true;

    const testimonials = await Testimonial.find(filter).sort({ order: 1 }).lean();
    res.json(testimonials);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to load testimonials',
      error: error.message,
    });
  }
});

module.exports = router;

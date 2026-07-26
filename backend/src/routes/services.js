const express = require('express');
const Service = require('../models/Service');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const services = await Service.find().sort({ order: 1 }).lean();
    res.json(services);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load services', error: error.message });
  }
});

module.exports = router;

const express = require('express');
const Company = require('../models/Company');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const company = await Company.findOne().lean();
    if (!company) {
      return res.status(404).json({ message: 'Company profile not found. Run npm run seed.' });
    }
    res.json(company);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load company profile', error: error.message });
  }
});

module.exports = router;

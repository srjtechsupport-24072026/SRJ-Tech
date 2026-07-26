const express = require('express');
const Page = require('../models/Page');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const pages = await Page.find({ published: true })
      .select('slug title subtitle')
      .sort({ title: 1 })
      .lean();
    res.json(pages);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load pages', error: error.message });
  }
});

router.get('/:slug', async (req, res) => {
  try {
    const page = await Page.findOne({ slug: req.params.slug, published: true }).lean();
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }
    page.sections = (page.sections || []).sort((a, b) => a.order - b.order);
    res.json(page);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load page', error: error.message });
  }
});

module.exports = router;

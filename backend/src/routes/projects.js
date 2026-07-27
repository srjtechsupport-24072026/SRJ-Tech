const express = require('express');
const Project = require('../models/Project');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const filter = { published: true };
    if (req.query.featured === 'true') filter.featured = true;

    const projects = await Project.find(filter).sort({ order: 1 }).lean();
    res.json(projects);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load projects', error: error.message });
  }
});

router.get('/:slug', async (req, res) => {
  try {
    const project = await Project.findOne({
      slug: req.params.slug,
      published: true,
    }).lean();

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    res.json(project);
  } catch (error) {
    res.status(500).json({ message: 'Failed to load project', error: error.message });
  }
});

module.exports = router;

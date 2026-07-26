require('dotenv').config();

const { connectDB } = require('../config/db');
const Company = require('../models/Company');
const Page = require('../models/Page');
const Service = require('../models/Service');

async function seed() {
  await connectDB();

  await Promise.all([Company.deleteMany({}), Page.deleteMany({}), Service.deleteMany({})]);

  await Company.create({
    name: 'SRJ Tech',
    tagline: 'Innovate • Solve • Elevate',
    description:
      'SRJ Tech is a software company focused on crafting modern web, mobile, and cloud products. We partner with startups and growing businesses to design, build, and scale digital experiences that last.',
    email: 'srjtechsupport@gmail.com',
    phone: '+91 81379 67192',
    whatsapp: '+91 81379 67192',
    address: 'India',
    city: '',
    country: 'India',
    businessHours: 'Mon – Sat, 10:00 AM – 7:00 PM IST',
    responseTime: 'We usually reply within 24 hours',
    supportNote: 'Share your project goals, timeline, and any existing product links so we can help faster.',
    social: {
      linkedin: 'https://linkedin.com',
      twitter: 'https://twitter.com',
      github: 'https://github.com',
      instagram: '',
    },
  });

  await Page.insertMany([
    {
      slug: 'home',
      title: 'Home',
      subtitle: 'Software crafted with clarity and care',
      sections: [
        {
          heading: 'What we do',
          body: 'We design and engineer digital products — from polished company websites to production-ready apps — using Flutter, Node.js, and modern cloud stacks.',
          order: 1,
        },
        {
          heading: 'How we work',
          body: 'Clear communication, iterative delivery, and a bias for quality. We ship foundations first, then grow features with you.',
          order: 2,
        },
      ],
    },
    {
      slug: 'about',
      title: 'About SRJ Tech',
      subtitle: 'A software studio built for long-term partners',
      sections: [
        {
          heading: 'Our story',
          body: 'SRJ Tech started with a simple goal: help companies ship dependable software without the noise. We combine product thinking with solid engineering so teams can move fast and stay maintainable.',
          order: 1,
        },
        {
          heading: 'Our approach',
          body: 'We start with understanding your users and business goals, then translate that into clean architecture, thoughtful UI, and APIs that scale. Every engagement begins with a strong foundation you can grow on.',
          order: 2,
        },
        {
          heading: 'What we value',
          body: 'Clarity over complexity. Craft over shortcuts. Partnership over transactions. We measure success by the confidence our clients have in the systems we leave behind.',
          order: 3,
        },
      ],
    },
    {
      slug: 'services',
      title: 'Services',
      subtitle: 'End-to-end product engineering',
      sections: [
        {
          heading: 'From idea to production',
          body: 'Whether you need a marketing site, a customer-facing app, or a backend platform, SRJ Tech can own the full delivery lifecycle — discovery, design, development, and launch support.',
          order: 1,
        },
      ],
    },
    {
      slug: 'contact',
      title: 'Contact',
      subtitle: 'Tell us what you are building',
      sections: [
        {
          heading: 'Get in touch',
          body: 'Reach us by email, phone, or WhatsApp — or send a project note through the form. Share your goals and timeline and we will respond with clear next steps.',
          order: 1,
        },
      ],
    },
  ]);

  await Service.insertMany([
    {
      title: 'Web Applications',
      summary: 'Fast, responsive web products with modern UI and reliable APIs.',
      description:
        'We build dynamic websites and web apps using Flutter Web on the frontend and Node.js with MongoDB on the backend.',
      icon: 'web',
      order: 1,
      featured: true,
    },
    {
      title: 'Mobile Apps',
      summary: 'Cross-platform Flutter apps for iOS and Android from one codebase.',
      description:
        'Ship polished mobile experiences with shared UI, platform-aware design, and clean API integration.',
      icon: 'phone',
      order: 2,
      featured: true,
    },
    {
      title: 'API & Backend',
      summary: 'Secure, scalable Node.js services backed by MongoDB.',
      description:
        'REST APIs, authentication, content management, and integrations designed for growth.',
      icon: 'api',
      order: 3,
      featured: true,
    },
    {
      title: 'Product Consulting',
      summary: 'Architecture reviews, roadmap planning, and technical guidance.',
      description:
        'Get clarity on stack choices, delivery plans, and how to evolve your product with confidence.',
      icon: 'consult',
      order: 4,
      featured: true,
    },
  ]);

  console.log('Seed complete: company, pages, and services are ready.');
  process.exit(0);
}

seed().catch((error) => {
  console.error('Seed failed:', error);
  process.exit(1);
});

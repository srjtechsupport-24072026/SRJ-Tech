require('dotenv').config();

const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const mongoose = require('mongoose');
const { connectDBWithRetry } = require('./config/db');

const companyRoutes = require('./routes/company');
const pageRoutes = require('./routes/pages');
const serviceRoutes = require('./routes/services');
const contactRoutes = require('./routes/contact');

const app = express();
const PORT = process.env.PORT || 5001;

app.set('trust proxy', 1);

const allowedOrigins = (process.env.CORS_ORIGIN || '*')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean);

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes('*')) {
        return callback(null, true);
      }
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      // Render static site (+ PR preview subdomains)
      if (
        process.env.ALLOW_RENDER_HOSTING !== 'false' &&
        /^https:\/\/[a-z0-9-]+(\.[a-z0-9-]+)*\.onrender\.com$/i.test(origin)
      ) {
        return callback(null, true);
      }
      return callback(new Error(`CORS blocked for origin: ${origin}`));
    },
  })
);
app.use(express.json());
app.use(morgan('dev'));

app.get('/', (_req, res) => {
  res.json({
    service: 'SRJ Tech API',
    docs: '/api/health',
    endpoints: ['/api/company', '/api/pages', '/api/services', '/api/contact/details'],
  });
});

app.get('/api/health', (_req, res) => {
  const dbStates = ['disconnected', 'connected', 'connecting', 'disconnecting'];
  res.json({
    status: 'ok',
    company: 'SRJ Tech',
    database: dbStates[mongoose.connection.readyState] || 'unknown',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/company', companyRoutes);
app.use('/api/pages', pageRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/contact', contactRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ message: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`SRJ Tech API running on port ${PORT}`);
});

connectDBWithRetry();

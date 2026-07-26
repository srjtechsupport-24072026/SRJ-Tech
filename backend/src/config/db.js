const mongoose = require('mongoose');

async function connectDB() {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/srj_tech';
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 15000 });
  console.log('MongoDB connected');
}

/**
 * Retries forever so a temporary Atlas/DNS problem cannot kill the web service.
 */
async function connectDBWithRetry(delayMs = 10000) {
  for (let attempt = 1; ; attempt += 1) {
    try {
      await connectDB();
      return;
    } catch (error) {
      console.error(`MongoDB connection attempt ${attempt} failed:`, error.message);
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
}

module.exports = { connectDB, connectDBWithRetry };

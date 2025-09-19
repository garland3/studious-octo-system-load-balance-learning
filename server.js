const express = require('express');
const app = express();

// Get server ID from environment variable or default to 'unknown'
const serverId = process.env.SERVER_ID || 'unknown';
const port = process.env.PORT || 3000;

// Middleware to log requests
app.use((req, res, next) => {
  console.log(`[Server ${serverId}] ${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Main endpoint
app.get('/', (req, res) => {
  const response = {
    message: 'Hello from Load Balanced Server!',
    serverId: serverId,
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname()
  };
  
  res.json(response);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    serverId: serverId,
    uptime: process.uptime()
  });
});

// Status endpoint with server info
app.get('/status', (req, res) => {
  res.json({
    serverId: serverId,
    port: port,
    hostname: require('os').hostname(),
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server ${serverId} is running on port ${port}`);
});
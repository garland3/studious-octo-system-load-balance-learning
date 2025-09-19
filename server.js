const http = require('http');
const os = require('os');

// Get server ID from environment variable or default to 'unknown'
const serverId = process.env.SERVER_ID || 'unknown';
const port = process.env.PORT || 3000;

// Helper function to send JSON response
function sendJSON(res, statusCode, data) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data, null, 2));
}

// Helper function to log requests
function logRequest(req) {
  console.log(`[Server ${serverId}] ${new Date().toISOString()} - ${req.method} ${req.url}`);
}

// Create HTTP server
const server = http.createServer((req, res) => {
  logRequest(req);
  
  if (req.url === '/' && req.method === 'GET') {
    // Main endpoint
    const response = {
      message: 'Hello from Load Balanced Server!',
      serverId: serverId,
      timestamp: new Date().toISOString(),
      hostname: os.hostname()
    };
    sendJSON(res, 200, response);
    
  } else if (req.url === '/health' && req.method === 'GET') {
    // Health check endpoint
    const response = {
      status: 'healthy',
      serverId: serverId,
      uptime: process.uptime()
    };
    sendJSON(res, 200, response);
    
  } else if (req.url === '/status' && req.method === 'GET') {
    // Status endpoint with server info
    const response = {
      serverId: serverId,
      port: port,
      hostname: os.hostname(),
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    };
    sendJSON(res, 200, response);
    
  } else {
    // 404 for unknown endpoints
    const response = {
      error: 'Not Found',
      serverId: serverId,
      path: req.url
    };
    sendJSON(res, 404, response);
  }
});

// Start server
server.listen(port, '0.0.0.0', () => {
  console.log(`Server ${serverId} is running on port ${port}`);
});
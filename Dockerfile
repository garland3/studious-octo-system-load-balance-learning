FROM node:18-alpine

WORKDIR /app

# Copy server code (no npm install needed - using built-in modules)
COPY server.js ./

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["node", "server.js"]
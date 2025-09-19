FROM node:18-alpine

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy server code
COPY server.js ./

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["npm", "start"]
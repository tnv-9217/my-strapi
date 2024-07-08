# Use the official Node.js image as the base image
FROM node:20-alpine

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your app's source code
COPY . .

# Expose the Strapi port
EXPOSE 1337

# Start the Strapi server
CMD ["npm", "run", "start"]

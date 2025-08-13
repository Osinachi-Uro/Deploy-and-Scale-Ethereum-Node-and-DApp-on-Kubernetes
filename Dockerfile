# Node as base image
FROM node:18

# Set working directory
WORKDIR /app

# Copy DApp files
COPY DApp/package*.json ./
COPY DApp/truffle-config.js ./
COPY DApp/contracts/ ./contracts/
COPY DApp/migrations/ ./migrations/
COPY DApp/src/ ./src/

# Install dependencies
RUN npm install -g truffle@5.11.5 http-server && \
    npm install && \
    truffle compile

# Build/compile contracts
RUN truffle compile --all

# Copy compiled ABI JSONs into the folder served by http-server
RUN mkdir -p public && cp -r build/contracts/*.json public/

# Move frontend files to public
RUN cp -r src/* public/

# Serve static files
EXPOSE 8080
CMD ["http-server", "public", "-p", "8080"]

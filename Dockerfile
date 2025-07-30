# #======================
# # For Github Action
# #======================
# # Stage 1: Truffle compile and prepare files
# FROM node:18 AS build-stage

# WORKDIR /app

# # Copy DApp contract files
# COPY package*.json ./
# COPY truffle-config.js ./
# COPY contracts ./contracts
# COPY migrations ./migrations

# # Install Truffle and dependencies
# RUN npm install -g truffle && npm install

# # Compile contracts
# RUN truffle compile

# # Copy frontend files
# COPY src ./src

# # Stage 2: Nginx to serve static content
# FROM nginx:alpine

# # Copy frontend to serve from nginx
# COPY --from=build-stage /app/src /usr/share/nginx/html

# # (Optional) Copy contract ABIs to frontend (can access via JS if needed)
# COPY --from=build-stage /app/build/contracts /usr/share/nginx/html/abis

# # Expose web port
# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]


# Dockerfile for Local Build and Test
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

# Build contracts
RUN truffle compile --all

# Copy compiled ABI JSONs into the folder served by http-server
RUN mkdir -p public && cp -r build/contracts/*.json public/

# Move frontend files to public
RUN cp -r src/* public/

# Serve static files
EXPOSE 8080
CMD ["http-server", "public", "-p", "8080"]

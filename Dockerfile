# Base stage
FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies stage
FROM base AS deps
COPY package*.json ./
RUN npm ci

# Development stage
FROM base AS development
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Build stage for production
FROM base AS builder
COPY package*.json ./
RUN npm ci --production=false
COPY . .

# Production stage
FROM base AS production
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --production
COPY --from=builder /app .
EXPOSE 3000
CMD ["npm", "start"]

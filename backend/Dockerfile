# syntax=docker/dockerfile:1

ARG NODE_VERSION=22
ARG PNPM_VERSION=10

################################################################################
# Stage 1: Base image for all stages
FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /usr/src/app
RUN npm install -g pnpm@${PNPM_VERSION}

################################################################################
# Stage 2: Dependencies
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
# Install ALL dependencies (including devDependencies for building)
RUN pnpm install --no-frozen-lockfile

################################################################################
# Stage 3: Build the application
FROM deps AS build
COPY . .
RUN pnpm run build

################################################################################
# Stage 4: Production dependencies only
FROM base AS prod-deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --no-frozen-lockfile

################################################################################
# Stage 5: Final production image
FROM node:${NODE_VERSION}-alpine AS final

# Create a special user for the application
RUN addgroup -S stride_group && adduser -S stride_user -G stride_group

WORKDIR /usr/src/app

# Set production environment
ENV NODE_ENV production
ENV PORT 4000

# Copy only the necessary files from build stages
COPY --from=prod-deps /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
COPY package.json ./

# Change ownership to the special user
RUN chown -R stride_user:stride_group /usr/src/app

# Switch to the special user
USER stride_user

# Expose the application port
EXPOSE 4000

# Healthcheck to ensure the container is running correctly
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:4000/ || exit 1

# Start the application
CMD ["node", "dist/app.js"]

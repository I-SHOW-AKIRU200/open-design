# Stage 1: Build the workspace dependencies safely
FROM node:24-bullseye AS builder

WORKDIR /app

# Enable pnpm natively inside Node 24 
RUN corepack enable pnpm

# Copy workspace structural files first to optimize layer caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/daemon/package.json ./apps/daemon/
COPY packages/ ./packages/

# Install the monorepo tree dependencies smoothly
RUN pnpm install --frozen-lockfile

# Copy the rest of the source directories
COPY . .

# Compile required workspace core contracts followed by the daemon server
RUN pnpm --filter @open-design/contracts build
RUN pnpm --filter @open-design/daemon build

# Stage 2: Runtime image to keep image size small
FROM node:24-slim AS runner

WORKDIR /app
RUN corepack enable pnpm

COPY --from=builder /app /app

# Hugging Face strictly maps web routing exclusively to port 7860
EXPOSE 7860
ENV PORT=7860

# Execute the compiled native backend production daemon process
CMD ["node", "apps/daemon/dist/index.js", "--port", "7860"]

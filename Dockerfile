FROM node:24-bullseye

WORKDIR /app

RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/daemon/package.json ./apps/daemon/
COPY packages/ ./packages/

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm --filter @open-design/contracts build
RUN pnpm --filter @open-design/daemon build

EXPOSE 7860

CMD ["node", "apps/daemon/dist/index.js"]

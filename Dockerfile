FROM node:20-bookworm-slim AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-bookworm-slim AS runtime

ENV NODE_ENV=production
ENV CHAT2API_HEADLESS=1
ENV ELECTRON_DISABLE_SECURITY_WARNINGS=true
ENV DISPLAY=:99

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxshmfence1 \
    libxss1 \
    tini \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY --from=builder /app/out ./out
COPY --from=builder /app/build ./build
COPY --from=builder /app/sha3_wasm_bg.7b9ca65ddd.wasm ./sha3_wasm_bg.7b9ca65ddd.wasm
COPY --from=builder /app/docker ./docker

EXPOSE 8080
VOLUME ["/root/.chat2api"]

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "/app/docker/entrypoint.sh"]

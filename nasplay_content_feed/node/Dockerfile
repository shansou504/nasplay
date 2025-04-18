# syntax=docker/dockerfile:1
FROM node:22
USER node
WORKDIR /home/node/app
ENV NODE_ENV=production
COPY package.json package-lock.json .
RUN npm ci
COPY index.js .
RUN mkdir media
EXPOSE 3000

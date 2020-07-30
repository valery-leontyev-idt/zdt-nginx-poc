FROM node:14-alpine AS zdt-poc-node-app
ENV HOST 0.0.0.0
ENV PORT 3000

WORKDIR /app
COPY . .
RUN npm install --production
CMD npm start
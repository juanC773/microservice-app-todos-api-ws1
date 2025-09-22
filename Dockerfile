# Dockerfile para TODOs API (Node.js)
FROM node:8.17.0-alpine

LABEL maintainer="alejandro.t.s.321@gmail.com"

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

EXPOSE 8082

# Variables de entorno por defecto (se pueden sobrescribir)
ENV TODO_API_PORT=8082
ENV JWT_SECRET=PRFT
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_CHANNEL=log_channel

CMD ["npm", "start"]
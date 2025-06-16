# Build stage
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
# Optional: Copy a custom nginx configuration file, if not managed by ansible or other means
#COPY nginx/nginx_basic.conf /etc/nginx/conf.d/default.conf
#COPY nginx/sites-available/server.conf /etc/nginx/conf.d/sites-available/server.conf

EXPOSE 80
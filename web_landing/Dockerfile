# Stage 1: Build the Vite App
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve the App using Nginx
FROM nginx:alpine
# Copy the custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the built assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html
# Expose port 8080 (Cloud Run default)
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

# Use an official lightweight web server image
FROM nginx:stable-alpine

# Update system packages to pick up latest security fixes
RUN apk update && apk upgrade --no-cache

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy all web application files from APP folder to nginx html directory
COPY APP/ .

# Expose port 80
EXPOSE 80

# Start nginx server in foreground
CMD ["nginx", "-g", "daemon off;"]


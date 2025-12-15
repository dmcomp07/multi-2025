FROM nginx:latest

# Copy application code
COPY . /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]

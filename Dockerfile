FROM alpine:latest

# Install packages and remove default server definition
RUN apk add --no-cache \
    curl \
    nginx \
    supervisor

# Setup document root
WORKDIR /var/www/html

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
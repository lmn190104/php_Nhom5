FROM php:8.2-apache

# Cài extension cần cho Laravel
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Enable rewrite
RUN a2enmod rewrite

# Set thư mục web root trỏ vào public/
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy source code
COPY . /var/www/html

# Quyền thư mục
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Cài composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Cài package Laravel
RUN composer install --no-dev --optimize-autoloader

# Laravel optimize
RUN php artisan key:generate || true
RUN php artisan config:clear
RUN php artisan config:cache
RUN php artisan route:cache

EXPOSE 80

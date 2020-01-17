FROM php:7.4-apache
LABEL maintainer="Niels Lippke<nlippke@gmx.de>"
ENV VER 5.1.13

# Update and install necessary packages
RUN apt-get update && apt-get install --no-install-recommends gnumeric libpng-dev catdoc poppler-utils \
    id3 docx2txt tesseract-ocr tesseract-ocr-deu ocrmypdf imagemagick vim parallel dos2unix cron -y
RUN docker-php-ext-install gd mysqli pdo pdo_mysql && \
    pear channel-update pear.php.net && pear install Log

# Get seeddms
RUN curl -fsSL https://downloads.sourceforge.net/project/seeddms/seeddms-${VER}/seeddms-quickstart-${VER}.tar.gz | tar -xzC /var/www
RUN mv /var/www/seeddms51x /var/www/seeddms && touch /var/www/seeddms/data/conf/ENABLE_INSTALL_TOOL

# Copy settings-files
COPY sources/php.ini /usr/local/etc/php/
COPY sources/000-default.conf /etc/apache2/sites-available/
COPY sources/settings.xml /var/www/seeddms/data/conf/settings.xml
COPY sources/ocrmypdf.sh /usr/local/bin
COPY sources/seeddms-entrypoint /usr/local/bin

RUN chown -R www-data:www-data /var/www/seeddms/ && \
    dos2unix /usr/local/bin/ocrmypdf.sh && chmod a+rx /usr/local/bin/ocrmypdf.sh && \
    dos2unix /usr/local/bin/seeddms-entrypoint && chmod a+rx /usr/local/bin/seeddms-entrypoint && \
    a2enmod rewrite

RUN cp -a /var/www/seeddms/data /var/www/seeddms/data.bak

# Volumes to mount
VOLUME [ "/var/www/seeddms/data", "/var/www/seeddms/www/ext" ]

ENTRYPOINT [ "/usr/local/bin/seeddms-entrypoint"]
CMD ["apache2-foreground"]
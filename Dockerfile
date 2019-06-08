FROM ubuntu:16.04
MAINTAINER xiaofd <jun@jun.ac.cn>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  nginx php php-fpm supervisor \
  wget unzip patch

# install h5ai and patch configuration
#RUN wget http://release.larsjung.de/h5ai/h5ai-0.24.1.zip
#RUN unzip h5ai-0.24.1.zip -d /usr/share/h5ai
COPY h5ai-0.29.2.zip .
#COPY default /etc/nginx/sites-available/default
RUN unzip h5ai-0.29.2.zip -d /usr/share/h5ai
RUN chmod -R 0777 /usr/share/h5ai/
# patch h5ai because we want to deploy it ouside of the document root and use /var/www as root for browsing
#ADD App.php.patch App.php.patch
#RUN patch -p1 -u -d /usr/share/h5ai/_h5ai/server/php/inc/ -i /App.php.patch && rm App.php.patch

#ADD options.json.patch options.json.patch
#RUN patch -p1 -u -d /usr/share/h5ai/_h5ai/conf/ -i /options.json.patch && rm options.json.patch
#RUN sed -i "s#\$this->set('ROOT_PATH', Util::normalize_path(dirname(\$this->get('H5AI_PATH')), false))#\$this->set('ROOT_PATH', '/var/www')#g" /usr/share/h5ai/_h5ai/private/php/core/class-setup.php
# add h5ai as the only nginx site

ADD h5ai.nginx.conf /etc/nginx/sites-available/h5ai
RUN ln -s /etc/nginx/sites-available/h5ai /etc/nginx/sites-enabled/h5ai
RUN rm /etc/nginx/sites-enabled/default
RUN mkdir -p /run/php
WORKDIR /var/www

# add dummy files in case the container is not run with a volume mounted to /var/www

RUN echo "Looks like you did not mount a volume to `/var/www`. See README.md for details." > /var/www/INSTALL.md
RUN mkdir -p /var/www/first/second/third/fourth/fifth
ADD README.md /var/www/README.md

# use supervisor to monitor all services
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD supervisord -c /etc/supervisor/conf.d/supervisord.conf

# expose only nginx HTTP port
EXPOSE 80

# expose path
VOLUME /var/www

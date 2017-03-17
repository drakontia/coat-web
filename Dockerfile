FROM alpine:3.5

MAINTAINER drakontia

ENV NGXDEVEL_VERSION=0.3.0
ENV NGXLUA_VERSION=0.10.7
ENV NGINX_VERSION=1.11.10

RUN apk --no-cache update \
  && apk --no-cache add --virtual build-dependencies curl build-base openssl-dev \
  && apk --no-cache add pcre-dev libxslt-dev gd-dev geoip-dev \
  && apk --no-cache add lua lua-dev openssl

RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${NGXDEVEL_VERSION}.tar.gz \
  && tar xvfz v${NGXDEVEL_VERSION}.tar.gz \
  && wget https://github.com/openresty/lua-nginx-module/archive/v${NGXLUA_VERSION}.tar.gz \
  && tar xvfz v${NGXLUA_VERSION}.tar.gz \
  && curl -O -s http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xvfz nginx-${NGINX_VERSION}.tar.gz \
  && addgroup -S nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  && cd nginx-${NGINX_VERSION} \
  && export LUA_LIB=/usr/lib \
  && export LUA_INC=/usr/include \
  && ./configure \
       --prefix=/opt/nginx \
       --conf-path=/etc/nginx/nginx.conf \
       --http-log-path=/var/log/nginx/access.log \
       --error-log-path=/var/log/nginx/error.log \
       --lock-path=/var/lock/nginx.lock \
       --pid-path=/run/nginx.pid \
       --http-client-body-temp-path=/var/lib/nginx/body \
       --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
       --http-proxy-temp-path=/var/lib/nginx/proxy \
       --http-scgi-temp-path=/var/lib/nginx/scgi \
       --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
       --with-ld-opt="-Wl,-rpath,/usr/bin/lua/lib" \
       --with-debug \
       --with-pcre-jit \
       --with-ipv6 \
       --with-threads \
       --with-http_ssl_module \
       --with-http_stub_status_module \
       --with-http_realip_module \
       --with-http_auth_request_module \
       --with-http_addition_module \
       --with-http_geoip_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_image_filter_module \
       --with-http_v2_module \
       --with-http_sub_module \
       --with-http_xslt_module \
       --add-module=/ngx_devel_kit-${NGXDEVEL_VERSION} \
       --add-module=/lua-nginx-module-${NGXLUA_VERSION} \
  && make \
  && make install \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && cd / \
  && mkdir /var/lib/nginx \
  && apk del --purge build-dependencies \
  && rm v${NGXDEVEL_VERSION}.tar.gz \
  && rm -rf ngx_devel_kit-${NGXDEVEL_VERSION} \
  && rm v${NGXLUA_VERSION}.tar.gz \
  && rm -rf lua-nginx-module-${NGXLUA_VERSION} \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  && rm -rf nginx-${NGINX_VERSION} \
  && rm -rf /var/cache/apk/*

EXPOSE 80
EXPOSE 443

CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]

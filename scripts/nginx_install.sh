#!/bin/sh
THE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_TEMP_DIR="$THE_DIR/nginx_build"

if [ ! -d $BUILD_TEMP_DIR ]; then
  mkdir -p $BUILD_TEMP_DIR
fi
if [ ! -d $BUILD_TEMP_DIR ]; then
  echo "[FATAL] You have no permission to write in directory: $THE_DIR"
  exit
fi
#TOUCH_FILE=$BUILD_TEMP_DIR/touch_file_`date +"%Y%m%d%H%M%S"`
#touch $BUILD_TEMP_DIR/touch_file
#if [ ! "$?" != "0" ]; then
#fi
#if [ ! -f $TOUCH_FILE ]; then
#fi
cd $BUILD_TEMP_DIR

yum install -y --nogpgcheck git zlib-devel gcc gcc-c++ automake autoconf make \
    libxml2-devel libxslt-devel patch glibc glibc-devel glibc-static imake curl \
    \
    intltool protobuf-lite-devel protobuf-lite-static protobuf-lite libuuid-devel \
    protobuf-compiler pcre-devel readline-devel boost boost-devel boost-date-time \
    boost-regex boost-static boost-system boost-thread boost-filesystem \
    boost-iostreams boost-program-options libldap-devel libgearman-devel \
    libmemcached-devel memcahced pam-devel

# try to git clone and retry 3 times
# @param {String} git repository's url
# @param {String} target path, the local directory
function get_modules () {
  target_dir="$BUILD_TEMP_DIR/$2"
  if [ ! -d "$target_dir" ]; then
    git clone $1 $target_dir
    if [ "0" != "$?" ]; then
      git clone $1 $target_dir
      if [ "0" != "$?" ]; then
        git clone $1 $target_dir
      fi
    fi
  fi
}

get_modules "https://github.com/agentzh/echo-nginx-module.git" \
    "echo-nginx-module"
get_modules "https://github.com/agentzh/set-misc-nginx-module.git" \
    "set-misc-nginx-module"
get_modules "https://github.com/agentzh/headers-more-nginx-module.git" \
    "headers-more-nginx-module"
get_modules "https://github.com/agentzh/memc-nginx-module.git" \
    "memc-nginx-module"
get_modules "https://github.com/simpl/ngx_devel_kit.git" \
    "ngx_devel_kit"
get_modules "https://github.com/chaoslawful/lua-nginx-module.git" \
    "lua-nginx-module"
get_modules "https://github.com/agentzh/redis2-nginx-module.git" \
    "redis2-nginx-module"
get_modules \
    "https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git" \
    "ngx_http_substitutions_filter_module"
get_modules "https://github.com/yaoweibin/nginx_tcp_proxy_module.git" \
    "nginx_tcp_proxy_module"
get_modules "https://github.com/samizdatco/nginx-http-auth-digest.git" \
    "nginx-http-auth-digest"
get_modules "https://github.com/openresty/encrypted-session-nginx-module.git" \
    "encrypted-session-nginx-module"
get_modules "https://github.com/openresty/replace-filter-nginx-module.git" \
    "replace-filter-nginx-module"
get_modules "https://github.com/openresty/lua-upstream-nginx-module.git" \
    "lua-upstream-nginx-module"
get_modules "https://github.com/openresty/drizzle-nginx-module.git" \
    "drizzle-nginx-module"
get_modules "https://github.com/openresty/array-var-nginx-module.git" \
    "array-var-nginx-module"
get_modules "https://github.com/openresty/xss-nginx-module.git" \
    "xss-nginx-module"

if [ ! -f "$BUILD_TEMP_DIR/nginx-1.9.9.tar.gz" ]; then
  wget -t 3 -O nginx-1.9.9.tar.gz \
      "http://nginx.org/download/nginx-1.9.9.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/openssl-1.0.2e.tar.gz" ]; then
  wget -t 3 -O openssl-1.0.2e.tar.gz \
      "http://www.openssl.org/source/openssl-1.0.2e.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/pcre-8.38.tar.gz" ]; then
  wget -t 3 -O pcre-8.38.tar.gz \
      "http://kc32.com/software/pcre-8.38.tar.gz"
#      "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/LuaJIT-2.0.4.tar.gz" ]; then
  wget -t 3 -O LuaJIT-2.0.4.tar.gz \
      "http://kc32.com/software/LuaJIT-2.0.4.tar.gz"
#      "http://luajit.org/download/LuaJIT-2.0.4.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/drizzle7-2011.07.21.tar.gz" ]; then
  wget -t 3 -O drizzle7-2011.07.21.tar.gz \
      "http://kc32.com/software/drizzle7-2011.07.21.tar.gz"
#      "http://agentzh.org/misc/nginx/drizzle7-2011.07.21.tar.gz"
fi

if [ ! -d "$BUILD_TEMP_DIR/nginx-1.9.9" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/nginx-1.9.9.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/openssl-1.0.2e" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/openssl-1.0.2e.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/pcre-8.38" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/pcre-8.38.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/LuaJIT-2.0.4" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/LuaJIT-2.0.4.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/drizzle7-2011.07.21" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf \
      "$BUILD_TEMP_DIR/drizzle7-2011.07.21.tar.gz"
fi

# first, config and make and install luajit-2.0
cd "$BUILD_TEMP_DIR/LuaJIT-2.0.4"
make && make install

export LUAJIT_LIB="/usr/local/lib"
export LUAJIT_INC="/usr/local/include/luajit-2.0"

echo '/usr/local/lib' > /etc/ld.so.conf.d/luajit.conf
ldconfig

# second, fetch, make, instal libdrizzle for drizzle-ngx-module
cd "$BUILD_TEMP_DIR/drizzle7-2011.07.21"
./configure --without-server
make libdrizzle-1.0
make install-libdrizzle-1.0

# temparorily fix an unused-paramater 
# added by simonkuang on 2015-12-17
sed -i -e "/ngx_http_auth_digest_decode_auth/,+10 s~^\([^/]*\),[[:blank:]]*\*p\([^/]*\)\(//.*\)\?$~\1\2 //\1, *p\2~I" \
    -e "/ngx_http_auth_digest_decode_auth/,+10 s~\(//[[:blank:]]*\)\?\(p[[:blank:]]*=[[:blank:]]*ngx_sprintf(.*\)~// \2~I" \
    -e "/ngx_http_auth_digest_decode_auth[^{]*{/,+30 s~\(//[[:blank:]]*\)\?\(p[[:blank:]]*=[[:blank:]]*ngx_cpymem(.*\)~// \2~I" \
    $BUILD_TEMP_DIR/nginx-http-auth-digest/ngx_http_auth_digest_module.c

# building nginx
cd "$BUILD_TEMP_DIR/nginx-1.9.9"
# patch for tcp proxy
patch -p1 < ../nginx_tcp_proxy_module/tcp.patch
# configure && make && make install
./configure \
  --prefix=/usr/local/nginx-1.9.9 \
  --user=nobody \
  --group=nobody \
  --with-http_ssl_module \
  --with-http_addition_module \
  --with-http_realip_module \
  --with-http_xslt_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_gzip_static_module \
  --with-http_stub_status_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-pcre="$BUILD_TEMP_DIR/pcre-8.38" \
  --with-openssl="$BUILD_TEMP_DIR/openssl-1.0.2e" \
  --add-module="$BUILD_TEMP_DIR/ngx_devel_kit" \
  --add-module="$BUILD_TEMP_DIR/echo-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/headers-more-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/memc-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/set-misc-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/lua-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/redis2-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/ngx_http_substitutions_filter_module" \
  --add-module="$BUILD_TEMP_DIR/nginx_tcp_proxy_module" \
  --add-module="$BUILD_TEMP_DIR/nginx-http-auth-digest" \
  --add-module="$BUILD_TEMP_DIR/encrypted-session-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/lua-upstream-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/drizzle-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/array-var-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/xss-nginx-module"

make && make install



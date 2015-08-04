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
    libxml2-devel libxslt-devel patch glibc glibc-devel glibc-static imake curl

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

if [ ! -f "$BUILD_TEMP_DIR/nginx-1.9.3.tar.gz" ]; then
  wget -t 3 -O nginx-1.9.3.tar.gz \
      "http://nginx.org/download/nginx-1.9.3.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/openssl-1.0.2d.tar.gz" ]; then
  wget -t 3 -O openssl-1.0.2d.tar.gz \
      "http://www.openssl.org/source/openssl-1.0.2d.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/pcre-8.37.tar.gz" ]; then
  wget -t 3 -O pcre-8.37.tar.gz \
      "http://cd82.com/software/pcre-8.37.tar.gz"
#      "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz"
fi
if [ ! -f "$BUILD_TEMP_DIR/LuaJIT-2.0.4.tar.gz" ]; then
  wget -t 3 -O LuaJIT-2.0.4.tar.gz \
      "http://cd82.com/software/LuaJIT-2.0.4.tar.gz"
#      "http://luajit.org/download/LuaJIT-2.0.4.tar.gz"
fi

if [ ! -d "$BUILD_TEMP_DIR/nginx-1.9.3" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/nginx-1.9.3.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/openssl-1.0.2d" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/openssl-1.0.2d.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/pcre-8.37" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/pcre-8.37.tar.gz"
fi
if [ ! -d "$BUILD_TEMP_DIR/LuaJIT-2.0.4" ]; then
  tar -C "$BUILD_TEMP_DIR/" -zxf "$BUILD_TEMP_DIR/LuaJIT-2.0.4.tar.gz"
fi

# first, config and make and install luajit-2.0
cd "$BUILD_TEMP_DIR/LuaJIT-2.0.4"
make && make install

export LUAJIT_LIB="/usr/local/lib"
export LUAJIT_INC="/usr/local/include/luajit-2.0"

echo '/usr/local/lib' > /etc/ld.so.conf.d/luajit.conf
ldconfig

# building nginx
cd "$BUILD_TEMP_DIR/nginx-1.9.3"
# patch for tcp proxy
patch -p1 < ../nginx_tcp_proxy_module/tcp.patch
# configure && make && make install
./configure \
  --prefix=/usr/local/nginx-1.9.3 \
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
  --with-pcre="$BUILD_TEMP_DIR/pcre-8.37" \
  --with-openssl="$BUILD_TEMP_DIR/openssl-1.0.2d" \
  --add-module="$BUILD_TEMP_DIR/ngx_devel_kit" \
  --add-module="$BUILD_TEMP_DIR/echo-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/headers-more-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/memc-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/set-misc-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/lua-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/redis2-nginx-module" \
  --add-module="$BUILD_TEMP_DIR/ngx_http_substitutions_filter_module" \
  --add-module="$BUILD_TEMP_DIR/nginx_tcp_proxy_module"

make && make install



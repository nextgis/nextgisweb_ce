# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
FROM ubuntu:24.04
ENV LC_ALL=C.UTF-8

RUN set -ex; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get --yes -qq install --no-install-recommends  \
        ca-certificates curl git gnupg nano openssh-client software-properties-common tini xz-utils; \
    rm -rf /var/lib/apt/lists/*

ARG CA_CERT=/etc/ssl/certs/ca-certificates.crt

RUN set -ex; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get --yes -qq install --no-install-recommends  \
        build-essential libssl-dev cmake pkg-config python3 python3-dev python3-virtualenv python3-pip; \
    ( : ; \
       cd /tmp; \
       curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.2.0/s6-overlay-noarch.tar.xz > s6-overlay-noarch.tar.xz; \
       curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.2.0/s6-overlay-x86_64.tar.xz > s6-overlay-x86_64.tar.xz; \
       tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
       tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
       rm /package/admin/s6-overlay-*/etc/s6-rc/sources/base/contents.d/legacy-cont-init; \
       rm /package/admin/s6-overlay-*/etc/s6-rc/sources/top/contents.d/legacy-services; \
       rm /package/admin/s6-overlay-*/etc/s6-rc/sources/base/contents.d/fix-attrs; \
       rm /tmp/s6-overlay-*.tar.xz; \
    ); \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    export DEBIAN_FRONTEND=noninteractive; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/1.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/1.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/1.list; \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/2.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/2.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/2.list; \
    ( : ; \
        cd /tmp; \
        curl -sSL https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.0.5.tar.gz > zlib-ng-2.0.5.tar.gz; \
        tar -zxf zlib-ng-2.0.5.tar.gz && rm zlib-ng-2.0.5.tar.gz; \
        mv zlib-ng-2.0.5 zlib-ng && cd zlib-ng; \
        ./configure --zlib-compat; \
        make && make install prefix=/opt/zlib-ng; \
        echo '/opt/zlib-ng/lib/libz.so' >> /etc/ld.so.preload; \
        rm -rf /tmp/zlib-ng; \
    ); \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/3.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/3.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/3.list; \
    apt-get update; \
    apt-get --yes -qq install --no-install-recommends  \
        nodejs yarn libgdal-dev libgeos-dev gdal-bin g++ libxml2-dev libxslt1-dev zlib1g-dev libjpeg-turbo8-dev postgresql-client libmagic-dev fonts-liberation fonts-dejavu postgresql-common locales; \
    sed -ri "s/#(create_main_cluster) .*$/\1 = false/" /etc/postgresql-common/createcluster.conf; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    add-apt-repository --yes --no-update "ppa:savoury1/ffmpeg4"; \
    add-apt-repository --yes --no-update "ppa:savoury1/chromium"; \
    curl -fsSL https://download.qgis.org/downloads/qgis-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/4.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/4.gpg] https://qgis.org/ubuntu-ltr $(lsb_release -sc) main" > /etc/apt/sources.list.d/4.list; \
    apt-get update; \
    apt-get --yes -qq install --no-install-recommends  \
        "^postgresql-(12)$" "^postgresql-(12)-postgis-(3)$" "^postgresql-(12)-postgis-(3)-scripts$" libpcre3 libpcre3-dev gettext chromium-browser ghostscript libqgis-dev qgis-providers-common build-essential cmake qt5-image-formats-plugins cmake swig libfreetype6-dev libgeos-dev libproj-dev; \
    rm -rf /var/lib/apt/lists/*; \
    curl -sSL https://github.com/jackhftang/tusc/releases/download/0.4.7/tusc_linux_amd64 > /usr/local/bin/tusc; chmod +x /usr/local/bin/tusc; \
    userdel postgres

ENV CRATER_USER=crater
ENV CRATER_ROOT=/opt/crater
ENV CRATER_DATA_DIR=/opt/crater/data
ENV CRATER_CONFIG_DIR=/opt/crater/data/config
ENV CRATER_SECRET_DIR=/opt/crater/data/secret
ENV CRATER_BACKUP_DIR=/opt/crater/backup
ENV NGWUSER=crater
ENV NGWROOT=/opt/crater

RUN set -ex; \
    getent passwd 1000 && userdel -r $(getent passwd 1000 | cut -d: -f1); \
    groupadd -g 1000 $CRATER_USER; \
    useradd -d $CRATER_ROOT -u 1000 -g $CRATER_USER $CRATER_USER; \
    mkdir -p $CRATER_ROOT $CRATER_DATA_DIR $CRATER_CONFIG_DIR $CRATER_SECRET_DIR $CRATER_BACKUP_DIR $CRATER_ROOT/bin $CRATER_ROOT/libexec $CRATER_ROOT/libexec/entry-point.d $CRATER_ROOT/libexec/entry-server.d $CRATER_ROOT/libexec/entry-uwsgi.d $CRATER_ROOT/run $CRATER_ROOT/run/uwsgi $CRATER_ROOT/build $CRATER_ROOT/build/font $CRATER_ROOT/backup $CRATER_ROOT/package $CRATER_ROOT/data $CRATER_ROOT/data/app $CRATER_ROOT/config $CRATER_ROOT/config/app $CRATER_ROOT/dist $CRATER_ROOT/node_modules $CRATER_ROOT/data $CRATER_ROOT/data/postgres $CRATER_ROOT/config $CRATER_ROOT/config/postgres $CRATER_ROOT/secret; \
    chown -R $CRATER_USER:$CRATER_USER /etc/s6-overlay; \
    chown -R $CRATER_USER:$CRATER_USER /var/run/postgresql /var/lib/postgresql; \
    ln -s $CRATER_ROOT/data/postgres /var/lib/postgresql/data; \
    chown -R $CRATER_USER:$CRATER_USER $CRATER_ROOT

WORKDIR $CRATER_ROOT
USER $CRATER_USER

COPY --chown=$CRATER_USER:$CRATER_USER package $CRATER_ROOT/package

RUN set -ex; \
    export PIP_USE_PEP517=1 PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1; \
    DEB_PYTHON_INSTALL_LAYOUT="deb" /usr/bin/virtualenv -p /usr/bin/python3 --activators bash $CRATER_ROOT/env; \
    $CRATER_ROOT/env/bin/pip install --no-cache-dir setuptools packaging; \
    gdal_numpy_spec=$(cd package/nextgisweb; $CRATER_ROOT/env/bin/python setup.py gdal_numpy_spec); \
    $CRATER_ROOT/env/bin/pip install --no-cache-dir "$(echo $gdal_numpy_spec | cut -d ' ' -f 2)"; \
    $CRATER_ROOT/env/bin/pip install --no-cache-dir --no-build-isolation "$(echo $gdal_numpy_spec | cut -d ' ' -f 1)"; \
    $CRATER_ROOT/env/bin/pip install --no-cache-dir package/nextgisweb_qgis/qgis_headless; \
    ( : ; \
        cd /tmp; \
        curl -sSL https://download.osgeo.org/mapserver/mapserver-8.4.0.tar.gz > mapserver-8.4.0.tar.gz; \
        tar -zxf mapserver-8.4.0.tar.gz && rm mapserver-8.4.0.tar.gz; \
        mv mapserver-8.4.0 mapserver && cd mapserver; \
        mkdir build && cd build; \
        cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DLINK_STATIC_LIBMAPSERVER=ON -DWITH_PROTOBUFC=OFF -DWITH_FRIBIDI=OFF -DWITH_HARFBUZZ=OFF -DWITH_CAIRO=OFF -DWITH_FCGI=OFF -DWITH_POSTGIS=OFF -DWITH_WFS=OFF -DWITH_WCS=OFF -DWITH_LIBXML2=OFF -DWITH_PYTHON=ON ../ > ../configure.out.txt && make; \
        $CRATER_ROOT/env/bin/pip install --no-cache-dir src/mapscript/python; \
        rm -rf /tmp/mapserver; \
    ); \
    mkdir /tmp/uwsgi /tmp/uwsgi/src; \
    $CRATER_ROOT/env/bin/pip download uwsgi -d /tmp/uwsgi; \
    tar xfvz /tmp/uwsgi/uwsgi-*.tar.gz -C /tmp/uwsgi/src --strip-components 1; \
    sed "s/embedded_plugins = .*/embedded_plugins = cache,cheaper_busyness,corerouter,http,logfile,ping,python,rawrouter,router_basicauth,router_cache,router_expires,router_hash,router_http,router_metrics,router_redirect,router_rewrite,router_static,router_uwsgi,rpc,signal,spooler,symcall,transformation_chunked,transformation_gzip,transformation_offload,transformation_template,transformation_tofile/" /tmp/uwsgi/src/buildconf/base.ini > /tmp/uwsgi/src/buildconf/default.ini; \
    $CRATER_ROOT/env/bin/pip install  \
        --editable $CRATER_ROOT/package/nextgisweb \
        --editable $CRATER_ROOT/package/nextgisweb_qgis \
        --editable $CRATER_ROOT/package/nextgisweb_mapserver \
        /tmp/uwsgi/src \
        uwsgitop; \
    SITE=$($CRATER_ROOT/env/bin/python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])'); \
    export NEXTGISWEB__CORE__LOCALE__EXTERNAL_PATH=${CRATER_ROOT}/package/nextgisweb_i18n; \
    $CRATER_ROOT/env/bin/nextgisweb-i18n --all-packages compile; \
    ln -s $CRATER_ROOT/env/bin/nextgisweb $CRATER_ROOT/env/bin/nextgisweb-config $CRATER_ROOT/env/bin/uwsgi $CRATER_ROOT/bin/; \
    SA_CONCURRENCY=$($CRATER_ROOT/env/bin/python -c "import sqlalchemy.util.concurrency as m; print(m.__file__)"); \
    sed -i "s/^\(\s\+\)import greenlet/\1raise ImportError/" $SA_CONCURRENCY; \
    NEXTGISWEB__ENVIRONMENT__ENABLE_OPTIONAL_COMPONENTS=YES env/bin/nextgisweb jsrealm install --build; \
    rm -rf node_modules .cache/yarn; \
    ln -s package/nextgisweb/.prettierrc.cjs $CRATER_ROOT/; \
    ln -s package/nextgisweb/eslint.config.cjs $CRATER_ROOT/; \
    rm -rf /tmp/uwsgi

COPY --chown=$CRATER_USER:$CRATER_USER user $CRATER_ROOT

RUN set -ex; \
    sed -i -E "s/^static_key = .*/static_key = $(openssl rand -hex 4)/" $CRATER_ROOT/build/config/app/config.ini

COPY s6-overlay /etc/s6-overlay

ARG CRATER_DISTRIBUTION_VERSION=0
ARG CRATER_DISTRIBUTION_DATE

ENV CRATER_DISTRIBUTION_VERSION=$CRATER_DISTRIBUTION_VERSION
ENV CRATER_DISTRIBUTION_DATE=$CRATER_DISTRIBUTION_DATE

VOLUME ["$CRATER_DATA_DIR", "$CRATER_BACKUP_DIR"]

EXPOSE 8080
ENTRYPOINT ["/opt/crater/bin/docker-entrypoint"]

CMD ["/bin/bash"]

ENV SSL_CERT_FILE="$CA_CERT"
ENV CURL_CA_BUNDLE="$CA_CERT"
ENV NGWDOCKER_POSTGRES_DATABASES="nextgisweb"
ENV PATH="$CRATER_ROOT/entry:$PATH"
ENV NGWDOCKER_PACKAGES="nextgisweb nextgisweb_qgis nextgisweb_mapserver"
ENV NGWDOCKER_DEFAULT_INSTANCE="yes"
ENV NGWDOCKER_WAIT_FOR_SERVICE="yes"
ENV NGWDOCKER_INITIALIZE_DB="yes"
ENV NEXTGISWEB_CONFIG="$CRATER_ROOT/build/config/app/config.ini:$CRATER_CONFIG_DIR/app/config.ini"
ENV NGWDOCKER_MIGRATION_UPGRADE="1"
ENV NO_PROXY="app"

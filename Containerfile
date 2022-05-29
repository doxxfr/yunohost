

FROM python:3.9-bullseye as deps

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NOWARNINGS="yes"
RUN set -x \
&& sed -Ei 's|^(DPkg::Pre-Install-Pkgs .*)|#\1|g' /etc/apt/apt.conf.d/70debconf \
&& apt-get update \
&& apt-get upgrade -y

# RUN python3 -c "import sys;print(sys.path)"

ENV PYTHONPATH_PREFIX /usr/local/lib/python3.9/
ARG PYTHONPATH_PREFIX /usr/local/lib/python3.9/
# ENV PYTHONPATH '/usr/local/lib/python39.zip':'/usr/local/lib/python3.9':'/usr/local/lib/python3.9/lib-dynload':'/usr/local/lib/python3.9/site-packages'

# disabled:
# resolvconf
# unscd

# TODO: sortir la stack ldap/metronome? la stack mail?
run apt-get update && apt-get install -q --yes \
    apt apt-transport-https apt-utils dirmngr \
    openssh-server iptables fail2ban bind9-dnsutils \
    openssl ca-certificates netcat-openbsd iproute2 \
    nginx nginx-extras \
    slapd ldap-utils sudo-ldap libnss-ldapd libpam-ldapd \
    dnsmasq  libnss-myhostname \
    postfix postfix-ldap postfix-policyd-spf-perl postfix-pcre \
    dovecot-core dovecot-ldap dovecot-lmtpd dovecot-managesieved dovecot-antispam \
    rspamd opendkim-tools postsrsd procmail mailutils \
    redis-server \
    acl \
    git curl wget cron unzip jq bc at \
    lsb-release haveged fake-hwclock equivs lsof whois

run apt-get install -q --yes  \
    python3-psutil python3-requests python3-dnspython python3-openssl \
    python3-miniupnpc python3-dbus python3-jinja2 \
    python3-toml python3-packaging python3-publicsuffix2 \
    python3-ldap 'python3-zeroconf' python3-lexicon \
    python-is-python3
# run pip install -r requirements.txt

# Recommends: yunohost-admin
#   ntp inetutils-ping | iputils-ping
#   bash-completion rsyslog
#   php7.4-common php7.4-fpm php7.4-ldap php7.4-intl
#   mariadb-server php7.4-mysql
#   php7.4-gd php7.4-curl php-php-gettext
#   python3-pip
#   unattended-upgrades
#   libdbd-ldap-perl libnet-dns-perl
#   metronome (>=3.14.0)
# Conflicts: iptables-persistent
#   apache2
#   bind9
#   nginx-extras (>= 1.19)
#   openssl (>= 1.1.1o-0)
#   slapd (>= 2.4.58)
#   dovecot-core (>= 1:2.3.14)
#   redis-server (>= 5:6.1)
#   fail2ban (>= 0.11.3)
#  iptables (>= 1.8.8)


# add "bin/yunohost" "/usr/bin/yunohost"
# add "bin/yunohost-api" "/usr/bin/yunohost-api"

# data
# TODO:
# add "data/bash-completion.d/yunohost" "/etc/bash_completion.d/yunohost"


# FROM deps as yunohost-build

# add ./ /build/yunohost
# RUN chmod -R 755 /build/yunohost
# WORKDIR /build/yunohost/
# RUN make
# WORKDIR /yunohost/debian
# RUN make
# .build-stage:
#   stage: build
#   image: "before-install"
#   variables:
#     YNH_SOURCE: "https://github.com/yunohost"
#   before_script:
#     - mkdir -p $YNH_BUILD_DIR
#     - DEBIAN_FRONTEND=noninteractive apt update
#   artifacts:
#     paths:
#       - $YNH_BUILD_DIR/*.deb

#     - rm archive.tar.gz
# run DEBIAN_FRONTEND=noninteractive apt --assume-yes -o Dpkg::Options::="--force-confold" install devscripts --no-install-recommends
# run dch --package "yunohost" --newversion --force-bad-version -v "${VERSION_NIGHTLY}" -D "unstable" --force-distribution "Docker build."
# run dch --package "yunohost" --newversion --force-bad-version -v "${VERSION_NIGHTLY}" -D "unstable" --force-distribution "Docker build."
#  run debuild --no-lintian -us -uc

# ########################################
# # BUILD DEB
# ########################################

# build-yunohost:
#   extends: .build-stage
#   variables:
#     PACKAGE: "yunohost"
#   script:
#     - git ls-files | xargs tar -czf archive.tar.gz
#     - mkdir -p $YNH_BUILD_DIR/$PACKAGE
#     - cat archive.tar.gz | tar -xz -C $YNH_BUILD_DIR/$PACKAGE
#     - rm archive.tar.gz
#     - DEBIAN_FRONTEND=noninteractive apt --assume-yes -o Dpkg::Options::="--force-confold" build-dep $(pwd)/$YNH_BUILD_DIR/$PACKAGE
#     - *build_script


# build-ssowat:
#   extends: .build-stage
#   variables:
#     PACKAGE: "ssowat"
#   script:
#     - DEBIAN_DEPENDS=$(cat debian/control | tr "," "\n" | grep -Po "ssowat \([>,=,<]+ .*\)" | grep -Po "[0-9\.]+")
#     - git clone $YNH_SOURCE/$PACKAGE -b $CI_COMMIT_REF_NAME $YNH_BUILD_DIR/$PACKAGE --depth 1 || git clone $YNH_SOURCE/$PACKAGE -b $DEBIAN_DEPENDS $YNH_BUILD_DIR/$PACKAGE --depth 1 || git clone $YNH_SOURCE/$PACKAGE $YNH_BUILD_DIR/$PACKAGE --depth 1
#     - DEBIAN_FRONTEND=noninteractive apt --assume-yes -o Dpkg::Options::="--force-confold" build-dep $(pwd)/$YNH_BUILD_DIR/$PACKAGE
#     - *build_script

# build-moulinette:
#   extends: .build-stage
#   variables:
#     PACKAGE: "moulinette"
#   script:
#     - DEBIAN_DEPENDS=$(cat debian/control | tr "," "\n" | grep -Po "moulinette \([>,=,<]+ .*\)" | grep -Po "[0-9\.]+")
#     - git clone $YNH_SOURCE/$PACKAGE -b $CI_COMMIT_REF_NAME $YNH_BUILD_DIR/$PACKAGE --depth 1 || git clone $YNH_SOURCE/$PACKAGE -b $DEBIAN_DEPENDS $YNH_BUILD_DIR/$PACKAGE --depth 1 || git clone $YNH_SOURCE/$PACKAGE $YNH_BUILD_DIR/$PACKAGE --depth 1
#     - DEBIAN_FRONTEND=noninteractive apt --assume-yes -o Dpkg::Options::="--force-confold" build-dep $(pwd)/$YNH_BUILD_DIR/$PACKAGE
#     - *build_script

#RUN dpkg-deb -b /yunohost/debian /yunohost/yunohost.deb
#RUN dpkg -i /yunohost.deb
# RUN  python -m pip install /usr/lib/python3/dist-packages/yunohost






FROM deps AS base
# FROM debian AS base



add bin/* /usr/bin/
# add "bin/yunohost" "/usr/bin/yunohost"
add share/* /usr/share/yunohost/
add hooks/* /usr/share/yunohost/hooks/
add helpers/* /usr/share/yunohost/helpers.d/
add conf/* /usr/share/yunohost/conf/

# locales
add locales/* /usr/share/yunohost/locales/
add "locales" "/usr/lib/yunohost/yunohost/locales"


# metronome
# FIXME: On met keycloak à la place
# add conf/metronome/modules/* /usr/lib/metronome/modules/
# add "conf/metronome/modules/ldap.lib.lua" "/usr/lib/metronome/modules/ldap.lib.lua"
# add "conf/metronome/modules/mod_auth_ldap2.lua" "/usr/lib/metronome/modules/mod_auth_ldap2.lua"
# add "conf/metronome/modules/mod_legacyauth.lua" "/usr/lib/metronome/modules/mod_legacyauth.lua"
# add "conf/metronome/modules/mod_storage_ldap.lua" "/usr/lib/metronome/modules/mod_storage_ldap.lua"
# add "conf/metronome/modules/vcard.lib.lua" "/usr/lib/metronome/modules/vcard.lib.lua"

# debian python3

#add --from=debian "debian/conf/pam/mkhomedir" "/usr/share/pam-configs/mkhomedir"


# src
# RUN python3 -c "import sys;print(sys.path)"
# ENV PYTHONPATH"import sys;print(sys.path)"
# add "src/" "/usr/lib/yunohost/yunohost/"
add src/ ${PYTHONPATH_PREFIX}/yunohost/


# Autre image Docker? FIXME: remplacer par Keycloak
# add "submodules/ssowat" "/usr/share/ssowat"

# moulinette

# TODO: image moulinette?
RUN apt-get install  -q --yes \
python3-yaml \
python3-bottle \
python3-gevent-websocket \
python3-toml \
python3-psutil \
python3-tz \
python3-prompt-toolkit \
python3-pygments

add "share/actionsmap.yml" "/usr/share/moulinette/actionsmap/yunohost.yml"
# add "data/templates" "/usr/share/yunohost/templates"
# add "data/other" "/usr/share/yunohost/yunohost-config/moulinette"


add "submodules/moulinette/locales" "/usr/share/moulinette/locales"
# add "submodules/moulinette/moulinette" "/usr/lib/python2.7/dist-packages/moulinette"
add "submodules/moulinette/moulinette" "${PYTHONPATH_PREFIX}/moulinette"
# add "submodules/moulinette/moulinette" "/usr/local/lib/python3.9/moulinette"

# TODO: Autre image Docker
# add "submodules/yunohost-admin/" "/usr/share/yunohost/admin"


FROM base AS doc

run python3 -m pip install pyyaml jinja2
add "share/actionsmap.yml" "/usr/share/moulinette/actionsmap/yunohost.yml"
add "share/actionsmap.yml" "/usr/share/actionsmap.yml"
copy doc/ /doc/
run python3 /doc/generate_bash_completion.py
run python3 /doc/generate_manpages.py --gzip --output doc/yunohost.8.gz
# yunohost:doc

FROM base as bootstrap
COPY --from=doc doc/yunohost.8.gz /usr/share/man/man8/
COPY --from=doc doc/bash_completion.d/* /etc/bash_completion.d/
add ./bootstrap.sh "/bootstrap.sh"

run bash /bootstrap.sh

#  yunohost:base
FROM bootstrap as dev
# yunohost:dev
 
WORKDIR /
ENV YNH_ROOT_DOMAIN=ynh.localhost

RUN /usr/bin/yunohost tools postinstall -d ynh.localhost -p --ignore-dyndns --force-diskspace

# RUN bash yunohost tools postinstall -d ${YNH_ROOT_DOMAIN} -p --ignore-dyndns --force-diskspace

# RUN useradd --shell /bin/bash -G sudo \root admin
# USER admin

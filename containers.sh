#!/usr/bin/make -f
# -*- makefile -*-

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

# Get package version
# dpkg-parsechangelog > 1.17 could use dpkg-parsechangelog --show-field Version
DEBVERS := $(shell dpkg-parsechangelog | sed -n -e 's/^Version: //p')

# Define temporary debian directory
TMPDIR = $$(pwd)/debian/yunohost-admin

%:
	dh  $@

override_dh_auto_build:
	/usr/bin/npm install -g npm@6
	cd app ; PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/npm --progress false ci
	cd app ; PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/npm run build


override_dh_clean:
	dh_clean
	rm -rf app/node_modules
	rm -rf app/dist

---

#!/usr/bin/make -f
# -*- makefile -*-

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

# Get package version
# dpkg-parsechangelog > 1.17 could use dpkg-parsechangelog --show-field Version
DEBVERS := $(shell dpkg-parsechangelog | sed -n -e 's/^Version: //p')

# Define temporary debian directory
TMPDIR = $$(pwd)/debian/yunohost-admin

%:
	dh  $@

override_dh_auto_build:
	/usr/bin/npm install -g npm@6
	cd app ; PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/npm --progress false ci
	cd app ; PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/npm run build


override_dh_clean:
	dh_clean
	rm -rf app/node_modules
	rm -rf app/dist

app/dist/* usr/share/yunohost/admin


#!/bin/bash

set -e

do_configure() {

  # Set document root permissions
  chown -R root:root /usr/share/yunohost/admin
}

# summary of how this script can be called:
#        * <postinst> `configure' <most-recently-configured-version>
#        * <old-postinst> `abort-upgrade' <new version>
#        * <conflictor's-postinst> `abort-remove' `in-favour' <package>
#          <new-version>
#        * <deconfigured's-postinst> `abort-deconfigure' `in-favour'
#          <failed-install-package> <version> `removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

case "$1" in
    configure)
        do_configure
    ;;
    abort-upgrade|abort-remove|abort-deconfigure)
    ;;
    *)
        echo "postinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

#DEBHELPER#

exit 0

usr/lib/moulinette
usr/share/moulinette/actionsmap
#!/usr/bin/make -f

export PYBUILD_NAME=moulinette

%:
	dh $@ --with python3 --buildsystem=pybuild

---
#!/usr/bin/make -f
# -*- makefile -*-

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

%:
	dh  $@

#!/bin/bash

yunohost app ssowatconf > /dev/null 2>&1
service nginx restart > /dev/null 2>&1
exit 0

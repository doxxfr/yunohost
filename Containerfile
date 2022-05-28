
FROM python:3.9-bullseye
add bootstrap.sh "/bootstrap.sh"
CMD chmod +x"/bootstrap.sh"

# Autre image Docker
add "submodules/ssowat" "/usr/share/ssowat"

# TODO: Autre image Docker
add "submodules/moulinette/locales" "/usr/share/moulinette/locale"
add "submodules/moulinette/moulinette" "/usr/lib/python2.7/dist-packages/moulinette"

# TODO: Autre image Docker
# add "submodules/yunohost-admin/" "/usr/share/yunohost/admin"






add "bin/yunohost" "/usr/bin/yunohost"
add "bin/yunohost-api" "/usr/bin/yunohost-api"



                # data
# TODO:
# add "data/bash-completion.d/yunohost" "/etc/bash_completion.d/yunohost"

add bin/* /usr/bin/
add share/* /usr/share/yunohost/
add hooks/* /usr/share/yunohost/hooks/
add helpers/* /usr/share/yunohost/helpers.d/
add conf/* /usr/share/yunohost/conf/
add locales/* /usr/share/yunohost/locales/


run python3 doc/generate_bash_completion.py
run python3 doc/generate_manpages.py --gzip --output doc/yunohost.8.gz

add doc/yunohost.8.gz /usr/share/man/man8/
add doc/bash_completion.d/* /etc/bash_completion.d/

add conf/metronome/modules/* /usr/lib/metronome/modules/
add src/* /usr/lib/python3/dist-packages/yunohost/




add "share/actionsmap/yunohost.yml" "/usr/share/moulinette/actionsmap/yunohost.yml"
add "data/hooks" "/usr/share/yunohost/hooks"
add "data/templates" "/usr/share/yunohost/templates"
add "data/helpers" "/usr/share/yunohost/helpers"
add "data/helpers.d" "/usr/share/yunohost/helpers.d"
add "data/other" "/usr/share/yunohost/yunohost-config/moulinette"

                # debian
add "debian/conf/pam/mkhomedir" "/usr/share/pam-configs/mkhomedir"


                # lib
add "conf/metronome/modules/ldap.lib.lua" "/usr/lib/metronome/modules/ldap.lib.lua"
add "conf/metronome/modules/mod_auth_ldap2.lua" "/usr/lib/metronome/modules/mod_auth_ldap2.lua"
add "conf/metronome/modules/mod_legacyauth.lua" "/usr/lib/metronome/modules/mod_legacyauth.lua"
add "conf/metronome/modules/mod_storage_ldap.lua" "/usr/lib/metronome/modules/mod_storage_ldap.lua"
add "conf/metronome/modules/vcard.lib.lua" "/usr/lib/metronome/modules/vcard.lib.lua"

                # src
add "src/" "/usr/lib/moulinette/yunohost"

                # locales
add "locales" "/usr/lib/moulinette/yunohost/locales"

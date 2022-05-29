#!/bin/bash

function show_usage() {
    cat <<EOF

  ${BLUE}On the host, to manage the LXC${NORMAL}
  ${BLUE}==============================${NORMAL}

  start [NAME]    (Create and) starts a LXC (ynh-dev by default)
  attach [NAME]   Attach an already started LXC (ynh-dev by default)
  destroy [NAME]  Destroy the ynh-dev LXC (ynh-dev by default)
  rebuild         Rebuild a fresh, up-to-date box

  ${BLUE}Inside the dev instance${NORMAL}
  ${BLUE}=======================${NORMAL}

  ip              Give the ip of the guest container
  use-git [PKG]   Use Git repositories from dev environment path
  test [PKG]      Deploy, update and run tests for some packages
                  Tests for single modules and functions can ran with
                  e.g. ./ynh-dev test yunohost/appurl:urlavailable

EOF
}

function main()
{
    local ACTION="$1"
    local ARGUMENTS="${@:2}"

    [ -z "$ACTION" ] && show_usage && exit 0

    case "${ACTION}" in

        help|-h|--help)            show_usage     $ARGUMENTS ;;

        start|--start)             start_ynhdev   $ARGUMENTS ;;
        attach|--attach)           attach_ynhdev  $ARGUMENTS ;;
        destroy|--destroy)         destroy_ynhdev $ARGUMENTS ;;
        rebuild|--rebuild)         rebuild_ynhdev $ARGUMENTS ;;

        # ip|--ip)                   show_vm_ip     $ARGUMENTS ;;
        use-git|--use-git)         use_git        $ARGUMENTS ;;
        test|--test)               run_tests      $ARGUMENTS ;;

        *)              critical "Unknown action ${ACTION}." ;;
    esac
}

##################################################################
#               Misc helpers                                     #
##################################################################

readonly NORMAL=$(printf '\033[0m')
readonly BOLD=$(printf '\033[1m')
readonly faint=$(printf '\033[2m')
readonly UNDERLINE=$(printf '\033[4m')
readonly NEGATIVE=$(printf '\033[7m')
readonly RED=$(printf '\033[31m')
readonly GREEN=$(printf '\033[32m')
readonly ORANGE=$(printf '\033[33m')
readonly BLUE=$(printf '\033[34m')
readonly YELLOW=$(printf '\033[93m')
readonly WHITE=$(printf '\033[39m')

function success()
{
  local msg=${1}
  echo "[${BOLD}${GREEN} OK ${NORMAL}] ${msg}"
}

function info()
{
  local msg=${1}
  echo "[${BOLD}${BLUE}INFO${NORMAL}] ${msg}"
}

function warn()
{
  local msg=${1}
  echo "[${BOLD}${ORANGE}WARN${NORMAL}] ${msg}" 2>&1
}

function error()
{
  local msg=${1}
  echo "[${BOLD}${RED}FAIL${NORMAL}] ${msg}"  2>&1
}

function critical()
{
  local msg=${1}
  echo "[${BOLD}${RED}CRIT${NORMAL}] ${msg}"  2>&1
  exit 1
}

function assert_inside_vm() {
    [ -d /etc/yunohost ] || critical "There's no YunoHost in there. Are you sure that you are inside the container ?"
}

function create_sym_link() {
    local DEST=$1
    local LINK=$2
    # Remove current sources if not a symlink
    [ -L "$LINK" ] || sudo rm -rf $LINK
    # Symlink from Git repository
    sudo ln -sfn $DEST $LINK
}

##################################################################
#               Actions                                          #
##################################################################

function check_lxd_setup()
{
    local LXD_VERSION=$(lxc --version)

    [[ -n "$LXD_VERSION" ]] \
        || critical "You need to have LXD install for ynh-dev to be usable from the host machine. From a debian-like system, you can install it with 'apt install snap' then 'snap install lxd'. (Don't forget to add /snap/bin to your \$PATH somehow. Then you can run 'lxd init' (keeping all the default option is usally okay!)"

    # ip a | grep -q lxdbr0 \
    #     || critical "There is no 'lxdbr0' interface... Did you ran 'lxd init' ?"
}

function start_ynhdev()
{
    check_lxd_setup

    local BOX=${1:-ynh-dev}

    sudo lxc info $BOX &>/dev/null && critical "The container already exist. Use 'attach' to enter the LXC, or 'destroy' if you aim to recreate it."
    sudo lxc image info $BOX-base &>/dev/null || critical "You should first build the base YunoHost LXC using ./ynh-dev rebuild"
    set -eu
    set -x
    sudo lxc launch $BOX-base $BOX
    # Does not work on macOS
    # sudo lxc config device add $BOX ynhdev-shared-folder disk path=/ynh-dev source="$PWD"
    set +x

    attach_ynhdev $BOX
}

function attach_ynhdev()
{
    check_lxd_setup
    local BOX=${1:-ynh-dev}
    sudo lxc start $BOX 2>/dev/null || true
    sudo lxc exec $BOX -- /bin/bash
}

function destroy_ynhdev()
{
    check_lxd_setup
    local BOX=${1:-ynh-dev}
    sudo lxc stop $BOX
    sudo lxc delete $BOX
}

function rebuild_ynhdev()
{
    check_lxd_setup

    local BOX=${1:-ynh-dev}

    set -x
    sudo lxc info $BOX-rebuild >/dev/null && sudo lxc delete $BOX-rebuild --force
    sudo lxc launch images:debian/stretch/amd64 $BOX-rebuild
    sudo lxc config set $BOX-rebuild security.privileged true
    sudo lxc restart $BOX-rebuild
    sudo lxc exec $BOX-rebuild -- apt install curl -y
    sudo lxc exec $BOX-rebuild -- /bin/bash -c "curl https://install.yunohost.org | bash -s -- -a -d unstable"
    sudo lxc stop $BOX-rebuild
    sudo lxc publish $BOX-rebuild --alias $BOX-base
    set +x
}

# function show_vm_ip()
# {
#     assert_inside_vm
#     hostname --all-ip-addresses | tr ' ' '\n'
# }

function use_git()
{
    # assert_inside_vm
    local PACKAGES="$@"
    for PACKAGE in "$PACKAGES";
    do
        case $PACKAGE in
            ssowat)
                create_sym_link "/ynh-dev/ssowat" "/usr/share/ssowat"
                success "Now using Git repository for SSOwat"
                ;;
            moulinette)
                create_sym_link "/ynh-dev/moulinette/locales" "/usr/share/moulinette/locale"
                create_sym_link "/ynh-dev/moulinette/moulinette" "/usr/lib/python2.7/dist-packages/moulinette"
                success "Now using Git repository for Moulinette"
                ;;
            yunohost)

                # bin
                create_sym_link "/ynh-dev/yunohost/bin/yunohost" "/usr/bin/yunohost"
                create_sym_link "/ynh-dev/yunohost/bin/yunohost-api" "/usr/bin/yunohost-api"

                # data
                create_sym_link "/ynh-dev/yunohost/data/bash-completion.d/yunohost" "/etc/bash_completion.d/yunohost"
                create_sym_link "/ynh-dev/yunohost/data/actionsmap/yunohost.yml" "/usr/share/moulinette/actionsmap/yunohost.yml"
                create_sym_link "/ynh-dev/yunohost/data/hooks" "/usr/share/yunohost/hooks"
                create_sym_link "/ynh-dev/yunohost/data/templates" "/usr/share/yunohost/templates"
                create_sym_link "/ynh-dev/yunohost/data/helpers" "/usr/share/yunohost/helpers"
                create_sym_link "/ynh-dev/yunohost/data/helpers.d" "/usr/share/yunohost/helpers.d"
                create_sym_link "/ynh-dev/yunohost/data/other" "/usr/share/yunohost/yunohost-config/moulinette"

                # debian
                # create_sym_link "/ynh-dev/yunohost/debian/conf/pam/mkhomedir" "/usr/share/pam-configs/mkhomedir"

                # lib
                create_sym_link "/ynh-dev/yunohost/lib/metronome/modules/ldap.lib.lua" "/usr/lib/metronome/modules/ldap.lib.lua"
                create_sym_link "/ynh-dev/yunohost/lib/metronome/modules/mod_auth_ldap2.lua" "/usr/lib/metronome/modules/mod_auth_ldap2.lua"
                create_sym_link "/ynh-dev/yunohost/lib/metronome/modules/mod_legacyauth.lua" "/usr/lib/metronome/modules/mod_legacyauth.lua"
                create_sym_link "/ynh-dev/yunohost/lib/metronome/modules/mod_storage_ldap.lua" "/usr/lib/metronome/modules/mod_storage_ldap.lua"
                create_sym_link "/ynh-dev/yunohost/lib/metronome/modules/vcard.lib.lua" "/usr/lib/metronome/modules/vcard.lib.lua"

                # src
                create_sym_link "/ynh-dev/yunohost/src/yunohost" "/usr/lib/moulinette/yunohost"

                # locales
                create_sym_link "/ynh-dev/yunohost/locales" "/usr/lib/moulinette/yunohost/locales"

                success "Now using Git repository for YunoHost"

                ;;
            yunohost-admin)

                # getent passwd ynhdev > /dev/null
                # if [ $? -eq 2 ]; then
                #     useradd ynhdev
                #     chown -R ynhdev: /ynh-dev/yunohost-admin
                # fi

                # Install npm dependencies if needed
                # which gulp > /dev/null
                # if [ $? -eq 1 ]
                # then
                #     info "Installing dependencies to develop in yunohost-admin ..."

                #     curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
                #     sudo apt install nodejs

                #     cd /ynh-dev/yunohost-admin/src
                #     sudo npm install --no-bin-links
                #     sudo npm install -g bower
                #     sudo npm install -g gulp
                # fi
                # cd /ynh-dev/yunohost-admin/src
                # sudo su -c "bower install" ynhdev
                # sudo su -c "gulp build --dev" ynhdev

                # create_sym_link "/ynh-dev/yunohost-admin/src" "/usr/share/yunohost/admin"

                # success "Now using Git repository for yunohost-admin"

                # warn "-------------------------------------------------------- "
                # warn "Launching gulp ...                                       "
                # warn "NB : This command will keep running and watch for changes"
                # warn " in the folder /ynh-dev/yunohost-admin/src, such that you"
                # warn "don't need to re-run npm yourself everytime you change   "
                # warn "something !                                              "
                # warn "-------------------------------------------------------- "
                # sudo su -c "gulp watch --dev" ynhdev

                ;;
        esac
    done
}

function run_tests()
{
    assert_inside_vm
    local PACKAGES="$@"
    for PACKAGE in "$PACKAGES";
    do
        TEST_FUNCTION=$(echo "$PACKAGE" | tr '/:' ' ' | awk '{print $3}')
        TEST_MODULE=$(echo "$PACKAGE" | tr '/:' ' ' | awk '{print $2}')
        PACKAGE=$(echo "$PACKAGE" | tr '/:' ' ' | awk '{print $1}')

        case $PACKAGE in
            yunohost)
                # Pytest and tests dependencies
                if ! type "pytest" > /dev/null 2>&1; then
                    info "> Installing pytest ..."
                    apt-get install python-pip -y
                    pip2 install pytest pytest-sugar
                fi
                for DEP in "pytest-mock requests-mock mock"
                do
                    if [ -z "$(pip show $DEP)" ]; then
                        info "Installing $DEP with pip"
                        pip2 install $DEP
                    fi
                done

                # Apps for test
                cd /ynh-dev/yunohost/src/yunohost/tests
                [ -d "apps" ] || git clone https://github.com/YunoHost/test_apps ./apps
                cd apps
                git pull > /dev/null 2>&1

                # Run tests
                info "Running tests for YunoHost"
                [ -e "/etc/yunohost/installed" ] || critical "You should run postinstallation before running tests :s."
                if [[ -z "$TEST_MODULE" ]]
                then
                    cd /ynh-dev/yunohost/
                    py.test tests
                    cd /ynh-dev/yunohost/src/yunohost
                    py.test tests
                else
                    cd /ynh-dev/yunohost/src/yunohost
                    if [[ -z "$TEST_FUNCTION" ]]
                    then
                        py.test tests/test_"$TEST_MODULE".py
                    else
                        py.test tests/test_"$TEST_MODULE".py::test_"$TEST_FUNCTION"
                    fi
                fi
                ;;
        esac
    done
}

main "$@"

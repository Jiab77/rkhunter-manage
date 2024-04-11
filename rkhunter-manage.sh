#!/bin/bash

# Rootkit Hunter management script
# Made by Jiab77 - 2021
#
# Version 0.0.1

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Colors
NC="\033[0m"
NL="\n"
TAB="\t"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;37m"
PURPLE="\033[1;35m"

# Header
echo -e "${NL}${BLUE}Rootkit Hunter management script ${WHITE}/ Jiab77 - 2021${NC}${NL}"

# Functions
show_help() {
    echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<action>${NC}"
    echo -e "${TAB}${YELLOW}configure${TAB}${WHITE}- Configure existing Rootkit Hunter installation${NC}"
    echo -e "${TAB}${YELLOW}restore${TAB}${TAB}${WHITE}- Restore RootKit Hunter configuration from backup file${NC}"
    echo -e "${TAB}${YELLOW}update${TAB}${TAB}${WHITE}- Download and update Rootkit Hunter database files${NC}"
    echo -e "${TAB}${YELLOW}scan${TAB}${TAB}${WHITE}- Run Rootkit Hunter scan${NC}"
    echo -e "${TAB}${YELLOW}scan-from-cron${TAB}${WHITE}- Run Rootkit Hunter scan from CRON${NC}"
    echo -e "${TAB}${YELLOW}show-log${TAB}${WHITE}- Show log from last scan${NC}"
    echo -e "${TAB}${YELLOW}help${TAB}${TAB}${WHITE}- Show help${NC}"
    echo -e ""
}

# Arguments check
((!$#)) && show_help && exit 1

# Get OS details
source /etc/os-release

# Fix OS detection
[[ -z $ID_LIKE ]] && DISTRO=$ID || DISTRO=$ID_LIKE

# Config
RKH_CONF="/etc/rkhunter.conf"
RKH_CONF_BACKUP="${RKH_CONF}.bak"
RKH_LOG="/var/log/rkhunter.log"

# Check action
case "$1" in
    "scan")
        echo -e "${WHITE}Running ${GREEN}Rootkit Hunter${WHITE} scan...${NC}${NL}"

        # Defining scan command line based on linux distro
        case $DISTRO in
            "debian")
                sudo rkhunter --propupd --pkgmgr DPKG --enable all --disable none --check --sk
            ;;
            "redhat")
                sudo rkhunter --propupd --pkgmgr RPM --enable all --disable none --check --sk
            ;;
        esac
    ;;

    "scan-from-cron")
        echo -e "${WHITE}Running ${GREEN}Rootkit Hunter${WHITE} ${PURPLE}CRON${WHITE} scan...${NC}${NL}"

        # Defining scan command line based on linux distro
        case $DISTRO in
            "debian")
                sudo rkhunter --propupd --pkgmgr DPKG --enable all --disable none --cronjob --rwo --novl
            ;;
            "redhat")
                sudo rkhunter --propupd --pkgmgr RPM --enable all --disable none --cronjob --rwo --novl
            ;;
        esac
    ;;

    "configure")
        echo -e "${WHITE}Configuring existing Rootkit Hunter installation ${GREEN}${RKH_CONF}${WHITE}...${NC}${NL}"

        # Create config file backup
        sudo cp -v $RKH_CONF $RKH_CONF_BACKUP

        # Enable all tests, including those that are disabled for some reasons
        sudo sed -e 's/DISABLE_TESTS=suspscan hidden_ports hidden_procs deleted_files packet_cap_apps apps/DISABLE_TESTS=NONE/' -i $RKH_CONF

        # Enable whitelisting based on package managers
        case $DISTRO in
            "debian")
                sudo sed -e 's/#PKGMGR=NONE/PKGMGR=DPKG/' -i $RKH_CONF
            ;;
            "redhat")
                sudo sed -e 's/#PKGMGR=NONE/PKGMGR=RPM/' -i $RKH_CONF
            ;;
        esac

        # Use 'curl' if exist to download updates
        if [[ ! $(which curl) == "" ]]; then
            sudo sed -e 's|WEB_CMD="/bin/false"|WEB_CMD=curl|' -i $RKH_CONF
        fi
    ;;

    "restore")
        echo -e "${WHITE}Restoring Rootkit Hunter configuration from backup file ${GREEN}${RKH_CONF_BACKUP}${WHITE}...${NC}${NL}"

        # Searching for backup file and restore if found
        if [[ -f $RKH_CONF_BACKUP ]]; then
            sudo mv -v $RKH_CONF_BACKUP $RKH_CONF
        else
            echo -e "${RED}Backup file not found.${NC}${NL}"
        fi
    ;;

    "update")
        echo -e "${WHITE}Updating Rootkit Hunter database files...${NC}${NL}"

        # Download each database files required by RootKit Hunter
        # TODO: Include i18n files
        for F in mirrors.dat programs_bad.dat backdoorports.dat suspscan.dat ; do
            sudo wget http://rkhunter.sourceforge.net/1.4/$F -O /var/lib/rkhunter/db/$F
        done
    ;;

    "show-log")
        echo -e "${WHITE}Showing last Rootkit Hunter scan log...${NC}${NL}"
        sudo less $RKH_LOG
    ;;

    "help")
        show_help
    ;;

    *)
        echo -e "${YELLOW}Invalid option: ${RED}$1${NC}${NL}"
        show_help
    ;;
esac

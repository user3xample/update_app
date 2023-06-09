#! /usr/bin/env bash
#==============================================================================#
# title             : update_app
# Git               : https://github.com/user3xample/update_app
# description       : Script to update and patch servers or pc's
# author            : Paul Abel
# date              : 30/05/2023
# version           : 2.0
# usage             : sudo ./update_app.sh
# notes             : In development.
# bash_version      : 5.0.17(1)-release
# licence           : GNU General Public License v3.0 
#		                  https://github.com/user3xample/updater/blob/main/LICENSE
#==============================================================================#
### DEBUG
#set -xe  # Prints the cmds as they are executed. Debug mode
set -e  # Break out and halt script if we hit an error (default left on unless -xe selected)
###Display colouring ##################################################################################################
# display output options
COLOR_1="\033[1;31m"    # Red
COLOR_2="\033[1;32m"    # Green, lines and 'good' text.
COLOR_3="\033[1;35m"    # cyan
COLOR_4="\033[1;33m"	  # Yellow
NOCOLOR="\033[0m"
LINE="#===========================================================================#"
STEP_COMPLETE=" [*] Step Complete"
START_OF_UPDATE=$(date +'%I:%M:%S %p %d/%m/%Y')
### FAILSAFE ##########################################################################################################
# fail safe, comment out to arm the script.
echo -e "${COLOR_1}[X] Failsafe is active${NOCOLOR} : script disabled. 'Check script at line 29'." && exit 1
#######################################################################################################################
if [ "$EUID" -ne 0 ]  # force running as root.
    then echo -e "${COLOR_1}\n [X] Required to be run as 'root'.\n\n${COLOR_2}[CORRECT WAY] 'sudo ./update_app.sh'"
    echo -e "\n${COLOR_4} [*] Please try again.${NOCOLOR}"
  exit
fi

function logo(){
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "${COLOR_1}   __  __          __      __                             "
    echo -e "${COLOR_2}  / / / /___  ____/ /___ _/ /____     ____ _____  ____    "
    echo -e "${COLOR_3} / / / / __ \/ __  / __  / __/ _ \   / __  / __ \/ __ \   "
    echo -e "${COLOR_4}/ /_/ / /_/ / /_/ / /_/ / /_/  __/  / /_/ / /_/ / /_/ /   "
    echo -e "${COLOR_1}\____/ .___/\__,_/\__,_/\__/\___/   \__,_/ .___/ .___/    "
    echo -e "${COLOR_2}    /_/                                 /_/   /_/         "
}


function setup_log(){
    datetime=$(date +"%Y%m%d_%H%M%S")
    sudo mkdir -p /home/update/updatelogs/
    touch "/home/update/updatelogs/${datetime}_update.log"
    logfile="/home/update/updatelogs/${datetime}_update.log"
    sudo echo "[*] Update started : $(date) : ITOPS Ticket : @option.TicketReference@"\
     >> /home/update/updatelogs/mini_timeline.log
}


function header(){
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo  " === New Server === "
    echo  "  Date: ${START_OF_UPDATE} "
    echo  "  Host: $(hostname) "
    echo  "  IP: $(hostname -I) "
    echo -e "${COLOR_3}${LINE}"
    echo -e "${COLOR_2} [*] Logging set to: Active : ${logfile}"
}


function list_failed_services(){

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Check: ${COLOR_2}List current failed services"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    systemctl list-units --failed
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo
}


function debian_updater(){
    export DEBIAN_FRONTEND=noninteractive
    list_failed_services

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 1: ${COLOR_2}Pre-configuring Packages"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo yes yes | sudo dpkg --configure -a
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 2: ${COLOR_2}Fix and attempt to correct a system with broken dependencies"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get install -f -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 3: ${COLOR_2}Update apt cache"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get update -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 4: ${COLOR_2}Upgrade packages"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get upgrade -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 5: ${COLOR_2}Distribution upgrade"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get dist-upgrade -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 6: ${COLOR_2}Remove unused packages"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get --purge autoremove -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo

    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo -e "Step 7: ${COLOR_2}Clean up"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo apt-get autoclean -y
    echo -e "${COLOR_2}${STEP_COMPLETE}"
    echo
    list_failed_services
    footer
}


function footer(){
    END_TIME=$(date +'%I:%M:%S %p %d/%m/%Y')
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    echo    " === Finished ==="
    echo -e "START Date: ${START_OF_UPDATE} "
    echo -e "END Date:   ${END_TIME}"
    echo -e "${COLOR_3}${LINE}${NOCOLOR}"
    sudo echo "[*] Update Ended :   $(date)" >> /home/update/updatelogs/mini_timeline.log
    sudo echo "${LINE}" >> /home/update/updatelogs/mini_timeline.log
}


#play
setup_log                        # start logging
logo | tee -a "${logfile}"       # Print logo to make easy to find start of server
header | tee -a "${logfile}"       # Write our header
debian_updater  | tee -a "${logfile}"    # start of our process

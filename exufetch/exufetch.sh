#!/bin/bash
# ExuFetch - System Information Tool for Exu Linux
# Replacement for fastfetch with Exu branding

# Color definitions (Exu brand colors)
PURPLE='\033[38;2;108;92;231m'
LIGHT_PURPLE='\033[38;2;162;155;254m'
GREEN='\033[38;2;0;184;148m'
DARK='\033[38;2;45;52;54m'
LIGHT='\033[38;2;245;246;250m'
RESET='\033[0m'
BOLD='\033[1m'

# Function to get system info
get_os() {
    echo "Exu Linux"
}

get_kernel() {
    uname -r
}

get_uptime() {
    uptime -p | sed 's/up //'
}

get_packages() {
    pacman -Q 2>/dev/null | wc -l
}

get_shell() {
    basename $SHELL
}

get_desktop() {
    echo "KDE Plasma"
}

get_cpu() {
    lscpu | grep "Model name" | cut -d':' -f2 | xargs
}

get_gpu() {
    lspci | grep -i "vga\|3d\|display" | cut -d':' -f3 | xargs
}

get_memory() {
    free -h | awk '/^Mem/ {print $3 " / " $2}'
}

get_disk() {
    df -h / | awk 'NR==2 {print $3 " / " $2}'
}

# Exu Linux ASCII Logo
print_logo() {
    echo -e "${PURPLE}"
    echo "    ███████╗██╗   ██╗██╗   ██╗"
    echo "    ██╔════╝██║   ██║██║   ██║"
    echo "    █████╗  ██║   ██║██║   ██║"
    echo "    ██╔══╝  ██║   ██║██║   ██║"
    echo "    ███████╗╚██████╔╝╚██████╔╝"
    echo "    ╚══════╝ ╚═════╝  ╚═════╝"
    echo -e "${RESET}"
}

# Print system information
print_info() {
    echo -e "${BOLD}${PURPLE}System Information${RESET}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}OS${RESET}           ${LIGHT}$(get_os)${RESET}"
    echo -e "${GREEN}Kernel${RESET}       ${LIGHT}$(get_kernel)${RESET}"
    echo -e "${GREEN}Uptime${RESET}       ${LIGHT}$(get_uptime)${RESET}"
    echo -e "${GREEN}Desktop${RESET}      ${LIGHT}$(get_desktop)${RESET}"
    echo -e "${GREEN}Shell${RESET}        ${LIGHT}$(get_shell)${RESET}"
    echo -e "${GREEN}Packages${RESET}     ${LIGHT}$(get_packages)${RESET}"
    echo -e ""
    echo -e "${BOLD}${PURPLE}Hardware${RESET}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}CPU${RESET}         ${LIGHT}$(get_cpu)${RESET}"
    echo -e "${GREEN}GPU${RESET}         ${LIGHT}$(get_gpu)${RESET}"
    echo -e "${GREEN}Memory${RESET}      ${LIGHT}$(get_memory)${RESET}"
    echo -e "${GREEN}Disk${RESET}        ${LIGHT}$(get_disk)${RESET}"
    echo -e ""
    echo -e "${LIGHT_PURPLE}Simple. Fast. Beautiful.${RESET}"
}

# Main execution
print_logo
print_info

#!/bin/bash

collect_data()
{
    thehostname=$(hostname)
    osversion=$(cat /etc/os-release | grep -E "^(NAME|VERSION)=")
    kernelversion=$(uname -r)
    currentuser=$(whoami)
    usersuidcount=$(awk -F: '$3 == 0 {print $1}' /etc/passwd | wc -l)
    #sudo users
    countsudousers=$(getent group sudo | cut -d: -f4 | wc -l)
    sudousers=$(getent group sudo | cut -d: -f4)
    openports=$(ss -tulpn | grep LISTEN)
    unnecessaryservices=$(systemctl list-units --type=service --state=running 2>/dev/null | grep -E "telnet|ftp|vsftpd|rsh" | wc -l)
    #firewall status
    sudo ufw status 2>/dev/null | grep -q "Status: active"
    firewallstat=$?
    #permition root login
    grep -qi "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null
    sshrootlogin=$?
    #ssh password auth
    grep -qi "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null
    sshpswdauth=$?
    insecurecronjobs=$(find /etc/cron* -type f -perm -0002 2>/dev/null | wc -l)
    worldwritablefile=$(find / -xdev -type f -perm -0002 2>/dev/null | head -n 1 | wc -l)
    suidfiles=$(find / -perm -4000 -type f 2>/dev/null | wc -l)
}

print_baseline()
{
    echo "=================================="
    echo "LINUX SECURITY BASELINE REPORT"
    echo -e "==================================\n\n"

    # ==================================
    # SECTION 1: SYSTEM INFORMATION
    # ==================================

    echo -e "[HOSTNAME]:\n$thehostname\n"
    echo -e "[OS VERSION]:\n$osversion\n"
    echo -e "[KERNEL]:\n$kernelversion\n"
    echo -e "[CURRENT USER]:\n$currentuser\n"
    echo -e "[NUMBER OF USERS WITH UID 0]:\n$usersuidcount\n"
    echo -e "[NUMBER OF SUDO USERS]:\n$countsudousers"
    echo -e "$sudousers\n"
    echo -e "[OPEN PORTS]:\n$openports\n"
    echo -e "[UNNECESSARY SERVICES (Telnet, FTP, VSFTPD, or RSH)]:\n$unnecessaryservices\n"
    printf "[FIREWALL STATUS]:\n%s\n\n" \
        "$([[ $firewallstat -eq 0 ]] && echo "Firewall Active" || echo "Firewall Inactive")"
    printf "[PERMIT ROOT LOGIN]:\n%s\n\n" \
        "$([[ $sshrootlogin -eq 0 ]] && echo "SSH Root Login Enabled" || echo "SSH Root Login Disabled")"
    printf "[SSH PASSWORD AUTH]:\n%s\n\n" \
        "$([[ $sshpswdauth -eq 0 ]] && echo "Password Authentication Enabled" || echo "Password Authentication Disabled")"
    echo -e "[INSECURE CRON JOBS]:\n$insecurecronjobs\n"
    echo -e "[WORLD-WRITABLE FILES]:\n$worldwritablefile\n"
    echo -e "[SUID FILES]:\n$suidfiles\n"
}

collect_data
print_baseline

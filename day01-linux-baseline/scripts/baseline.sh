echo "=================================="
echo "LINUX SECURITY BASELINE REPORT"
echo "=================================="

#what is the hostname?
echo
echo "[HOSTNAME]"
hostname

#which distro is used?
echo
echo "[OS VERSION]"
cat /etc/os-release

#linux kernel version
echo
echo "[KERNEL]"
uname -r

echo
echo "[CURRENT USER]"
whoami

#identify users with UID 0
echo
echo "[USERS WITH UID 0]"
awk -F: '$3 == 0 {print $1}' /etc/passwd

#administrator privilege user list (in sudo group)
echo
echo "[SUDO USERS]"
getent group sudo

#which port is open for the application on this server (ss = socket statistics)
echo
echo "[OPEN PORTS]"
ss -tulpn

#services/daemon that running in the background
echo
echo "[RUNNING SERVICES]"
systemctl list-units --type=service --state=running

#maintain the firewall iptables with ufw (uncomplicated firewall)
echo
echo "[FIREWALL STATUS]"
sudo ufw status 2>/dev/null

#check SSH daemon configuration with Extended regexp feature
#permitrootlogin = configure the ssh login as administrator
#passwordauthentication = configure the ssh login using password (for more secure, using ssh key)
echo
echo "[SSH CONFIG]"
grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null


#system-wide automation job list
echo
echo "[CRON JOBS]"
ls -lah /etc/cron.*

#a world-writable filesystem that has write access for the 'others' group.
echo
echo "[WORD WRITABLE FILES]"
find / -xdev -type f -perm -0002 2>/dev/null | head

#Display all SUID-enabled files. 
#(SUID = Set User ID)
echo
echo "[SUID FILES]"
find / -perm -4000 -type f 2>/dev/null | head -20


#!/usr/bin/bash
LOGFILE=/boot/acd_cli/logs/cloudstore-$(date "+%Y%m%d").log
echo CloudStore log $(date) $'\r'$'\r' >> $LOGFILE 2>&1
echo "Starting Cloud Mounts" $'\r'>> $LOGFILE 2>&1

#Get oauth_data file 
#go to https://tensile-runway-92512.appspot.com

#Put oauth_data file to /boot/acd_cli/config/

#Copy oauth file to system
mkdir -p /root/.cache/acd_cli/
cp /boot/acd_cli/config/oauth_data /root/.cache/acd_cli/oauth_data &&

#Get dependencies

#Install dependancies
upgradepkg --install-new /boot/acd_cli/install/boost-1.59.0-x86_64-1.txz >> $LOGFILE 2>&1
upgradepkg --install-new /boot/acd_cli/install/rlog-1.4-x86_64-1pw.txz >> $LOGFILE 2>&1
upgradepkg --install-new /boot/acd_cli/install/slocate-3.1-x86_64-4.txz >> $LOGFILE 2>&1

#Get encfs

#Install encfs
upgradepkg --install-new /boot/acd_cli/install/encfs-1.8.1-x86_64-1gv.txz >> $LOGFILE 2>&1

#Get acd_cli

#Install acd_cli
pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git >> $LOGFILE 2>&1

#Sleep for 10s and then run a acd_cli sync
sleep 10s &&
acdcli sync >> $LOGFILE 2>&1

#Make sure acdcli sync is successfull. If not, keep calling acdcli sync untill successfull

#Mount point info
#On amazon, create a folder /encfs

#Mount Amazon Cloud Drive (using screen)
echo Mounting Amazon Cloud Drive >> $LOGFILE 2>&1
screen -S acdcli -d -m /usr/bin/acd_cli -nl mount -fg -ao --uid 99 --gid 100 --modules="subdir,subdir=/encfs" /mnt/user/Amazon/.acd >> $LOGFILE 2>&1

#Create a pair of encrypted and decrypted folders
#encfs /mnt/user/Amazon/.acd/ /mnt/user/Amazon/acd/

#Copy /mnt/user/Amazon/.acd/.encfs6.xml /boot/acd_cli/config/.encfs6.xml

#Mount Decrypted view of ACD
echo Mounting ENCFS points >> $LOGFILE 2>&1
echo <password> | ENCFS6_CONFIG='/boot/acd_cli/config/.encfs6.xml' encfs -S -o ro -o allow_other -o uid=99 -o gid=100 /mnt/user/Amazon/.acd/ /mnt/user/Amazon/acd/ >> $LOGFILE 2>&1

#Mount Encrypted view of Local Media (Use for uploading Data to ACD)
echo <password>| ENCFS6_CONFIG='/boot/acd_cli/config/.encfs6.xml' encfs -S --reverse -o ro -o allow_other -o uid=99 -o gid=100 /mnt/user/Amazon/local/ /mnt/user/Amazon/.local/ >> $LOGFILE 2>&1

#Overlay Mount with Local Data taking preference. (Read Only)
echo Mounting Overlay point >> $LOGFILE 2>&1
mount -t overlay -o lowerdir=/mnt/user/Amazon/local/:/mnt/user/Amazon/acd/ overlay /mnt/user/Amazon/merged/ >> $LOGFILE 2>&1

#Actions to run after mounting
#Restart the plex docker (so it can see data in the mount point)
#docker restart plex
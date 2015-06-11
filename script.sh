  # Vagrantfile API/syntax version. Don't touch unless you know what you're doing!


#install firefox 
sudo apt-get update
sudo apt-get install firefox -y
#install flux box
sudo apt-get update
sudo apt-get -y install fluxbox rungetty xorg unzip vim

#=========================================================
echo "Set autologin for the Vagrant user..."
#=========================================================
sudo sed -i '$ d' /etc/init/tty1.conf
sudo echo "exec /sbin/rungetty --autologin vagrant tty1" >> /etc/init/tty1.conf

#=========================================================
echo -n "Start X on login..."
#=========================================================
PROFILE_STRING=$(cat <<EOF
if [ ! -e "/tmp/.X0-lock" ] ; then
	    startx
    fi
    EOF
    )
echo "${PROFILE_STRING}" >> .profile
echo "ok"



wget --no-check-certificate https://github.com/aglover/ubuntu-equip/raw/master/equip_java7_64.sh && bash equip_java7_64.sh
wget --no-check-certificate https://github.com/resilva87/ubuntu-equip/raw/master/equip_eclipse_ide.sh && bash equip_eclipse_ide.sh
wget --no-check-certificate https://github.com/resilva87/ubuntu-equip/raw/master/equip_maven3.sh && bash equip_maven3.sh
#set the path for maven
export PATH="/opt/maven/bin/:$PATH"

#install chrome

wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo rm google-chrome-stable_current_amd64.deb
sudo apt-get install -y -f

echo "Download latest selenium server..."
##=========================================================
#Check if selenium already present
if [ ! -f /opt/selenium/selenium-server-standalone.jar ]; then
echo "Inatlling selenium server latest version"
SELENIUM_VERSION=$(curl "https://selenium-release.storage.googleapis.com/" | perl -n -e'/.*<Key>([^>]+selenium-server-standalone[^<]+)/ && print $1')
wget "https://selenium-release.storage.googleapis.com/${SELENIUM_VERSION}" -O selenium-server-standalone.jar
chown vagrant:vagrant selenium-server-standalone.jar
mkdir -p /opt/selenium
mv selenium-server-standalone.jar /opt/selenium
else
echo "Selenium server already present"
fi

#Start selenium hub

#create sample project
mvn archetype:generate -DgroupId=com.sample -DartifactId=my-app -DarchetypeArtifactId=omelet-archetype -DarchetypeGroupId=com.springer -Dversion=1.0.1 -Dpackage=sample-test -DinteractiveMode=false
cd my-app
mvn clean dependency:copy-dependencies

echo -n "Install startup scripts..."
#=========================================================
STARTUP_SCRIPT=$(cat <<EOF
#!/bin/sh
xterm &
EOF
)
echo "${STARTUP_SCRIPT}" > /etc/X11/Xsession.d/9999-common_start
chmod +x /etc/X11/Xsession.d/9999-common_start
echo "ok"

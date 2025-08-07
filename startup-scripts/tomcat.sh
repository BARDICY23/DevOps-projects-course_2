#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-17-jdk -y
mkdir temp
mkdir /opt/tomcat
cd temp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz
sudo tar -xzf apache-tomcat-10.1.18.tar.gz -C /opt/tomcat --strip-components=1
gsutil cp gs://ahmed-vprofile-bucket-2025/ROOT.war /opt/tomcat/webapps/
cd /opt/tomcat/webapps/
rm -fr ROOT
mv vprofile-v2.war ROOT.war
bash /opt/tomcat/bin/startup.sh


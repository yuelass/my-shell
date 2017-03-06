#!/bin/sh
Nagios_Plugins="nagios-plugins-1.4.16"
NRPE="nrpe-2.12"
Plugins=(
"Params-Validate-0.91"
"Class-Accessor-0.31"
"Config-Tiny-2.12"
"Math-Calc-Units-1.07"
"Regexp-Common-2010010201"
"Nagios-Plugin-0.34"
)
libsetups=(
"yum install gcc glibc glibc-common -y"
"yum install perl-CPAN -y"
"yum install openssl-devel -y"
"yum install sysstat -y"
"yum -y install perl"
"yum -y install perl-devel"
"yum install dos2unix -y"
)
#setup lib
function libsetup(){
for((libsetup=0;libsetup<${#libsetups[*]};libsetup++))
     do
     while true
        do
          ${libsetups[libsetup]} &>/dev/null
          if [ $? -eq 0 ];then
             break
          fi
     done
done
echo "lib install finish!"
}
function nrpesetup(){
useradd nagios -s /sbin/nologin -M
cd /server/tools
tar zxf ${NRPE}.tar.gz
cd ${NRPE}
./configure  &>/dev/null
if [ $? -ne 0 ]
  then
      echo "${NRPE} configure error!"
      exit 4
fi
MAKES=(
"make all"
"make install-plugin"
"make install-daemon"
"make install-daemon-config"
)
for((i=0;i<${#MAKES[*]};i++))
   do
     ${MAKES[i]} &>/dev/null
     if [ $? -ne 0 ]
        then
     echo "${NRPE} ${MAKES[i]} error!"
     exit 5
     fi
done
echo "${NRPE} install finish!"
}
function check_plugins(){
for((i=0;i<${#Plugins[*]};i++))
   do
     cd /server/tools
     tar zxf ${Plugins[i]}.tar.gz
     cd ${Plugins[i]}
     MAKES=(
     "perl Makefile.PL"
     "make"
     "make install"
     )
     for((n=0;n<${#MAKES[*]};n++))
        do
          ${MAKES[n]} &>/dev/null
         if [ $? -ne 0 ]
         then
            echo "${Plugins[i]} ${MAKES[n]} error!"
            exit 5
         fi
     done
     echo "${Plugins[i]} install finish!"
done
}
# setup nagios-plugins
function npluginssetup(){
cd /server/tools
tar zxf ${Nagios_Plugins}.tar.gz
cd ${Nagios_Plugins}
./configure --prefix=/usr/local/nagios --enable-perl-modules  --enable-redhat-pthread-workaround &>/dev/null
if [ $? -ne 0 ]
  then
      echo "${Nagios_Plugins} configure error!"
      exit 4
fi
make &>/dev/null&&make install &>/dev/null
if [ $? -ne 0 ]
  then
     echo "${Nagios_Plugins} make install error!"
     exit 3
fi
echo "${Nagios_Plugins} install finish!"
}
function main(){
libsetup
npluginssetup
nrpesetup
check_plugins
}
main

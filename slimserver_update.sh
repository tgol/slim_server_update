#!/bin/bash

echo
echo "-----------------"
echo "Slimserver update"
echo "-----------------"
echo

echo "> existing update files"
ls -alrt "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/logitechmediaserver_*.deb*
echo

echo "> retrieve update url"
LMS_UPDATE_URL=$(curl -s "http://www.mysqueezebox.com/update/?version=7.9.1&revision=1&geturl=1&os=deb")
if [ \( -z "${LMS_UPDATE_URL}" \) -o \( "${LMS_UPDATE_URL}" == 0 \) ]
then
	echo "Failed to get Slimserver update URL"
	echo "http://wiki.slimdevices.com/index.php/Nightly_Builds"
	exit 1
fi


echo "${LMS_UPDATE_URL}"

echo
echo "Proceed with the update ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo; echo "Update canceled !"; echo; exit;;
    esac
done

echo
echo "> downloading update file"
wget "${LMS_UPDATE_URL}"
LMS_DL_STATUS=$?

if [ ! ${LMS_DL_STATUS} == 0 ]
then
	echo "Failed to download Slimserver update file"
	echo "http://wiki.slimdevices.com/index.php/Nightly_Builds"
	exit 2
fi

LMS_UPDATE_FILE=$(basename ${LMS_UPDATE_URL})
if [ ! -f "${LMS_UPDATE_FILE}" ]
then
	echo "Update file not found"
	echo "http://wiki.slimdevices.com/index.php/Nightly_Builds"
	exit 3
fi

echo
echo "> stop logitechmediaserver if needed"
service logitechmediaserver stop

echo
echo "> install ${LMS_UPDATE_FILE}"
dpkg -i "${LMS_UPDATE_FILE}"

echo
echo "> start logitechmediaserver"
service logitechmediaserver start

echo
echo "Done."
exit 0


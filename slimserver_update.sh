#!/bin/bash

LMS_VERSION="7.9.2"
LMS_INSTALLER_FLAVOUR="deb"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo
echo "-----------------"
echo "Slimserver update"
echo "-----------------"
echo

LMS_CURRENT_REVISION="$(head -n1 /usr/share/squeezeboxserver/revision.txt)"
if [ -z "${LMS_CURRENT_REVISION}" ]
then
	echo "failed to get current revision"
	LMS_CURRENT_REVISION="0000000000"
fi
echo "> current revision: ${LMS_CURRENT_REVISION}"

echo
echo "> retrieve update url"
LMS_UPDATE_URL="$(curl -s "http://www.mysqueezebox.com/update/?\
version=${LMS_VERSION}&\
revision=1&\
geturl=1&\
os=${LMS_INSTALLER_FLAVOUR}$(dpkg --print-architecture)")"

if [ -z "${LMS_UPDATE_URL}" ] || [ "${LMS_UPDATE_URL}" == "0" ]
then
	echo "Failed to get Slimserver update URL"
	echo "http://wiki.slimdevices.com/index.php/Nightly_Builds"
	exit 1
fi

echo "${LMS_UPDATE_URL}" | grep -E --color=always ".*${LMS_CURRENT_REVISION}.*|$"

echo
echo "> existing update files"
find "${SCRIPT_DIR}" \
	-iname "logitechmediaserver_*.${LMS_INSTALLER_FLAVOUR}*" \
	-exec ls -alrt {} + |
	grep -E --color=always ".*${LMS_CURRENT_REVISION}.*|$"

echo
echo "Proceed with the update ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo; echo "Update canceled !"; echo; exit;;
    esac
done

! pushd "${SCRIPT_DIR}" > /dev/null && echo "Failed to cd into $(dirname "${0}")" && exit 1

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

LMS_UPDATE_FILE="$(basename "${LMS_UPDATE_URL}")"
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


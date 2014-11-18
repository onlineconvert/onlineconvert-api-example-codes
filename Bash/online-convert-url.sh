#!/usr/bin/env bash
# vim: tabstop=4 shiftwidth=4 expandtab
#######################################################################
#
#                        Online-Convert.com
#   
#   Example code snippet for using the API of 
#   http://www.online-convert.com
#   
#   Author:  Alexander Löhner <a.loehner@qaamgo.com>
#   License: GPL 3.0
#   
#######################################################################

apiurl="http://api.online-convert.com"

function displayHelp () {
    echo "Example code snippet for using the API of online-convert.com"
    echo ""
    echo "This script converts a given URL into the target format."
    echo ""
    echo "Syntax:    ${0} [--option] [value] [--test]"
    echo ""
    echo "  -h|--help            Get this help screen"
    echo "* -t|--targettype      Sets the target type for convertation"
    echo "* -m|--targetmethod    Sets the target method for convertation"
    echo "* -s|--sourceurl       Sets the source url for convertation"
    echo "* -n|--notificationurl Sets the URL for status notification"
    echo "  --test               Set to \"true\" to activates the test mode"
    echo ""
    echo "Options marked with a \"*\" are mandatory!"
    echo ""
    echo "Refer to http://api.online-convert.com/ for detailed description"
    echo "about these options."
    exit
}

function readApiKey () {
    echo "Please enter your ApiKey for online-convert.com. You may find your"
    echo "ApiKey in your \"Dashboard\" and then clicking on \"Subscription details\":"
    read apikey
    echo "${apikey}" > ${HOME}/.online-convert
    chmod 600 ${HOME}/.online-convert
}

function errorMessage () {
    echo -e "${1}"
    exit
}

if [ "${1}" = "" ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [  "${1}" = "-?" ] || [ "${1}" = "help" ]; then
    displayHelp
fi

if [[ ! -r "${HOME}/.online-convert" ]]; then
    readApiKey
else
    apikey=$( cat ${HOME}/.online-convert )
fi

curl=$( which curl )
if [[ "${curl}" = "" ]]; then
    errorMessage "You need curl installed to use this script.\nie: \"sudo apt-get install curl\""
fi

targettype=""
targetmethod=""
sourceurl=""
notificationurl=""
testmode="false"

while [[ $# > 1 ]]; do
    key="${1}"
    shift
    case ${key} in
        -h|--help)
            displayHelp
            shift
            ;;
        -t|--targettype)
            targettype="${1}"
            shift
            ;;
        -m|--targetmethod)
            targetmethod="${1}"
            shift
            ;;
        -s|--sourceurl)
            sourceurl="${1}"
            shift
            ;;
        -n|--notificationurl)
            notificationurl="${1}"
            shift
            ;;
        --test)
            testmode="${1}"
            shift
            ;;
        *)
            displayHelp
            ;;
    esac
done

if [ "${targettype}" = "" ] || [ "${targetmethod}" = "" ] || [ "${sourceurl}" = "" ] || [ "${notificationurl}" = "" ]; then
    displayHelp
fi

echo "> Building XML data string for requesting token from online-convert.com..."
read -r -d '' opts << EOM
-s --data-urlencode "queue=<?xml version=\"1.0\" encoding=\"utf-8\"?>
<queue>
  <apiKey>${apikey}</apiKey>
</queue>"
EOM

echo "> Requesting token from online-convert.com..."
return=$( eval ${curl} ${opts} ${apiurl}/request-token )
errorcode=$( echo ${return} | sed "s#.*<code>\([0-9]*\)</code>.*#\1#" )

if [[ $errorcode -ne 400 ]]; then
    errorMessage "Something went wrong!\nHere's the response given from the online-convert.com:\n\n${return}"
fi

token=$( echo ${return} | sed "s#.*<token>\([0-9a-z]*\)</token>.*#\1#" )
echo "> Token successfully received: ${token}"

server=$( echo ${return} | sed "s#.*<server>\([^<]*\)</server>.*#\1#" )
echo "> Server successfully received: ${server}"

domain=$( echo ${server} | awk -F/ '{print $3}' )

echo "> Building XML data string for sending job request to online-convert.com..."
read -r -d '' opts << EOM
-s --data-urlencode "queue=<?xml version=\"1.0\" encoding=\"utf-8\"?>
<queue>
  <token>${token}</token>
  <targetType>${targettype}</targetType>
  <targetMethod>${targetmethod}</targetMethod>
  <testMode>${testmode}</testMode>
  <sourceUrl>${sourceurl}</sourceUrl>
  <notificationUrl>${notificationurl}</notificationUrl>
</queue>"
EOM

echo "> Inserting convertion job into queue on ${domain}..."
return=$( eval ${curl} ${opts} ${server}/queue-insert )
errorcode=$( echo ${return} | sed "s#.*<code>\([0-9]*\)</code>.*#\1#" )

if [[ $errorcode -gt 0 ]]; then
    errorMessage "Something went wrong!\nHere's the response given from the online-convert.com:\n\n${return}"
fi

hash=$( echo ${return} | sed "s#.*<hash>\([0-9a-z]*\)</hash>.*#\1#" )
echo "> Job successfully inserted to queue. Hash: ${hash}"

echo "> Building XML data string for getting status information about the job..."
read -r -d '' opts << EOM
-s --data-urlencode "queue=<?xml version=\"1.0\" encoding=\"utf-8\"?>
<queue>
  <token>${token}</token>
  <hash>${hash}</hash>
</queue>"
EOM

c=1
while true; do
    echo "> (${c}) Getting status information for job ${hash}..."
    return=$( eval ${curl} ${opts} ${apiurl}/queue-status )
    errorcode=$( echo ${return} | sed "s#.*<code>\([0-9]*\)</code>.*#\1#" )
    if [[ ${errorcode} -eq 100 ]]; then
        download=$( echo ${return} | sed "s#.*<directDownload>\([^<]*\)</directDownload>.*#\1#" )
        echo "> Job successfully finished."
        break
    else
        message=$( echo ${return} | sed "s#.*<message>\([^<]*\)</message>.*#\1#" )
        echo "> > ${message} (Code: ${errorcode})"
    fi
    c=$(( ${c} + 1 ))
    sleep 5
done

echo "> Downloading from ${download} ..."
${curl} -s -O -J ${download}

echo "> File locally saved in actual working directory."

# end

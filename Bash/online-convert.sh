#!/usr/bin/env bash
# vim: tabstop=4 shiftwidth=4 expandtab
apiurl="http://api.online-convert.com"

#
#
#####################      Begin of function definitions       ######################
#
#

function displayHelp () {
    echo "#######################################################"
    echo "#                                                     #"
    echo "#                 Online-Convert.com                  #"
    echo "#                                                     #"
    echo "#   Example code snippet for using the API of         #"
    echo "#   http://www.online-convert.com                     #"
    echo "#                                                     #"
    echo "#   Author:  Alexander Löhner <a.loehner@qaamgo.com>  #"
    echo "#   License: MIT                                      #"
    echo "#                                                     #"
    echo "#######################################################"
    echo ""
    echo "This script converts a file or URL into the target format."
    echo ""
    echo "-----------------------------------------------------------------------------"
    echo ""
    echo "Usage: ${0} [OPTIONS]"
    echo ""
    echo "One of following options are mandatory, and only one:"
    echo "  -F <path>    Use a local file for convertation."
    echo "  -U <url>     Use a URL for convertation."
    echo "  -B <hash>    Use a Hash string for convertation."
    echo "  -h           Show this help screen."
    echo ""
    echo "The following options must always be set:"
    echo "  -A <apikey>  Sets your ApiKey for online-convert.com"
    echo "  -T <type>    Sets the target type for convertation. This can be one of:"
    echo "               image, audio, video, archive, document, ebook, hash"
    echo "  -M <method>  Sets the convertation method. This can be many different methods"
    echo "               like: convert-to-png, convert-to-mp4, conver-to-epub, sha1-generator"
    echo "               and many more. Please refer to http://api.online-convert.com/"
    echo "               for detailed description."
    echo ""
    echo "The following options are optional:"
    echo "  -N <url>     Sets the notification URL. This URL will be automagically get"
    echo "               called when a convertation job is finished."
    echo "  -Z           This activates the Test Mode."
    echo ""
    echo "-----------------------------------------------------------------------------"
    echo ""
    echo "You may create a configfile in your home folder, named \".online-convert\"."
    echo "This configfile has to be in the following format:"
    echo ""
    echo "apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo "type=image"
    echo "method=convert-to-png"
    echo ""
    echo "You can store one or all of these three arguments in this configfile. If one"
    echo "is not set, you have to use the option as an argument on commandline."
    echo ""
    echo "-----------------------------------------------------------------------------"
    echo ""
    echo "There are many other options you can set on commandline for various"
    echo "convertation types (-T):"
    echo "(Options not belonging to the given type will be silently ignored!)"
    echo ""
    echo "For type \"audio\":"
    echo "  -b <bitrate>    Sets the target bitrate."
    echo "  -d <bit_depth>  Sets the target bit depth."
    echo "  -q <frequency>  Sets the target frequency."
    echo "  -c <channel>    Sets the channel"
    echo "  -s <start>      Sets the start time for the convertation, ie: 00:00:00"
    echo "  -e <end>        Sets the end time for the convertation, ie: 00:00:15"
    echo "  -w <pcm_format> Only for convert-to-wav, sets the PCM format."
    echo ""
    echo "For type \"document\":"
    echo "  -o              Activates the OCR moe for converting images (or PDF) to"
    echo "                  documents. (Option \"-l\" is mandatory then!)"
    echo "  -l <language>   Sets the language for OCR. Can be \"eng\" or \"deu\", etc."
    echo ""
    echo "For type \"ebook\":"
    echo "  -f <num>        Sets the target format. See file \"../docs/eBook-formats.txt\" for"
    echo "                  the available formats."
    echo "  -t <title>      The title of your converted eBook. Use quotes to enclose it!"
    echo "  -a <author>     The author of your converted eBook. Use quotes to enclose it!"
    echo "  -m <margin>     Add a margin in centimeters to your eBook. Use numeric value."
    echo "  -p              Converts your eBook into plain ASCII text."
    echo "  -i <input_enc>  Sets the input encoding. See file \"../docs/eBook-formats.txt\" for"
    echo "                  the available encodings."
    echo "  -j <embed_font> Sets the embedded font style. See file \"../docs/eBook-formats.txt\""
    echo "                  for the available font styles."
    echo ""
    echo "For type \"image\":"
    echo "  -W <width>      Sets the width of the target image."
    echo "  -H <height>     Sets the height of the target image."
    echo "  -d <dpi>        Sets the DPI for the target image."
    echo "  -q <quality>    Sets the quality of the target image (For JPEG compression)."
    echo "  -C <color>      Sets the color modification for the target image. See file"
    echo "                  \"image-formats.txt\" for available color modifications."
    echo "  -E              Equalize the image using histogram."
    echo "  -Y              Convert image to span full range of JPG colors"
    echo "  -X              Apply a digital filter to enhance the JPG image"
    echo "  -S              Sharpen target JPG image"
    echo "  -L              Remove pixel artefacts from JPG image"
    echo "  -D              Reduce the speckles in target JPG image"
    echo ""
    echo "For type \"video\":"
    echo "  -W <width>      Sets the width of the target video."
    echo "  -H <height>     Sets the height of the target video."
    echo "  -y <v_quality>  Sets the video bitrate."
    echo "  -x <a_quality>  Sets the audio bitrate."
    echo "  -f <framerate>  Sets the target framerate."
    echo "  -r <rotate>     Sets the angle for clockwise rotation."
    echo "  -m <mirror>     Sets the direction of mirroring. See file"
    echo "                  \"../docs/video-formats.txt\" for available direction."
    echo "  -c <codec>      Sets the codec. See file \"../docs/video-formats.txt\" for available"
    echo "                  codecs."
    echo "  -s <start>      Sets the start time for the convertation, ie: 00:00:00"
    echo "  -e <end>        Sets the end time for the convertation, ie: 00:00:15"
    echo ""
    echo "Refer to http://api.online-convert.com/ for detailed description"
    echo "about all these options."
    exit
}

function errorMessage () {
    echo -e "${1}" >&2
    exit 1
}

#
#
#####################      End of function definitions       ######################
#
#

curl=$( which curl )
if [[ "${curl}" = "" ]]; then
    errorMessage "You must have cURL installed for this script to work!"
fi

options=":F:U:B:hA:T:M:N:Zb:q:c:s:e:ol:f:t:a:m:pi:j:W:H:d:w:C:ENXSLDy:x:r:"
while getopts "${options}" option; do
  case $option in
    F)   isset_F=true;  val_F="${OPTARG}";;
    U)   isset_U=true;  val_U="${OPTARG}";;
    B)   isset_B=true;  val_B="${OPTARG}";;
    A)   isset_A=true;  val_A="${OPTARG}";;
    T)   isset_T=true;  val_T="${OPTARG}";;
    M)   isset_M=true;  val_M="${OPTARG}";;
    N)   isset_N=true;  val_N="${OPTARG}";;
    Z)   isset_Z=true;;
    h)   displayHelp;;
    b)   isset_b=true;  val_b="${OPTARG}";;
    q)   isset_q=true;  val_q="${OPTARG}";;
    c)   isset_c=true;  val_c="${OPTARG}";;
    s)   isset_s=true;  val_s="${OPTARG}";;
    e)   isset_e=true;  val_e="${OPTARG}";;
    w)   isset_w=true;  val_w="${OPTARG}";;
    o)   isset_o=true;;
    l)   isset_l=true;  val_l="${OPTARG}";;
    f)   isset_f=true;  val_f="${OPTARG}";;
    t)   isset_t=true;  val_t="${OPTARG}";;
    a)   isset_a=true;  val_a="${OPTARG}";;
    m)   isset_m=true;  val_m="${OPTARG}";;
    p)   isset_p=true;;
    i)   isset_i=true;  val_i="${OPTARG}";;
    j)   isset_j=true;  val_j="${OPTARG}";;
    W)   isset_W=true;  val_W="${OPTARG}";;
    H)   isset_H=true;  val_H="${OPTARG}";;
    d)   isset_d=true;  val_d="${OPTARG}";;
    C)   isset_C=true;  val_C="${OPTARG}";;
    E)   isset_E=true;;
    Y)   isset_Y=true;;
    X)   isset_X=true;;
    S)   isset_S=true;;
    L)   isset_L=true;;
    D)   isset_D=true;;
    y)   isset_y=true;  val_y="${OPTARG}";;
    x)   isset_x=true;  val_x="${OPTARG}";;
    r)   isset_r=true;  val_r="${OPTARG}";;
    \?)  displayHelp;;
    :)   errorMessage "Missing option argument for -$OPTARG";;
    *)   errorMessage "Unimplemented option: -$OPTARG";;
  esac
done

if [ ! $isset_F ] && [ ! $isset_U ] && [ ! $isset_B ]; then
    errorMessage "Either Option -F, -U or -B must be provided! Use -h for Help."
fi
if [ ! $isset_A ]; then
    source ${HOME}/.online-convert 2>/dev/null
    if [ ! $apikey ]; then
        errorMessage "Please provide us your ApiKey (-A). Use -h for Help."
    fi
else
    apikey="${val_A}"
fi
if [ ! $isset_T ]; then
    source ${HOME}/.online-convert 2>/dev/null
    if [ ! $type ]; then
        errorMessage "Please provide us the type of target file (-T). Use -h for Help."
    fi
else
    type="${val_T}"
fi
if [ ! $isset_M ]; then
    source ${HOME}/.online-convert 2>/dev/null
    if [ ! $method ]; then
        errorMessage "Please provide us the convertation method (-M). Use -h for Help."
    fi
else
    method="${val_M}"
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
xml="\\<?xml version=\\\"1.0\\\" encoding=\\\"utf-8\\\"?><queue>"
if [[ "${token}" != "" ]]; then
    xml="${xml}<token>${token}</token>"
fi
if [[ "${type}" != "" ]]; then
    xml="${xml}<targetType>${type}</targetType>"
fi
if [[ "${method}" != "" ]]; then
    xml="${xml}<targetMethod>${method}</targetMethod>"
fi
if [[ "${isset_Z}" = "true" ]]; then
    xml="${xml}<testMode>true</testMode>"
else
    xml="${xml}<testMode>false</testMode>"
fi
if [[ "${val_N}" != "" ]]; then
    xml="${xml}<notificationUrl>${val_N}</notificationUrl>"
fi
if [[ "${val_U}" != "" ]]; then
    xml="${xml}<sourceUrl>${val_U}</sourceUrl>"
fi

xml="${xml}<format>"
if [[ "${type}" = "audio" ]]; then
    if [[ "${val_b}" != "" ]]; then
        xml="${xml}<bitrate>${val_b}</bitrate>"
    fi
    if [[ "${val_d}" != "" ]]; then
        xml="${xml}<bit_depth>${val_d}</bit_depth>"
    fi
    if [[ "${val_q}" != "" ]]; then
        xml="${xml}<frequency>${val_q}</frequency>"
    fi
    if [[ "${val_c}" != "" ]]; then
        xml="${xml}<channel>${val_c}</channel>"
    fi
    if [[ "${val_s}" != "" ]]; then
        xml="${xml}<audio_start>${val_s}</audio_start>"
    fi
    if [[ "${val_e}" != "" ]]; then
        xml="${xml}<audio_end>${val_e}</audio_end>"
    fi
    if [[ "${val_w}" != "" ]]; then
        xml="${xml}<pcm_format>${val_w}</pcm_format>"
    fi
elif [[ "${type}" = "document" ]]; then
    if [[ "${isset_o}" = "true" ]]; then
        xml="${xml}<ocr>true</ocr>"
    fi
    if [[ "${val_l}" != "" ]]; then
        xml="${xml}<source_lang>${val_l}</source_lang>"
    fi
elif [[ "${type}" = "ebook" ]]; then
    if [[ "${val_f}" != "" ]]; then
        xml="${xml}<target_format>${val_f}</target_format>"
    fi
    if [[ "${val_t}" != "" ]]; then
        xml="${xml}<title>${val_t}</title>"
    fi
    if [[ "${val_a}" != "" ]]; then
        xml="${xml}<author>${val_a}</author>"
    fi
    if [[ "${val_m}" != "" ]]; then
        xml="${xml}<border>${val_m}</border>"
    fi
    if [[ "${isset_p}" = "true" ]]; then
        xml="${xml}<asciiize>true</asciiize>"
    fi
    if [[ "${val_i}" != "" ]]; then
        xml="${xml}<input_encoding>${val_i}</input_encoding>"
    fi
    if [[ "${val_j}" != "" ]]; then
        xml="${xml}<embed_font>${val_j}</embed_font>"
    fi
elif [[ "${type}" = "image" ]]; then
    if [[ "${val_W}" != "" ]]; then
        xml="${xml}<width>${val_W}</width>"
    fi
    if [[ "${val_H}" != "" ]]; then
        xml="${xml}<height>${val_H}</height>"
    fi
    if [[ "${val_d}" != "" ]]; then
        xml="${xml}<dpi>${val_d}</dpi>"
    fi
    if [[ "${val_q}" != "" ]]; then
        xml="${xml}<quality>${val_q}</quality>"
    fi
    if [[ "${val_C}" != "" ]]; then
        xml="${xml}<color>${val_C}</color>"
    fi
    if [[ "${isset_E}" = "true" ]]; then
        xml="${xml}<equalize>1</equalize>"
    fi
    if [[ "${isset_Y}" = "true" ]]; then
        xml="${xml}<normalize>1</normalize>"
    fi
    if [[ "${isset_X}" = "true" ]]; then
        xml="${xml}<enhance>1</enhance>"
    fi
    if [[ "${isset_S}" = "true" ]]; then
        xml="${xml}<sharpen>1</sharpen>"
    fi
    if [[ "${isset_L}" = "true" ]]; then
        xml="${xml}<antialias>1</antialias>"
    fi
    if [[ "${isset_D}" = "true" ]]; then
        xml="${xml}<despeckle>1</despeckle>"
    fi
elif [[ "${type}" = "video" ]]; then
    if [[ "${val_W}" != "" ]]; then
        xml="${xml}<width>${val_W}</width>"
    fi
    if [[ "${val_y}" != "" ]]; then
        xml="${xml}<v_quality>${val_y}</v_quality>"
    fi
    if [[ "${val_x}" != "" ]]; then
        xml="${xml}<a_quality>${val_x}</a_quality>"
    fi
    if [[ "${val_f}" != "" ]]; then
        xml="${xml}<framerate>${val_f}</framerate>"
    fi
    if [[ "${val_r}" != "" ]]; then
        xml="${xml}<rotate>${val_r}</rotate>"
    fi
    if [[ "${val_m}" != "" ]]; then
        xml="${xml}<mirror>${val_m}</mirror>"
    fi
    if [[ "${val_c}" != "" ]]; then
        xml="${xml}<codec>${val_c}</codec>"
    fi
    if [[ "${val_s}" != "" ]]; then
        xml="${xml}<audio_start>${val_s}</audio_start>"
    fi
    if [[ "${val_e}" != "" ]]; then
        xml="${xml}<audio_end>${val_e}</audio_end>"
    fi
fi
xml="${xml}</format>"
if [[ "${type}" = "hash" ]]; then
    xml="\\<?xml version=\\\"1.0\\\" encoding=\\\"utf-8\\\"?><queue>"
    if [[ "${token}" != "" ]]; then
        xml="${xml}<token>${token}</token>"
    fi
    if [[ "${type}" != "" ]]; then
        xml="${xml}<targetType>${type}</targetType>"
    fi
    if [[ "${method}" != "" ]]; then
        xml="${xml}<targetMethod>${method}</targetMethod>"
    fi
    if [[ "${isset_Z}" = "true" ]]; then
        xml="${xml}<testMode>true</testMode>"
    else
        xml="${xml}<testMode>false</testMode>"
    fi
    if [[ "${val_B}" != "" ]]; then
        xml="${xml}<hash_string>${val_B}</hash_string>"
    fi
fi
xml="${xml}</queue>"

if [ "${val_U}" != "" ] || [ "${val_B}" != "" ]; then
    # url download
    echo "> Inserting convertion job into queue on ${domain}..."
    return=$( eval ${curl} -s --data-urlencode \""queue=${xml}"\" ${server}/queue-insert )
    errorcode=$( echo ${return} | sed "s#.*<code>\([0-9]*\)</code>.*#\1#" )
    if [[ $errorcode -gt 0 ]]; then
        errorMessage "Something went wrong!\nHere's the response given from the online-convert.com:\n\n${return}"
    fi
    hash=$( echo ${return} | sed "s#.*<hash>\([0-9a-z]*\)</hash>.*#\1#" )
    echo "> Job successfully inserted to queue. Hash: ${hash}"
elif [[ "${val_F}" != "" ]]; then
    # file upload
    optstest=$( echo "${xml}" | sed ':a;N;$!ba;s/\n//g' )
    filedata='-s -X POST -F "queue='${optstest}'" -F "file=@'${val_F}'"'
    echo "> Inserting convertion job into queue on ${domain}..."
    return=$( eval ${curl} ${filedata} ${server}/queue-insert )
    errorcode=$( echo ${return} | sed "s#.*<code>\([0-9]*\)</code>.*#\1#" )
    if [[ $errorcode -gt 0 ]]; then
        errorMessage "Something went wrong!\nHere's the response given from the online-convert.com:\n\n${return}"
    fi
    hash=$( echo ${return} | sed "s#.*<hash>\([0-9a-z]*\)</hash>.*#\1#" )
    echo "> Job successfully inserted to queue. Hash: ${hash}"
fi

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

<?php

/*
 * The MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * OnlineConvert Class
 *
 * API class for www.online-convert.com service.
 *
 * @version 1.0
 * @link http://api.online-convert.com/
 */
Class OnlineConvert {

    /**
     * Online Converter API URL
     */
    const URL = 'http://api.online-convert.com';

    /**
     * Target type constant value for URL type.
     */
    const TARGET_TYPE_URL = 'URL';

    /**
     * Target type constant value for FILE_BASE64 type.
     */
    const TARGET_TYPE_FILE_BASE64 = 'FILE_BASE64';

    /**
     * Target type constant value for FILE_PATH type.
     */
    const TARGET_TYPE_FILE_PATH = 'FILE_PATH';

    /**
     * @var string Online Converter API Key
     */
    private $apiKey;

    /**
     * @var boolean
     */
    private $testMode;

    /**
     * @var string
     */
    private $url = self::URL;

    /**
     * @var string
     */
    private $targetType;

    /**
     * @var string
     */
    private $sourceType;

    /**
     * @var string
     */
    public $hash;

    /**
     * @var string
     */
    public $downloadUrl;

    /**
     * @var array
     */
    private $targetTypeOptions = array(
        'convert-to-7z' => 'archive',
        'convert-to-bz2' => 'archive',
        'convert-to-gz' => 'archive',
        'convert-to-zip' => 'archive',
        'convert-to-aac' => 'audio',
        'convert-to-aiff' => 'audio',
        'convert-to-flac' => 'audio',
        'convert-to-m4a' => 'audio',
        'convert-to-mp3' => 'audio',
        'convert-to-ogg' => 'audio',
        'convert-to-opus' => 'audio',
        'convert-to-wav' => 'audio',
        'convert-to-wma' => 'audio',
        'convert-to-doc' => 'document',
        'convert-to-docx' => 'document',
        'convert-to-flash' => 'document',
        'convert-to-html' => 'document',
        'convert-to-odt' => 'document',
        'convert-to-pdf' => 'document',
        'convert-to-ppt' => 'document',
        'convert-to-rtf' => 'document',
        'convert-to-txt' => 'document',
        'convert-to-azw3' => 'ebook',
        'convert-to-epub' => 'ebook',
        'convert-to-fb2' => 'ebook',
        'convert-to-lit' => 'ebook',
        'convert-to-lrf' => 'ebook',
        'convert-to-mobi' => 'ebook',
        'convert-to-pdb' => 'ebook',
        'convert-to-pdf' => 'ebook',
        'convert-to-tcr' => 'ebook',
        'convert-to-bmp' => 'image',
        'convert-to-eps' => 'image',
        'convert-to-gif' => 'image',
        'convert-to-exr' => 'image',
        'convert-to-ico' => 'image',
        'convert-to-jpg' => 'image',
        'convert-to-png' => 'image',
        'convert-to-svg' => 'image',
        'convert-to-tga' => 'image',
        'convert-to-tiff' => 'image',
        'convert-to-wbmp' => 'image',
        'convert-to-webp' => 'image',
        'convert-to-3g2' => 'video',
        'convert-to-3gp' => 'video',
        'convert-to-avi' => 'video',
        'convert-to-flv' => 'video',
        'convert-to-mkv' => 'video',
        'convert-to-mov' => 'video',
        'convert-to-mp4' => 'video',
        'convert-to-mpeg-1' => 'video',
        'convert-to-mpeg-2' => 'video',
        'convert-to-ogg' => 'video',
        'convert-to-webm' => 'video',
        'convert-to-wmv' => 'video',
        'convert-video-for-android' => 'video',
        'convert-video-for-blackberry' => 'video',
        'convert-video-for-ipad' => 'video',
        'convert-video-for-iphone' => 'video',
        'convert-video-for-ipod' => 'video',
        'convert-video-for-nintendo-3ds' => 'video',
        'convert-video-for-nintendo-ds' => 'video',
        'convert-video-for-ps3' => 'video',
        'convert-video-for-psp' => 'video',
        'convert-video-for-wii' => 'video ',
        'convert-video-for-xbox' => 'video'
    );

    /**
     * @var array
     */
    private $sourceTypeOptions = array(
        self::TARGET_TYPE_URL => 'URL',
        self::TARGET_TYPE_FILE_BASE64 => 'FILE_BASE64',
        self::TARGET_TYPE_FILE_PATH => 'FILE_PATH'
    );


    /**
     * create
     * Create instance and set required parameters.
     *
     * @param string $apiKey
     * @param string $testMode
     * @return self
     */
    public static function create($apiKey, $testMode='true')
    {
        $instance = new self();
        $instance->apiKey = $apiKey;
        $instance->testMode = $testMode;
        return $instance;
    }

    /**
     * convert
     * Make a API call to convert file/url/hash based on parameters and return xml response.
     *
     * @param string $targetType To which file you want to convert (like convert-to-jpg, convert-to-mp3)
     * @param string $sourceType 3 source types you can set (URL, FILE_PATH and FILE_BASE64)
     * @param string $source Source can be provide based on sourceType if sourceType = URL you have to provide url string to this param.
     * @param string $sourceName Provide file Name. This param used only with sourceType = FILE_PATH or FILE_BASE64
     * @param string $sourceOptions Provide file conversion required extra parameters as array using this param.
     * @param string $notificationUrl For set notification url for api actions.
     */
    public function convert($targetType, $sourceType, $source, $sourceName=null, $sourceOptions=null, $notificationUrl=null)
    {
        if(!isset($this->targetTypeOptions[$targetType])){
            throw new Exception('Invalid Target Type.');
        }
        $this->targetType = $targetType;

        if(!isset($this->sourceTypeOptions[$sourceType])){
            throw new Exception('Invalid Source Type.');
        }
        $this->sourceType = $sourceType;

        if($this->sourceType == self::TARGET_TYPE_FILE_BASE64 || $this->sourceType == self::TARGET_TYPE_FILE_PATH){
            if($sourceName === null || strlen($sourceName) < 1){
                throw new Exception('Invalid Source Name.');
            }
        }

        if($this->sourceType == self::TARGET_TYPE_FILE_PATH){
            if(!file_exists($source)){
                throw new Exception('File not found: '.$source);
            }
            $source = base64_encode(file_get_contents($source));
        }

        $data['apiKey'] = $this->apiKey;
        $data['targetType'] = $this->targetTypeOptions[$targetType];
        $data['targetMethod'] = $targetType;
        $data['testMode'] = $this->testMode;
        $data['notificationUrl'] = $notificationUrl;

        if ($this->sourceType == self::TARGET_TYPE_URL) {
            $data['sourceUrl'] = $source;
        } else {
            $data['file']['fileName'] = $sourceName;
            $data['file']['fileData'] = $source;
        }

        if ($sourceOptions !== null) {
            $data['format'] = $sourceOptions;
        }

        $response = $this->apiCall('queue-insert', array('queue' => $data));
        $responseArray = $this->xml2Array($response);

        if(isset($responseArray['queue-answer']['status']['code']) && $responseArray['queue-answer']['status']['code'] == 0){
            $this->hash = $responseArray['queue-answer']['params']['hash'];
            $this->downloadUrl = $responseArray['queue-answer']['params']['downloadUrl'];
        }

        $this->url = self::URL;
        return $response;
    }

    /**
     * getProgress
     * Provide process status for created instance or you can manually check status for specific hash.
     *
     * @param string $hash Hash value of process which you want to check status.
     * @return string xml response string from server.
     */
    public function getProgress($hash=null)
    {
        if(strlen($this->hash) < 1 && $hash === null){
            throw new Exception('Get Progress: Hash not found.');
        }
        $data['apiKey'] = $this->apiKey;
        $data['hash'] = ($hash !== null)?$hash:$this->hash;
        return $this->apiCall('queue-status', array('queue' => $data));
    }

    /**
     * deleteFile
     * Delete file from server after process or you can manually delete for specific hash.
     *
     * @param string $hash Hash value of process which you want to delete.
     * @return string xml response string from server.
     */
    public function deleteFile($hash=null)
    {
        if(strlen($this->hash) < 1 && $hash === null){
            throw new Exception('Delete File: Hash not found.');
        }
        $data['apiKey'] = $this->apiKey;
        $data['hash'] = ($hash !== null)?$hash:$this->hash;
        $data['method'] = 'deleteFile';
        return $this->apiCall('queue-manager', array('queue' => $data));
    }

    /**
     * createToken
     * Create one time token to use API.
     *
     * @return string xml response string from server.
     */
    public function createToken()
    {
        $data['apiKey'] = $this->apiKey;
        return $this->apiCall('request-token', array('queue' => $data));
    }

    /**
     * getServer
     * Get free api server information.
     *
     * @param string $targetType To which file you want to convert (like convert-to-jpg, convert-to-mp3)
     * @return string xml response string from server.
     */
    public function getServer($targetType)
    {
        return $this->apiCall('get-queue', array('queue' => array('apiKey' => $this->apiKey, 'targetType' => $targetType)));
    }

    /**
     * apiCall
     * Make an API call to server based on action and parameters.
     *
     * @param string $action API action name
     * @param array $xmlData Array of xml data
     * @return string xml response string from server.
     */
    private function apiCall($action, $xmlData)
    {
        $currentUrl = self::URL;
        if ($action != 'get-queue'){
            $this->getServer($this->targetTypeOptions[$this->targetType]);
        }

        $ch = curl_init($currentUrl."/".$action);
        $request['queue'] = $this->array2xml($xmlData, '<?xml version="1.0" encoding="UTF-8"?>');
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-type: multipart/form-data"));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
        $response = curl_exec($ch);

        curl_close($ch);
        return $response;
    }

    /**
     * array2Xml
     * Convert an Array to xml string.
     *
     * @param array $arr
     * @param string $xml
     * @return string
     */
    public function array2Xml($arr, $xml='')
    {
        foreach($arr as $key => $value){
            if(is_array($value)){
                $xml .= '<'.$key.'>';
                $xml = $this->array2Xml($value, $xml);
                $xml .= '</'.$key.'>';
            }else{
                $xml .= '<'.$key.'>'.$value.'</'.$key.'>';
            }
        }

        return $xml;
    }

    /**
     * xml2Array
     * Convert an xml string to array.
     *
     * @param string $xmlString
     * @return array
     */
    public function xml2Array($xmlString)
    {
        $xmlObj   = simplexml_load_string($xmlString);
        return array($xmlObj->getName() => json_decode(json_encode((array) $xmlObj), 1));
    }
}

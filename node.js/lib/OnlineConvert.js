
//Target type constant value for URL type.
var SOURCE_TYPE_URL = "URL";
// Target type constant value for FILE_BASE64 type.
var SOURCE_TYPE_FILE_BASE64 = 'FILE_BASE64';
// Target type constant value for FILE_PATH type.
var SOURCE_TYPE_FILE_PATH = 'FILE_PATH';

var EVENT_ON_DATA_GET = "dataget";
var EVENT_ON_DATA_FAIL = "datafail";

var OSC_EVENTS = {
    TOKEN: {GET: "token_created", FAIL: "token_fail"},
    SERVER: {GET: "server_get", FAIL: "server_fail"},
    FILE_DELETE: {GET: "file_get_deleted", FAIL: "file_get_fail"},
    PROGRESS: {GET: "progress_get", FAIL: "progress_fail"},
    API_CALL: {GET: "api_call_get", FAIL: "api_call_fail"},
    CONVERT: {GET: "convert_converted", FAIL: "convert_fail"}
};

function OnlineConvert() {

    var self = this;
    this.EVENT_ON_DATA_GET = EVENT_ON_DATA_GET;
    this.EVENT_ON_DATA_FAIL = EVENT_ON_DATA_FAIL;
    this.EVENTS = OSC_EVENTS;
    //Online Converter API URL
    this.URL = "http://api.online-convert.com";
    //Target type constant value for URL type.
    this.SOURCE_TYPE_URL = SOURCE_TYPE_URL;
    // Target type constant value for FILE_BASE64 type.
    this.SOURCE_TYPE_FILE_BASE64 = SOURCE_TYPE_FILE_BASE64;
    // Target type constant value for FILE_PATH type.
    this.SOURCE_TYPE_FILE_PATH = SOURCE_TYPE_FILE_PATH;
    /**@var string Online Converter API Key*/
    var _apiKey;
    /**@var boolean*/
    var _testMode;
    /**@var string*/
    var _url = this.URL;
    /**@var string*/
    var _targetType;
    /**@var string     */
    var _sourceType;
    /**@var string*/
    this.hash = "";
    /**@var string*/
    this.downloadUrl = "";
    /**
     * @var array
     */
    var _targetTypeOptions = {
        'convert-to-7z': 'archive', 'convert-to-bz2': 'archive', 'convert-to-gz': 'archive', 'convert-to-zip': 'archive', 'convert-to-aac': 'audio', 'convert-to-aiff': 'audio', 'convert-to-flac': 'audio', 'convert-to-m4a': 'audio',
        'convert-to-mp3': 'audio', 'convert-to-ogg': 'audio', 'convert-to-opus': 'audio', 'convert-to-wav': 'audio', 'convert-to-wma': 'audio', 'convert-to-doc': 'document', 'convert-to-docx': 'document', 'convert-to-flash': 'document',
        'convert-to-html': 'document', 'convert-to-odt': 'document', 'convert-to-pdf': 'document', 'convert-to-ppt': 'document', 'convert-to-rtf': 'document', 'convert-to-txt': 'document', 'convert-to-azw3': 'ebook',
        'convert-to-epub': 'ebook', 'convert-to-fb2': 'ebook', 'convert-to-lit': 'ebook', 'convert-to-lrf': 'ebook', 'convert-to-mobi': 'ebook', 'convert-to-pdb': 'ebook', /*    'convert-to-pdf' : 'ebook',*/
        'convert-to-tcr': 'ebook', 'convert-to-bmp': 'image', 'convert-to-jpg': 'image', 'convert-to-png': 'image', 'convert-to-mp4': 'video', 'convert-to-wmv': 'video'
    };
    /**
     * @var array
     */
    var _sourceTypeOptions = {
        'URL': 'URL',
        'FILE_BASE64': 'FILE_BASE64',
        'FILE_PATH': 'FILE_PATH'
    };
    /*
     * 
     * @param string $apiKey
     * @param boolean $testMode
     * @returns OnlineConvert
     */
    this.create = function ($apiKey, $testMode) {
        var oc = new OnlineConvert();
        _apiKey = $apiKey;
        _testMode = $testMode;
        return oc;
    };

    /**
     * 
     * @param {type} $targetType
     * @returns {OnlineConvert@call;apiCall}
     */
    this.getServer = function ($targetType) {
        if(!$targetType){
            throw new Error("Target type should be not null.");
        }
        var xmlData = {queue: {'apiKey': _apiKey, 'targetType': $targetType}};
        return this.apiCall('get-queue', xmlData, self.EVENTS.SERVER);
    };

    /**
     * createToken
     * Create one time token to use API.
     *
     * @return string xml response string from server.
     */
    this.createToken = function () {
        var xmlData = {queue: {'apiKey': _apiKey}};
        return this.apiCall('request-token', xmlData, self.EVENTS.TOKEN);
    };

    /**
     * deleteFile
     * Delete file from server after process or you can manually delete for specific hash.
     *
     * @param string $hash Hash value of process which you want to delete.
     * @return string xml response string from server.
     */
    this.deleteFile = function ($hash) {

        if (self.hash.length < 1 && $hash === undefined) {
            throw new Error("Delete File: Hash not found.");
        }
        var xmlData = {queue: {'apiKey': _apiKey, 'hash': ($hash !== undefined) ? $hash : self.hash, 'method': 'deleteFile'}};
        return this.apiCall('queue-manager', xmlData, self.EVENTS.FILE_DELETE);
    }

    /**
     * getProgress
     * Provide process status for created instance or you can manually check status for specific hash.
     *
     * @param string $hash Hash value of process which you want to check status.
     * @return string xml response string from server.
     */
    this.getProgress = function ($hash)
    {
        if (self.hash.length < 1 && $hash === undefined) {
            throw new Error('Get Progress: Hash not found.');
        }
        var xmlData = {queue: {'apiKey': _apiKey, 'hash': ($hash !== undefined) ? $hash : self.hash}};
        return this.apiCall('queue-status', xmlData, self.EVENTS.PROGRESS);
    }

    /**
     * 
     * @param string $xmlString
     * @returns object
     */
    this.getXML2Object = function ($xmlString) {
        var parseString = require('xml2js').parseString;
        var xmlObject;
        parseString($xmlString, function (err, result) {
            xmlObject = result;
        });
        return  xmlObject;
    };
    /**
     * 
     * @param object $object
     * @returns string xmlString
     */
    this.getObject2XML = function ($object) {
        var fs = require('fs'),
                xml2js = require('xml2js');
        var builder = new xml2js.Builder();
        var xml = builder.buildObject($object);
        return xml;
    };
    /**
     * 
     * @param {type} $action
     * @param {type} $xmlData
     * @returns {Number}
     */
    this.apiCall = function ($action, $xmlData, $fireEvent) {

        var http = require("http");
        var querystring = require('querystring');

        if ($action !== "get-queue" && _targetType) {
            this.getServer(_targetTypeOptions[_targetType], self.EVENTS.SERVER);
        }


        var queryData = {queue: this.getObject2XML($xmlData)};
        var postData = querystring.stringify(queryData);
        var options = {
            host: "api.online-convert.com",
            port: 80,
            path: '/' + $action,
            method: 'POST',
            headers: {
                'Content-type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        var req = http.request(options, function (res) {
            res.setEncoding('utf8');
            res.on('data', function (chunk) {
                self.emit($fireEvent.GET, chunk);
            });
        });

        req.on('error', function (e) {
            self.emit($fireEvent.FAIL);
        });

        req.write(postData);
        req.end();

    };

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
    this.convert = function ($targetType, $sourceType, $source, $sourceName, $sourceOptions, $notificationUrl)
    {
        if (!_targetTypeOptions[$targetType]) {
            throw new Error('Invalid Target Type.');
        }

        _targetType = $targetType;
        if (!_sourceTypeOptions[$sourceType]) {
            throw new Error('Invalid Source Type.');
        }

        _sourceType = $sourceType;

        if (_sourceType === self.SOURCE_TYPE_FILE_BASE64 || _sourceType === self.SOURCE_TYPE_FILE_PATH) {
            if ($sourceName === undefined || $sourceName.length < 1) {
                throw new Error('Invalid Source Name.');
            }
        }


        var base64data;

        if (_sourceType === self.SOURCE_TYPE_FILE_PATH) {

            var fs = require('fs');

            if (!fs.existsSync($source)) {
                throw new Error('File not found: '.$source);
            }

            base64Image($source);
            function base64Image(src) {
                var data = fs.readFileSync(src);
                if (!data) {
                    throw new Error('File not found: '.$source);
                }
                data = data.toString("base64");
                base64data =data;

            }

        }


        var xmlData = {'queue': {
                'apiKey': _apiKey,
                'targetType': _targetTypeOptions[$targetType],
                'targetMethod': $targetType,
                'testMode': _testMode,
                'notificationUrl': $notificationUrl === undefined ? "" : $notificationUrl
            }
        }


        if (_sourceType === self.SOURCE_TYPE_URL) {
            xmlData.queue.sourceUrl = $source;
        } else {
            xmlData.queue.file = {
                fileName: $sourceName,
                fileData: base64data
            };
        }


        if ($sourceOptions !== undefined) {
            xmlData.queue.format = $sourceOptions;
        }

        self.apiCall('queue-insert', xmlData, self.EVENTS.CONVERT);

        self.on(self.EVENTS.CONVERT.GET, function (data) {

            $responseArray = self.getXML2Object(data);

            if ($responseArray['queue-answer'].status[0].code[0] && $responseArray['queue-answer'].status[0].code[0] == 0) {
                self.hash = $responseArray['queue-answer'].params[0].hash[0];
                self.downloadUrl = $responseArray['queue-answer'].params[0].downloadUrl[0];
            }

            self.url = self.URL;

        });

        self.on(self.EVENTS.CONVERT.FAIL, function () {
            throw new Error("Error occured");
        });

    }

    return this;
}
;
var util = require('util'),
        EventEmitter = require('events').EventEmitter;
util.inherits(OnlineConvert, EventEmitter);

exports = module.exports = new OnlineConvert();

exports.SOURCE_TYPE_URL = SOURCE_TYPE_URL;
exports.SOURCE_TYPE_FILE_BASE64 = SOURCE_TYPE_FILE_BASE64;
exports.SOURCE_TYPE_FILE_PATH = SOURCE_TYPE_FILE_PATH;
exports.EVENTS = OSC_EVENTS;

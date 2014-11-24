#
# OnlineConvert Class
#
# API class for www.online-convert.com service.
# 
# Version::   1.0
# License::   Distributes under The MIT License

__date__ ="$Sep 4, 2014 12:36:41 PM$"

class OnlineConvert:
   
    #Online Converter API URL
    URL = 'http://api.online-convert.com';

    #Target type constant value for URL type.
    SOURCE_TYPE_URL = 'URL';

    #Target type constant value for FILE_BASE64 type.
    SOURCE_TYPE_FILE_BASE64 = 'FILE_BASE64';
    
    #Target type constant value for FILE_PATH type.
    SOURCE_TYPE_FILE_PATH = 'FILE_PATH';
    
    #@var string Online Converter API Key
    __apiKey="";

    #@var boolean
    __testMode=True;

    #@var string
    __url =  "" ;

    #@var string
    __targetType="";

    #@var string
    __sourceType="";

    #@var string
    hash="";

    #@var string
    downloadUrl="";

    #@var array
    __targetTypeOptions ={
        'convert-to-7z' : 'archive',
        'convert-to-bz2' : 'archive',
        'convert-to-gz' : 'archive',
        'convert-to-zip' : 'archive',
        'convert-to-aac' : 'audio',
        'convert-to-aiff' : 'audio',
        'convert-to-flac' : 'audio',
        'convert-to-m4a' : 'audio',
        'convert-to-mp3' : 'audio',
        'convert-to-ogg' : 'audio',
        'convert-to-opus' : 'audio',
        'convert-to-wav' : 'audio',
        'convert-to-wma' : 'audio',
        'convert-to-doc' : 'document',
        'convert-to-docx' : 'document',
        'convert-to-flash' : 'document',
        'convert-to-html' : 'document',
        'convert-to-odt' : 'document',
        'convert-to-pdf' : 'document',
        'convert-to-ppt' : 'document',
        'convert-to-rtf' : 'document',
        'convert-to-txt' : 'document',
        'convert-to-azw3' : 'ebook',
        'convert-to-epub' : 'ebook',
        'convert-to-fb2' : 'ebook',
        'convert-to-lit' : 'ebook',
        'convert-to-lrf' : 'ebook',
        'convert-to-mobi' : 'ebook',
        'convert-to-pdb' : 'ebook',
        'convert-to-pdf' : 'ebook',
        'convert-to-tcr' : 'ebook',
        'convert-to-bmp' : 'image',
        'convert-to-jpg' : 'image',
        'convert-to-png' : 'image',
        'convert-to-mp4' : 'video',
        'convert-to-wmv' : 'video'
    }

    #@var array
    __sourceTypeOptions = {}
    
    def __init__(self,apiKey,testMode=True,targetType=""):
        self.__sourceTypeOptions={
            self.SOURCE_TYPE_URL : 'URL',
            self.SOURCE_TYPE_FILE_BASE64 : 'FILE_BASE64',
            self.SOURCE_TYPE_FILE_PATH : 'FILE_PATH'
            }
            
        self.__apiKey = apiKey
        self.__testMode = testMode
        self.__targetType=targetType;
        self.__url=self.URL;
    
    def xml2Dic(self,xmlString):
        import lxml.etree as et
        root=et.fromstring(xmlString)
        dic={"queue-answer":{}}
        params={"params":{}}
        status={"status":{}}
        
        for child in root:
            for subchild in child:
                if child.tag=="params":
                    params["params"].update({ subchild.tag : subchild.text})
                if child.tag=="status":
                    status["status"].update({ subchild.tag : subchild.text})
            
        dic["queue-answer"].update(params)
        dic["queue-answer"].update(status)
        return dic
    
    def dic2Xml(self,xmlDic):
        xml="";
        for child in xmlDic:
            if child=="file":
               xml+="<file>"
               for sub in xmlDic.get(child):
                  xml+="<"+sub+">"+xmlDic.get(child).get(sub)+"</"+sub+">"
               xml+="</file>"
            else:
                xml+="<"+child+">"+xmlDic.get(child)+"</"+child+">"
        return xml
    
    def getServer(self,targetType):
        return self.apiCall('get-queue',{'apiKey': self.__apiKey,'targetType': targetType });
    
    def createToken(self):
        return self.apiCall('request-token',{'apiKey' : self.__apiKey });
    
    def deleteFile(self, hash=""):
        if len(self.hash) < 1 and hash == "":
            raise 'Delete File: Hash not found.'
        
        if hash!="":
            hash = hash
        else:
            hash=self.hash
        
        data={'apiKey':self.__apiKey,'hash': hash, 'method': 'deleteFile' }
        
        return self.apiCall('queue-manager',data);
     
    def getProgress(self, hash=""):
        if len(self.hash) < 1 and hash == "":
            raise 'Get Progress: Hash not found.'
        
        if hash!="":
            hash = hash
        else:
            hash=self.hash
        
        data={'apiKey':self.__apiKey,'hash': hash }
         
        return self.apiCall('queue-status',data);
    
            
    def apiCall(self,action,xmlData):
        import urllib2
        import urllib

        if action != 'get-queue':
             self.getServer(self.__targetTypeOptions[self.__targetType]);

        url = self.URL+"/"+action
        
        opener = urllib2.build_opener();
        opener.addheaders=[('Content-type','multipart/form-data')]

        params ={'queue':'<?xml version="1.0" encoding="UTF-8"?><queue>'+ self.dic2Xml(xmlData)+'</queue>'};
        
        
        params = urllib.urlencode(params) 
        response=opener.open(url,params);
        data = response.read()

        #response = urlopen(url, params)
        #data = response.read()

        return data;#requests.post(url, params=params, data=json.dumps(data), headers=headers)    
    
    def convert(self, targetType, sourceType, source, sourceName="", sourceOptions="", notificationUrl=""):
        
        if(not self.__targetTypeOptions.has_key(targetType)):
            raise 'Invalid Target Type.'
        
        self.__targetType = targetType

        if(not self.__sourceTypeOptions.has_key(sourceType)):
            raise 'Invalid Source Type.'
        
        self.__sourceType = sourceType
        
        if self.__sourceType == self.SOURCE_TYPE_FILE_BASE64 or self.__sourceType == self.SOURCE_TYPE_FILE_PATH:
            if sourceName == "" or len(sourceName) < 1:
                raise 'Invalid Source Name.'
        
      
        if self.__sourceType == self.SOURCE_TYPE_FILE_PATH:
            import os.path
            if not os.path.isfile(source):
                raise 'File not found: ' + source
            import base64
            with open(source, "rb") as file:
                    encoded_string = base64.b64encode(file.read())
            source = encoded_string
        
        data={'apiKey' : self.__apiKey,
            'targetType': self.__targetTypeOptions[targetType],
            'targetMethod' : targetType,
            'testMode' : str(self.__testMode),
            'notificationUrl': notificationUrl
            }   
            
        if self.__sourceType == self.SOURCE_TYPE_URL:
            data.update({'sourceUrl': source})
        else:
            file={'file':{ 'fileName': sourceName, 'fileData':source  }}
            data.update(file)
        
        if sourceOptions != "":
            data.update({'format': sourceOptions})
        
        response = self.apiCall('queue-insert', data)
        responseArray = self.xml2Dic(response)
       
        if responseArray['queue-answer']['status']['code'] == '0' :
            self.hash = responseArray['queue-answer']['params']['hash']
            self.downloadUrl = responseArray['queue-answer']['params']['downloadUrl']
        
        self.url = self.URL
        return response
   
       
   

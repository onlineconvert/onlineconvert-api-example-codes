#
# OnlineConvert Class
#
# API class for www.online-convert.com service.
# 
# Version::   1.0
# Author::    NIRAV RANPARA  (mailto:nirav.programmer@gmail.com)
# Copyright:: Copyright (c) 2002 The Pragmatic Programmers, LLC
# License::   Distributes under The MIT License

class OnlineConvert
  
  #Online Converter API URL
  URL = "http://api.online-convert.com"

  #Source type constant value for URL type.
  SOURCE_TYPE_URL = "URL"

  #Source type constant value for FILE_BASE64 type.
  SOURCE_TYPE_FILE_BASE64 = "FILE_BASE64"

  #Source type constant value for FILE_PATH type.
  SOURCE_TYPE_FILE_PATH ="FILE_PATH"
  
  #@var string Online Converter API Key
  @@_api_key="";

  #@var boolean
  @@_test_mode=false;
  
  #@var string
  @@_url=URL;

  #@var string
  @@_target_type="";
  
  #@var string
  @@_source_type="";

  #@var string
  @@hash="";

  #@var string
  @@download_url="";

  @@_target_type_options={
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
    #'convert-to-pdf' => 'document',
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
    'convert-to-jpg' => 'image',
    'convert-to-png' => 'image',
    'convert-to-mp4' => 'video',
    'convert-to-wmv' => 'video'}
  
  #@var array
  @@_source_type_options ={
    SOURCE_TYPE_URL => 'URL',
    SOURCE_TYPE_FILE_BASE64 => 'FILE_BASE64',
    SOURCE_TYPE_FILE_PATH => 'FILE_PATH'
  }

  def initialize
      
  end
  
=begin
  create
  Create instance and set required parameters.
     
  @param string $apiKey
  @param string $testMode
  @return self
=end
  def self.create(api_key,test_mode)
    obj=self.new();
    @@_api_key,@@_test_mode=api_key,test_mode
    return obj;
  end

  

=begin
     Make a API call to convert file/url/hash based on parameters and return xml response.
     
     @param string target_type_method To which file you want to convert (like convert-to-jpg, convert-to-mp3)
     @param string source_type 3 source types you can set (URL, FILE_PATH and FILE_BASE64)
     @param string source Source can be provide based on sourceType if sourceType = URL you have to provide url string to this param.
     @param string source_name Provide file Name. This param used only with sourceType = FILE_PATH or FILE_BASE64
     @param string source_options Provide file conversion required extra parameters as array using this param.
     @param string notification_url For set notification url for api actions.
=end
  def convert(target_type_method, source_type, source, source_name=nil, source_options=nil, notification_url=nil)
    
    if !@@_target_type_options.has_key?(target_type_method)
      raise "Invalid Target Type."
    end 
        
    @@_target_type =@@_target_type_options[target_type_method]

    if !@@_source_type_options.has_key?(source_type)
      raise "Invalid Source Type."
    end
        
    @@_source_type = source_type

    if @@_source_type == SOURCE_TYPE_FILE_BASE64 or @@_source_type == SOURCE_TYPE_FILE_PATH
      if source_name === nil || source_name.length < 1
        raise "Invalid Source Name."
      end
    end
    
    if @@_source_type == SOURCE_TYPE_FILE_PATH
      if !File.exist?(source)
        raise "File not found:"+source
      end
      require 'base64'
      source = Base64.encode64(open(source) { |io| io.read });
    end
    
    data={"apiKey"=>@@_api_key,
      "targetType"=>@@_target_type_options[target_type_method],
      "targetMethod" => target_type_method,
      "testMode" =>@@_test_mode,
      "notificationUrl" => notification_url
    }

    if @@_source_type == SOURCE_TYPE_URL
      data['sourceUrl'] = source
    else 
      file={"file"=>{ "fileName"=>source_name, "fileData"=>source }}
      data=data.merge(file)
    end

    if source_options != nil
      data['format'] = source_options
    end
       
    response = api_call('queue-insert',data)
    response_array = xml_to_array(response)
    
    if response_array['queue_answer']['status']['code'] == '0'     
      @@hash = response_array['queue_answer']['params']['hash'];
      @@download_url = response_array['queue_answer']['params']['downloadUrl'];
    end
    @@_url =URL;
    return response;
  end
  
  
=begin
    Make an API call to server based on action and parameters.
    @param string action API action name
    @param array xmlData Array of xml data
    @return string xml response string from server.
=end
  def api_call(action, xml_data)
    require 'net/http'
    require 'uri'
    current_url = URL;
    if action != 'get-queue'
      get_server(@@_target_type_options[@@_target_type]);
    end
    uri = URI.parse(current_url+"/"+action)
    http = Net::HTTP.new(uri.host,uri.port)
    request=Net::HTTP::Post.new(uri.request_uri);
    request.set_form_data({ "queue"=> array_to_xml(xml_data,"")})
    return http.request(request).body
  end
 
=begin
     * getProgress
     * Provide process status for created instance or you can manually check status for specific hash.
     *
     * @param string $hash Hash value of process which you want to check status.
     * @return string xml response string from server.
=end
  def get_progress(hash=nil)
    
    if @@hash.length < 1 and hash == nil
      raise "Get Progress: Hash not found."
    end
    
    return api_call('queue-status',{"apiKey"=>@@_api_key,"hash"=>(hash!=nil)?hash:@@hash })
  end


=begin
     * deleteFile
     * Delete file from server after process or you can manually delete for specific hash.
     *
     * @param string $hash Hash value of process which you want to delete.
     * @return string xml response string from server.
=end
  def delete_file(hash=nil)
    if @@hash.length < 1 && hash === nil 
      raise "Delete File: Hash not found."
    end
    return api_call('queue-manager',{"apiKey"=>@@_api_key,"hash"=>(hash!=nil)?hash:@@hash, "method"=>"deleteFile" });
  end
  
  
=begin
      Get free api server information.
     
      @param string $targetType To which file you want to convert (like convert-to-jpg, convert-to-mp3)
      @return string xml response string from server.
=end
  def get_server(target_type)
    return api_call('get-queue',{'apiKey' => @@_api_key,'targetType' => target_type});
  end
    
=begin
     Create one time token to use API.
     @return string xml response string from server.
=end
  def create_token
    return api_call('request-token',{"apiKey"=> @@_api_key });
  end
  
=begin
      Convert an array to xml string.
      @param array $arr
      @param string $xml
      @return string
=end
  def array_to_xml(hash, xml)
    require "active_support/core_ext"
    return hash.to_xml(:root => 'queue')
  end
  
  
=begin  
     Convert an xml string to array.
     @param string $xmlString
     @return array
=end
  def xml_to_array(xml_string)
    return  Hash.from_xml(xml_string)
  end
   
=begin  
     To get hash value of job
     @return string
=end  
  def get_hash()
    return @@hash;
  end

=begin  
     To get download url of inserted job
     @return string
=end    
  def get_download_url()
    return @@download_url;
  end
    
end

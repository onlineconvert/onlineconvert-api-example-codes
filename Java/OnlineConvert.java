package onlineconverter;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * OnlineConvert Class
 *
 * API class for www.online-convert.com service.
 *
 * This scripts are licensed under MIT license.
 *
 * @version 1.0
 * @link  http://api.online-convert.com/
 */
public class OnlineConvert {

    /**
     * Constant to get position of status node value from List Object return
     * from getXML2Map()
     */
    public final static int QUEUE_ANSWER_STATUS = 0;

    /**
     * Constant to get position of params node value from List Object return
     * from getXML2Map()
     */
    public final static int QUEUE_ANSWER_PARAMS = 1;

    /**
     * Consttant to set postition of comman params in List Object for argument
     * of apiCall()
     */
    public final static int QUEUE_COMMAN_PARAMS = 0;

    /**
     * Consttant to set postition of file params in List Object for argument of
     * apiCall()
     */
    public final static int QUEUE_FILE_METADATA_PARAMS = 1;

    /**
     * Online Converter API URL
     */
    public static final String URL = "http://api.online-convert.com";

    /**
     * Source type constant value for TYPE_URL
     */
    public static final String SOURCE_TYPE_URL = "URL";

    /**
     * Source type constant value for FILE_BASE64 type
     */
    public static final String SOURCE_TYPE_FILE_BASE64 = "FILE_BASE64";

    /**
     * Source type constant value for FILE_PATH type
     */
    public static final String SOURCE_TYPE_FILE_PATH = "FILE_PATH";

    /**
     * Used to store apiKey of the user
     */
    private String apiKey;

    /**
     * Used to set api call is for testing or not
     */
    private boolean testMode;

    /**
     * Used to store base api url
     */
    private String url = "";

    /**
     * Store desire file conversion e.g audio,video,etc...
     */
    private String targetType;

    /**
     * Store source type of file i.e one of the URL, FILE_PATH, FILE_BASE64
     */
    private String sourceType;

    /**
     * Store unique identification for the file on server queue
     */
    private String hash;

    /**
     * Uri link from where file can be downloaded
     */
    private String downloadUrl;

    /**
     * Map object to store targetTypeOptions for possible file type conversion
     */
    private final Map<String, String> targetTypeOptions;

    /**
     * Map object to store sourcetypeOption for the file source
     */
    private final Map<String, String> sourceTypeOptions;

    /**
     * Initialization of possible conversion methods and types
     *
     * @return void
     */
    private void setTargetTypeOptions() {

        this.targetTypeOptions.put("convert-to-7z", "archive");
        this.targetTypeOptions.put("convert-to-bz2", "archive");
        this.targetTypeOptions.put("convert-to-gz", "archive");
        this.targetTypeOptions.put("convert-to-zip", "archive");

        this.targetTypeOptions.put("convert-to-aac", "audio");
        this.targetTypeOptions.put("convert-to-aiff", "audio");
        this.targetTypeOptions.put("convert-to-flac", "audio");
        this.targetTypeOptions.put("convert-to-m4a", "audio");
        this.targetTypeOptions.put("convert-to-mp3", "audio");
        this.targetTypeOptions.put("convert-to-ogg", "audio");
        this.targetTypeOptions.put("convert-to-opus", "audio");
        this.targetTypeOptions.put("convert-to-wav", "audio");
        this.targetTypeOptions.put("convert-to-wma", "audio");

        this.targetTypeOptions.put("convert-to-doc", "document");
        this.targetTypeOptions.put("convert-to-docx", "document");
        this.targetTypeOptions.put("convert-to-flash", "document");
        this.targetTypeOptions.put("convert-to-html", "document");
        this.targetTypeOptions.put("convert-to-odt", "document");
        this.targetTypeOptions.put("convert-to-pdf", "document");
        this.targetTypeOptions.put("convert-to-ppt", "document");
        this.targetTypeOptions.put("convert-to-rtf", "document");
        this.targetTypeOptions.put("convert-to-txt", "document");

        this.targetTypeOptions.put("convert-to-azw3", "ebook");
        this.targetTypeOptions.put("convert-to-epub", "ebook");
        this.targetTypeOptions.put("convert-to-fb2", "ebook");
        this.targetTypeOptions.put("convert-to-lit", "ebook");
        this.targetTypeOptions.put("convert-to-lrf", "ebook");
        this.targetTypeOptions.put("convert-to-mobi", "ebook");
        this.targetTypeOptions.put("convert-to-pdb", "ebook");
        this.targetTypeOptions.put("convert-to-pdf", "ebook");
        this.targetTypeOptions.put("convert-to-tcr", "ebook");

        this.targetTypeOptions.put("convert-to-bmp", "image");
        this.targetTypeOptions.put("convert-to-eps", "image");
        this.targetTypeOptions.put("convert-to-gif", "image");
        this.targetTypeOptions.put("convert-to-exr", "image");
        this.targetTypeOptions.put("convert-to-ico", "image");
        this.targetTypeOptions.put("convert-to-jpg", "image");
        this.targetTypeOptions.put("convert-to-png", "image");
        this.targetTypeOptions.put("convert-to-svg", "image");
        this.targetTypeOptions.put("convert-to-tga", "image");
        this.targetTypeOptions.put("convert-to-tiff", "image");
        this.targetTypeOptions.put("convert-to-wbmp", "image");
        this.targetTypeOptions.put("convert-to-webp", "image");

        this.targetTypeOptions.put("convert-to-3g2", "video");
        this.targetTypeOptions.put("convert-to-3gp", "video");
        this.targetTypeOptions.put("convert-to-avi", "video");
        this.targetTypeOptions.put("convert-to-flv", "video");
        this.targetTypeOptions.put("convert-to-mkv", "video");
        this.targetTypeOptions.put("convert-to-mov", "video");
        this.targetTypeOptions.put("convert-to-mp4", "video");
        this.targetTypeOptions.put("convert-to-mpeg-1", "video");
        this.targetTypeOptions.put("convert-to-mpeg-2", "video");
        this.targetTypeOptions.put("convert-to-ogg", "video");
        this.targetTypeOptions.put("convert-to-webm", "video");
        this.targetTypeOptions.put("convert-to-wmv", "video");
        this.targetTypeOptions.put("convert-video-for-android", "video");
        this.targetTypeOptions.put("convert-video-for-blackberry", "video");
        this.targetTypeOptions.put("convert-video-for-ipad", "video");
        this.targetTypeOptions.put("convert-video-for-iphone", "video");
        this.targetTypeOptions.put("convert-video-for-ipod", "video");
        this.targetTypeOptions.put("convert-video-for-nintendo-3ds", "video");
        this.targetTypeOptions.put("convert-video-for-nintendo-ds", "video");
        this.targetTypeOptions.put("convert-video-for-ps3", "video");
        this.targetTypeOptions.put("convert-video-for-psp", "video");
        this.targetTypeOptions.put("convert-video-for-wii", "video");
        this.targetTypeOptions.put("convert-video-for-xbox", "video");

    }

    /**
     * Initialization of possible file source options
     *
     * @return void
     */
    private void setSourceTypeOptions() {
        this.sourceTypeOptions.put(SOURCE_TYPE_URL, "URL");
        this.sourceTypeOptions.put(SOURCE_TYPE_FILE_BASE64, "FILE_BASE64");
        this.sourceTypeOptions.put(SOURCE_TYPE_FILE_PATH, "FILE_PATH");
    }

    /**
     * private constructor to avoid too many intances of OnlineConvert class
     *
     * @return void
     */
    private OnlineConvert() {
        this.targetTypeOptions = new HashMap<>();
        this.sourceTypeOptions = new HashMap<>();
        this.setSourceTypeOptions();
        this.setTargetTypeOptions();
    }

    /**
     * this method is used to create instance of OnlineConvert class and
     * intialize basic parameters
     *
     * @param apiKey user apikey which is get from
     * https://www.online-convert.com/signup/api after registration
     * @param testMode is api call for testing or not, set to false for
     * production
     * @return OnlineConvert
     * @throws IllegalArgumentException when apiKey is null or empty
     */
    public static OnlineConvert create(String apiKey, boolean testMode) {
        if (apiKey == null || apiKey.isEmpty()) {
            throw new IllegalArgumentException("apiKey key should not be empty or null.");
        }
        OnlineConvert oc = new OnlineConvert();
        oc.apiKey = apiKey;
        oc.testMode = testMode;
        return oc;
    }

    /**
     *
     * convert Make a API call to convert file/url/hash based on parameters and
     * return xml response.
     *
     * @param targetTypeMethod To which file you want to convert (like convert-to-jpg,
     * convert-to-mp3)
     * @param sourceType The source types you can set (URL, FILE_PATH and
     * FILE_BASE64)
     * @param source Source can be provide based on sourceType if sourceType =
     * URL you have to provide url string to this param.
     * @param sourceName Provide file Name. This param used only with
     * sourceType= FILE_PATH or FILE_BASE64
     * @param formatOptions Provide file conversion required extra parameters as
     * array using this param.
     * @param notificationUrl For set notification url for api actions.
     * @return xml response string from server.
     * @throws java.lang.Exception when required values of variables not found
     * in an Instance of class or in the arguments
     */
    public String convert(String targetTypeMethod, String sourceType, String source, String sourceName, Map<String, String> formatOptions, String notificationUrl) throws Exception {
        if (null == this.targetTypeOptions.get(targetTypeMethod)) {
            throw new Exception("Invalid Target Type.");
        }

        this.targetType = this.targetTypeOptions.get(targetTypeMethod);

        if (null == this.sourceTypeOptions.get(sourceType)) {
            throw new Exception("Invalid Source Type.");
        }

        this.sourceType = sourceType;

        if (SOURCE_TYPE_FILE_BASE64.equals(this.sourceType) || SOURCE_TYPE_FILE_PATH.equals(this.sourceType)) {
            if (source == null || source.length() < 1) {
                throw new Exception("Invalid Source Name.");
            }
        }

        if (this.sourceType.equals(SOURCE_TYPE_FILE_PATH)) {
            if (!new File(source).exists()) {
                throw new Exception("File not found: " + source);
            }
            Path path = Paths.get(source);
            source = Base64.getEncoder().encodeToString(Files.readAllBytes(path));
        }

        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("targetType", this.targetTypeOptions.get(targetTypeMethod));
        data.put("targetMethod", targetTypeMethod);
        data.put("testMode", (String.valueOf(this.testMode)));
        data.put("notificationUrl", notificationUrl);

        String formatOptionsXml = "";
        if (null != formatOptions) {
            formatOptionsXml = this.getFormatMap2XML(formatOptions);
        }

        String apiCallResponse;
        List response;

        if (this.sourceType.equals(OnlineConvert.SOURCE_TYPE_URL)) {
            data.put("sourceUrl", source);
            apiCallResponse = this.apiCall("queue-insert", data, formatOptionsXml);
        } else {
            List<Map> query = new ArrayList<>();
            Map<String, String> file = new HashMap<>();
            file.put("fileName", sourceName);
            file.put("fileData", source);
            query.add(OnlineConvert.QUEUE_COMMAN_PARAMS, data);
            query.add(OnlineConvert.QUEUE_FILE_METADATA_PARAMS, file);
            apiCallResponse = this.apiCall("queue-insert", query, formatOptionsXml);
        }

        response = this.getXML2Map(apiCallResponse);
        if (!response.isEmpty()) {
            Map responseStatus = (HashMap) response.get(OnlineConvert.QUEUE_ANSWER_STATUS);
            Map responseParams = (HashMap) response.get(OnlineConvert.QUEUE_ANSWER_PARAMS);
            if (Integer.parseInt(responseStatus.get("code").toString()) == 0) {
                this.hash = (String) responseParams.get("hash");
                this.downloadUrl = (String) responseParams.get("downloadUrl");
            }
        }

        this.url = OnlineConvert.URL;
        return apiCallResponse;
    }

    /**
     * getProgress Provide process status for created instance.
     *
     * @return string xml response string from server.
     * @throws java.lang.Exception when required value of hash variable not
     * found in Instance of class
     */
    public String getProgress() throws Exception {

        if (this.hash == null || this.hash.isEmpty()) {
            throw new Exception("Get Progress: Hash not found.");
        }

        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("hash", this.hash);

        return this.apiCall("queue-status", data, "");
    }

    /**
     * getProgress Provide process status,for specific hash.
     *
     * @param hash Hash value of process which you want to check status.
     * @return xml response string from server.
     */
    public String getProgress(String hash) {
        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("hash", hash);
        return this.apiCall("queue-status", data, "");
    }

    /**
     * deleteFile Delete file from server after process.
     *
     * @return xml response string from server.
     * @throws Exception when required value of hash variable not found in
     * Instance of class
     */
    public String deleteFile() throws Exception {
        if (this.hash == null || this.hash.isEmpty()) {
            throw new Exception("Delete File: Hash not found.");
        }
        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("hash", this.hash);
        data.put("method", "deleteFile");
        return this.apiCall("queue-manager", data, "");
    }

    /**
     * deleteFile Delete file from server manually using hase
     *
     * @param hash Hash value of process which you want to delete.
     * @return xml response string from server.
     */
    public String deleteFile(String hash) {
        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("hash", hash);
        data.put("method", "deleteFile");
        return this.apiCall("queue-manager", data, "");
    }

    /**
     * createToken Create one time token to use API.
     *
     * @return xml response string from server.
     */
    public String createToken() {
        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        return this.apiCall("request-token", data, "");
    }

    /**
     * getServer Get free api server information.
     *
     * @param targetType To which file you want to convert (like audio,video,etc...)
     * @return xml response string from server.
     */
    public String getServer(String targetType) {

        if (targetType == null) {
            throw new IllegalArgumentException("Get server : target type is null");
        }

        Map<String, String> data = new HashMap<>();
        data.put("apiKey", this.apiKey);
        data.put("targetType", targetType);
        return this.apiCall("get-queue", data, "");
    }

    /**
     * apiCall Make an API call to server based on action and parameters.
     *
     * @param action API action name
     * @param query  List Object of xml data
     * @param formatOptionXml xml string for extra format options
     * @return xml response string from server.
     */
    private String apiCall(String action, List query, String formatOptionXml) {

        String currentUrl = OnlineConvert.URL;
        String xmlResponse = "";

        /*if (!"get-queue".equals(action)) {
            this.getServer(this.targetTypeOptions.get(this.targetType));
        }*/

        try {
            URL browser = new URL(currentUrl + "/" + action);
            HttpURLConnection conn = (HttpURLConnection) browser.openConnection();

            String params = "queue=" + URLEncoder.encode(this.getMap2XML((Map) query.get(OnlineConvert.QUEUE_COMMAN_PARAMS), "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", formatOptionXml + this.getFileMap2XML((Map) query.get(OnlineConvert.QUEUE_FILE_METADATA_PARAMS))), "UTF-8");

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Content-Length", String.valueOf(params.length()));

            conn.setUseCaches(false);

            conn.setDoOutput(true);
            conn.setDoInput(true);
            OutputStream wr = conn.getOutputStream();
            wr.write(params.getBytes());
            wr.flush();

            // Get the response
            BufferedReader in;
            in = new BufferedReader(new InputStreamReader(conn.getInputStream()));

            String inputLine;
            StringBuilder response = new StringBuilder();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            xmlResponse = response.toString();
            wr.close();
            in.close();

        } catch (IOException e) {

        }

        return xmlResponse;
    }

    /**
     * apiCall Make an API call to server based on action and parameters.
     *
     * @param action API action name
     * @param query Map Object of xml data
     * @param formatOptionXml xml string for extra format options
     * @return xml response string from server.
     */
    private String apiCall(String action, Map query, String formatOptionXml) {

        String currentUrl = OnlineConvert.URL;
        String xmlResponse = "";

       /* if (!"get-queue".equals(action)) {
            this.getServer(this.targetTypeOptions.get(this.targetType));
        }*/

        try {
            URL browser = new URL(currentUrl + "/" + action);
            HttpURLConnection conn = (HttpURLConnection) browser.openConnection();

            String params = "queue=" + URLEncoder.encode(this.getMap2XML(query, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", formatOptionXml), "UTF-8");

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Content-Length", String.valueOf(params.length()));

            conn.setUseCaches(false);

            conn.setDoOutput(true);
            conn.setDoInput(true);
            OutputStream wr = conn.getOutputStream();

            wr.write(params.getBytes());
            wr.flush();

            // Get the response
            BufferedReader in;
            in = new BufferedReader(new InputStreamReader(conn.getInputStream()));

            String inputLine;
            StringBuilder response = new StringBuilder();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            xmlResponse = response.toString();
            wr.close();
            in.close();

        } catch (IOException e) {

        }

        return xmlResponse;
    }

    /**
     * getMap2XML Convert a Map object to xml string.
     *
     * @param query Map object which contains xml data
     * @param xmlDoc Xml doc string that you want to prepend into result string
     * @return xml string
     */
    public String getMap2XML(Map query, String xmlDoc) {

        String xmlString = xmlDoc + "<queue>";
        Iterator<Map.Entry<String, String>> entries = query.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry<String, String> entry = entries.next();
            xmlString += "<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">";
        }

        return xmlString + "</queue>";
    }

    /**
     * getMap2XML Convert a Map object to xml string.
     *
     * @param query Map object which contains xml data
     * @param xmlDoc Xml doc string that you want to prepend into result string
     * @param insertXmlInQueueNode xml string that you want to insert in between
     * the parent node
     * @return xml string
     */
    public String getMap2XML(Map query, String xmlDoc, String insertXmlInQueueNode) {

        String xmlString = xmlDoc + "<queue>";
        Iterator<Map.Entry<String, String>> entries = query.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry<String, String> entry = entries.next();
            xmlString += "<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">";
        }

        return xmlString + insertXmlInQueueNode + "</queue>";
    }

    /**
     * getMap2XML Convert a Map object into xml string
     *
     * @param query Map object you want to convert into xml string
     * @return xml string
     */
    public String getMap2XML(Map query) {
        String xmlString = "";
        Iterator<Map.Entry<String, String>> entries = query.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry<String, String> entry = entries.next();
            xmlString += "<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">";
        }

        return xmlString;
    }

    /**
     * getFileMap2XML Convert a Map object for file related parameters into xml
     *
     * @param query Map object of file parameters that you want to convert into
     * @return xml string
     */
    public String getFileMap2XML(Map query) {
        String xmlString = "<file>";
        Iterator<Map.Entry<String, String>> entries = query.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry<String, String> entry = entries.next();
            xmlString += "<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">";
        }

        return xmlString + "</file>";
    }

    /**
     * getFormatMap2XML Convert a Map object for format related parameters into
     * xml
     *
     * @param query Map object of file parameters that you want to convert into
     * @return xml string
     */
    public String getFormatMap2XML(Map query) {
        String xmlString = "<format>";
        Iterator<Map.Entry<String, String>> entries = query.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry<String, String> entry = entries.next();
            xmlString += "<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">";
        }

        return xmlString + "</format>";
    }

    /**
     * getXML2Map Convert server xml response string into List object
     *
     * @param xmlResponse xml response string from server
     * @return Map Object containing status and params Map object
     * @throws ParserConfigurationException when document builder fails to parse
     * configuration
     * @throws SAXException when document builder fails to build to dom
     * @throws IOException when document builder fails to build to dom
     */
    public List getXML2Map(String xmlResponse) throws ParserConfigurationException, SAXException, IOException {

        List<Map> listResponse = new ArrayList<>();
        Map<String, String> status = new HashMap<>();
        Map<String, String> params = new HashMap<>();

        //Get the DOM Builder Factory
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

        //Get the DOM Builder
        DocumentBuilder builder = factory.newDocumentBuilder();

        //Load and Parse the XML document
        //document contains the complete XML as a Tree.
        Document document = builder.parse(new InputSource(new StringReader(xmlResponse)));

        //Iterating through the nodes and extracting the data.
        NodeList nodeList = document.getDocumentElement().getChildNodes();

        for (int i = 0; i < nodeList.getLength(); i++) {

            Node node = nodeList.item(i);
            if (node instanceof Element) {
                NodeList childNodes = node.getChildNodes();
                for (int j = 0; j < childNodes.getLength(); j++) {
                    Node cNode = childNodes.item(j);
                    if (cNode instanceof Element && "status".equals(node.getNodeName())) {
                        status.put(cNode.getNodeName(), cNode.getTextContent());
                    }
                    if (cNode instanceof Element && "params".equals(node.getNodeName())) {
                        params.put(cNode.getNodeName(), cNode.getTextContent());
                    }
                }

                if ("status".equals(node.getNodeName())) {
                    listResponse.add(OnlineConvert.QUEUE_ANSWER_STATUS, status);
                }
                if ("params".equals(node.getNodeName())) {
                    listResponse.add(OnlineConvert.QUEUE_ANSWER_PARAMS, params);
                }

            }
        }

        return listResponse;
    }

  
    /**
     * To get hash value
     *
     * @return
     */
    public String getHash() {
        return hash;
    }

    /**
     * To get download url
     *
     * @return
     */
    public String getDownloadUrl() {
        return downloadUrl;
    }

}

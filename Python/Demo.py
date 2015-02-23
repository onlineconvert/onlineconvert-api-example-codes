#!/usr/bin/env python
#
# This file is released under the MIT License.
#
# This is an basic example of "API of www.online-convert.com", how to use in your application/website to convert
# your file to your desire file format.
#
# Link:: http://api.online-convert.com this file is available here to download.
#

__date__ ="$Sep 4, 2014 12:36:41 PM$"

import imp
import time

import urllib2
import shutil
import urlparse
import os

def download(url, fileName=None):
    def getFileName(url,openUrl):
        if 'Content-Disposition' in openUrl.info():
            # If the response has Content-Disposition, try to get filename from it
            cd = dict(map(
                lambda x: x.strip().split('=') if '=' in x else (x.strip(),''),
                openUrl.info()['Content-Disposition'].split(';')))
            if 'filename' in cd:
                filename = cd['filename'].strip("\"'")
                if filename: return filename
        # if no filename was found above, parse it out of the final URL.
        return os.path.basename(urlparse.urlsplit(openUrl.url)[2])

    r = urllib2.urlopen(urllib2.Request(url))
    try:
        fileName = fileName or getFileName(url,r)
        with open(fileName, 'wb') as f:
            shutil.copyfileobj(r,f)
    finally:
        r.close()


ocModule = imp.load_source('OnlineConvert', 'OnlineConvert.py')

oc=ocModule.OnlineConvert("ADD_YOUR_API_KEY_HERE", True, "convert-to-png");

print "Inserting job in server...\n\n";
print oc.convert("convert-to-png", ocModule.OnlineConvert.SOURCE_TYPE_FILE_PATH, "./spjobs.jpg", "spjobs.jpg");
print "\n\nJob Inserted in server...\n\n\n\n";

# give the converter some time to convert... :-P
time.sleep(5)

print "Getting inserted job status on server...\n\n";
response = oc.getProgress();
print response;
print "\n\nStatus of inserted job on server is above...\n\n\n\n";

responseArray = oc.xml2Dic(response);
directDownload = responseArray['queue-answer']['params']['directDownload'];

print "===================================================";
print "HASH:          "+ oc.hash;
print "Download URL:  "+ directDownload;
print "===================================================\n\n";


print "===================================================";
print "Now getting file...";

download(directDownload);

print "===================================================\n\n";

print "File downloaded, look in your actual working directory.";


print "\n\nNow deleting the file  from server...\n\n";
# Comment the following line if you want to download the converted file
print oc.deleteFile();
print "The file has been deleted from server...\n\n\n\n";

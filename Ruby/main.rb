#
# This file is released under the MIT License.
#
# This is an basic example of "API of www.online-convert.com", how to use in your application/website to convert
# your file to your desire file format.
#
# Link:: http://api.online-convert.com this file is available here to download.
#

require './online_convert'

oc=OnlineConvert.create("ENTER YOUR API KEY HERE",true);

puts "Inserting job in server...\n\n";
puts oc.convert("convert-to-jpg",OnlineConvert::SOURCE_TYPE_FILE_PATH,"./spjobs.jpg","spjobs.jpg");
puts "\n\nJob Inserted in server...\n\n\n\n";

puts "Getting inserted job status on server...\n\n";
puts oc.get_progress();
puts "\n\nStatus of inserted job on server is above...\n\n\n\n";

puts "===================================================\n";
puts "HASH :- #{oc.get_hash()}";
puts "Download URL  :- #{oc.get_download_url()}";
puts "===================================================\n\n";


puts "\n\nNow deleting the file  from server...\n\n";
puts oc.delete_file();
puts "The file has been deleted from server...\n\n\n\n";

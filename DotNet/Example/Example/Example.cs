using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Mime;
using OnlineConvert;

namespace Example
{
    public class Example
    {
        static void Main(String[] args) 
		{
            OnlineConvert.OnlineConvert oc = OnlineConvert.OnlineConvert.create("5a85b749d33340f592cbd5d6a3630908",true,"convert-to-png");

			var a = oc.convert("convert-to-png", "URL", "http://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Colonial_Williamsburg_%283205781804%29.jpg/100px-Colonial_Williamsburg_%283205781804%29.jpg", "a.png");
			var dica = oc.getXml2Dic(a);

			var directDownloadURL = "";
			Dictionary<int, Dictionary<string, string>> dicb = new Dictionary<int, Dictionary<string, string>>();

			if (dica[1].ContainsKey("hash") && dica[1]["hash"] != "") 
			{
				while (true) 
				{
					var b = oc.getProgress(dica[1]["hash"]);
					dicb = oc.getXml2Dic(b);
					if (dicb[2].ContainsKey("code") && dicb[2]["code"] == "100") 
					{
						break;
					}
					System.Threading.Thread.Sleep(5000);
				}
				directDownloadURL = dicb[1]["directDownload"];
			}

			if (directDownloadURL != "") 
			{
				using (WebClient Client = new WebClient ())
				{
					var webClient = new WebClient();
					webClient.OpenRead(directDownloadURL);

					string header_contentDisposition = webClient.ResponseHeaders["content-disposition"];
					string filename = new ContentDisposition(header_contentDisposition).FileName;

					filename = filename.Replace("\"", "");
					webClient.DownloadFile(directDownloadURL, filename);
				}
			}
        }
    }
}

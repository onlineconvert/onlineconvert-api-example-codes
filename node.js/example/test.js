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
var obj = require('../lib/OnlineConvert');

obj.create("YOUR API KEY HERE", true);
obj.createToken();

obj.on(obj.EVENTS.TOKEN.GET, function (data) {
    obj.convert("convert-to-png", obj.SOURCE_TYPE_FILE_PATH, "./spjobs.jpg", "spjobs.png");
});

obj.on(obj.EVENTS.CONVERT.GET, function (data) {
    process.nextTick(function () {
        obj.getProgress(obj.hash)
    });
});

obj.on(obj.EVENTS.PROGRESS.GET, function (data) {
    var xmlData = obj.getXML2Object(data);
    var code = xmlData['queue-answer'].status[0].code[0];
    var directDownload = "";
    if (code != "100") {
        process.nextTick(function () {
            obj.getProgress(obj.hash)
        });
    } else {
        directDownload = xmlData['queue-answer'].params[0].directDownload[0];
        var http = require('http');
        var fs = require('fs');
        var request = http.get(directDownload, function (response) {
            var nameHeader = response.headers["content-disposition"];
            var name = nameHeader.substring(nameHeader.indexOf('"') + 1, nameHeader.lastIndexOf('"'));
            var file = fs.createWriteStream(name);
            response.pipe(file);
        });
    }
});

obj.on(obj.EVENTS.FILE_DELETE.GET, function () {
    console.log("File deleted.");
});

obj.on(obj.EVENTS.CONVERT.FAIL, function () {
    console.log("File converting error.");
});

obj.on(obj.EVENTS.PROGRESS.FAIL, function () {
    console.log("File status getting fail.");
});

obj.on(obj.EVENTS.FILE_DELETE.FAIL, function () {
    console.log("File deleting fail.");
});


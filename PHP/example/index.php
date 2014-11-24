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
 * 
 * 
 * This is an basic example of "API of www.online-convert.com", how to use in your application/website to convert
 * your file to your desire file format.
 *
 * @link http://api.online-convert.com this file is available here to download.
 */

require_once __DIR__.'/../config.php';
require_once __DIR__.'/../OnlineConvert.class.php';

$OC = OnlineConvert::create(OC_API_KEY);

if (filter_input(INPUT_GET,"action",FILTER_SANITIZE_STRING)== "del") {
    $responseArray3 = $OC->xml2Array($OC->deleteFile(filter_input(INPUT_GET,'hash',FILTER_SANITIZE_STRING)));
    header('Location: index.php');
}

$message = array('ex1' => '', 'ex2' => '');
$debugXmlOutput=array();

if (filter_input(INPUT_SERVER,"REQUEST_METHOD",FILTER_SANITIZE_STRING) == 'POST') {
    switch (filter_input(INPUT_POST,"ex",FILTER_SANITIZE_STRING)) {
        case 1:
            try {
                $OC->convert(filter_input(INPUT_POST,"ex1_type",FILTER_SANITIZE_STRING),OnlineConvert::TARGET_TYPE_URL,  filter_input(INPUT_POST,"ex1_url",FILTER_SANITIZE_URL));
                $responseArray1 = $OC->xml2Array($OC->getProgress());

                while ($responseArray1['queue-answer']['status']['code'] >= 101 && $responseArray1['queue-answer']['status']['code'] <= 104) {
                    sleep(3);
                    $responseArray1 = $OC->xml2Array($OC->getProgress());
                }

                if (filter_input(INPUT_POST,"ex1_debug",FILTER_SANITIZE_STRING)) {
                  $debugXmlOutput=$OC->getProgress();
                }

            } catch (Exception $e) {
                echo $e;
                exit;
            }
            break;
        case 2:
            try {

        if (filter_var($_FILES["ex2_file"]["error"],FILTER_VALIDATE_INT) != 0) {
          $message['ex2'] = "File upload problem.";
          break;
        }
        if (!in_array(filter_var($_FILES["ex2_file"]["type"],FILTER_SANITIZE_STRING),array('image/png','image/jpg','image/jpeg','image/bmp'))) {
          $message['ex2'] = "Not valid file type.";
          break;
        }
                $OC->convert(filter_input(INPUT_POST,'ex2_type',FILTER_SANITIZE_STRING), OnlineConvert::TARGET_TYPE_FILE_PATH,  filter_var($_FILES["ex2_file"]["tmp_name"],FILTER_SANITIZE_STRING) , filter_var($_FILES["ex2_file"]["name"],FILTER_SANITIZE_STRING ) );
                $responseArray2 = $OC->xml2Array($OC->getProgress());

                while ($responseArray2['queue-answer']['status']['code'] >= 101 && $responseArray2['queue-answer']['status']['code'] <= 104) {
                    sleep(3);
                    $responseArray2 = $OC->xml2Array($OC->getProgress());
                }

                if (filter_input(INPUT_POST,"ex2_debug",FILTER_SANITIZE_STRING)) {
                    $debugXmlOutput=$OC->getProgress();
                }

            } catch (Exception $e) {
                echo $e;
                exit;
            }
            break;
    }
}

?>

<html>
    <head>
        <title>Online-Convert API Examples</title>
        <style>
            body{
                font-family: arial;
                font-size: 12px;
                line-height: 18px;
            }
            label{
                width: 100px;
                float: left;
            }
            code{
                font-family: monospace;
            }
        </style>
    </head>
    <body>
        <h2>[1] Example - Convert file types from URL</h2>
        <div>
            <form method="post" action="index.php" id="ex1" style="padding:20px;border:1px solid #ccc;">
		<span style="color:#ff0000;"><?php echo $message['ex1']; ?></span>
		<br/>
                <input type="hidden" name="ex" value="1" />
                <label for="ex1_url">Source URL</label>
                <input type="url" id="ex1_url" name="ex1_url" value="" placeholder="Enter Image URL" />
                <br/>
                <label for="ex1_type">Target Type</label>
                <select id="ex1_type" name="ex1_type">
                    <option value="convert-to-jpg">JPG</option>
                    <option value="convert-to-png">PNG</option>
                    <option value="convert-to-bmp">BMP</option>
                </select>
                <br/>
                <label for="ex1_debug" >Debug Output</label>
                <input id="ex1_debug" type="checkbox" name="ex1_debug"  />
                <br/>
                <input type="submit" name="ex1_btn" value="Submit" />
                <?php if(isset($responseArray1['queue-answer']['params']['directDownload'])): ?>
                <a href="<?php echo $responseArray1['queue-answer']['params']['directDownload']; ?>">Download File</a> | <a href="index.php?action=del&hash=<?php echo $responseArray1['queue-answer']['params']['hash']; ?>">Delete file from server</a>
                <?php endif; ?>
            </form>
        </div>
        <h2>[2] Example - Convert file types from Files</h2>
        <div>
            <form enctype="multipart/form-data" method="post" action="index.php" id="ex2" style="padding:20px;border:1px solid #ccc;">
		<span style="color:#ff0000;"><?php echo $message['ex2']; ?></span>
		<br/>
                <input type="hidden" name="ex" value="2" />
                <label for="ex2_file">Select File</label>
                <input type="file" id="ex2_file" name="ex2_file" placeholder="Select Image File" />
                <br/>
                <label for="ex2_type">Target Type</label>
                <select id="ex2_type" name="ex2_type">
                    <option value="convert-to-jpg">JPG</option>
                    <option value="convert-to-png">PNG</option>
                    <option value="convert-to-bmp">BMP</option>
                </select>
                <br/>
                <label for="ex2_debug" >Debug Output</label>
                <input id="ex2_debug" type="checkbox" name="ex2_debug"  />
                <br/>
                <input type="submit" name="ex2_btn" value="Submit" />
                <?php if(isset($responseArray2['queue-answer']['params']['directDownload'])): ?>
                <a href="<?php echo $responseArray2['queue-answer']['params']['directDownload']; ?>">Download File</a> | <a href="index.php?action=del&hash=<?php echo $responseArray2['queue-answer']['params']['hash']; ?>">Delete file from server</a>
                <?php endif; ?>
            </form>
        </div>
        <?php if(filter_input(INPUT_POST,"ex1_debug",FILTER_SANITIZE_STRING) || filter_input(INPUT_POST,"ex2_debug",FILTER_SANITIZE_STRING) && !empty($debugXmlOutput)):  ?>
        <h2>Debug Output</h2>
        <iframe style="width: 100%; height: 100%;"  src='data:text/xml;charset=utf-8,<?php print_r($debugXmlOutput);?>' >
            </iframe>
        <?php endif; ?>
    </body>
</html>

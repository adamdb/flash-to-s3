package com.adambalchunas.flash.aws.s3
{
	/**
	 * @author Eric Wagner
	 * @author Adam Balchunas
	 * 
	 * This class was originally provided by Eric Wagner as part of a larger example utilizing the Flex framework.
	 * It has been modified to work on the Flash player runtime without requiring the Flex framework.
	 * The original work can be found here: http://aws.amazon.com/code/1092?_encoding=UTF8&jiveRedirect=1
	 */
	import flash.utils.ByteArray;
	
	public class S3Policy 
	{
		import com.hurlant.util.Base64;
		import com.hurlant.crypto.hash.HMAC;
		import com.hurlant.crypto.hash.SHA1;
		
		private var _mm:String;
		private var _dd:String;
		private var _yyyy:String;
		private var _bucket:String;
		private var _key:String;
		private var _options:S3PostOptions;
		private var _accessKeys:S3AccessKeys;
		private var _policyString:String;
		private var _base64PolicyString:String;
		private var _signatureString:String;
		
		public function S3Policy(mm:String, dd:String, yyyy:String, bucket:String, key:String, accessKeys:S3AccessKeys, options:S3PostOptions)
		{
			_mm = mm;
			_dd = dd;
			_yyyy = yyyy;	
			
			_bucket = bucket;
			_key = key;
			_options = options;
			_accessKeys = accessKeys;
			
			generatePolicy();
			signPolicy();
		}

		public function get base64Policy():String
		{
			return _base64PolicyString;
		}
		
		public function get signature():String
		{
			return _signatureString;
		}

		private function generatePolicy():void 
		{
			var buffer:Array = new Array();
			buffer.indents = 0;
                
			write(buffer, "{\n");
			indent(buffer);
                
			// expiration
			var mm:String = _mm;
			var dd:String = _dd;
			var yyyy:String = _yyyy;
			
			if (!mm || !mm.match(/^\d{2}$/) || !dd || !dd.match(/^\d{2}$/) || !yyyy || !yyyy.match(/^\d{4}$/)) 
			{
				trace("You must enter an expiration in the form:\n MM DD YYYY");
				return;
			}
			
			write(buffer, "'expiration': '");
			write(buffer, yyyy);
			write(buffer, "-");
			write(buffer, mm);
			write(buffer, "-");
			write(buffer, dd);
			write(buffer, "T12:00:00.000Z'");
			write(buffer, ",\n");
                    
			// conditions
			write(buffer, "'conditions': [\n");
			indent(buffer);
                    
			// bucket
			if (!_bucket)
			{
				trace("You must enter a 'bucket' condition!");
				return;
			}
			
			writeSimpleCondition(buffer, "bucket", _bucket, true);
                    
			// key
			if (!_key)
			{
				trace("You must enter a 'key' condition!");
				return;
			}
			
			writeSimpleCondition(buffer, "key", _key, true);
                        
			// acl
			if (_options.acl)
			{
				writeSimpleCondition(buffer, "acl", _options.acl, true);
			}
                        
			// Content-Type
			if (_options.contentType) 
			{
				writeSimpleCondition(buffer, "Content-Type", _options.contentType, true);
			}

			// Filename
			/**
			 * FileReference.Upload sends along the "Filename" form field.
			 * The "Filename" form field contains the name of the local file being
			 * uploaded.
			 * 
			 * See http://livedocs.adobe.com/flex/2/langref/flash/net/FileReference.html for more imformation
			 * about the FileReference API.
			 * 
			 * Since there is no provided way to exclude this form field, and since
			 * Amazon S3 POST interface requires that all form fields are handled by
			 * the policy document, we must always add this 'starts-with' condition that 
			 * allows ANY 'Filename' to be specified.  Removing this condition from your
			 * policy will result in Adobe Flash clients not being able to POST to Amazon S3.
			 */
			writeCondition(buffer, "starts-with", "$Filename", "", true);
                        
			// success_action_status
			/**
			 * Certain combinations of Flash player version and platform don't handle
			 * HTTP responses with the header 'Content-Length: 0'.  These clients do not
			 * dispatch completion or error events when such a response is received.
			 * Therefore it is impossible to tell when the upload has completed or failed.
			 * 
			 * Flash clients should always set the success_action_status parameter to 201
			 * so that Amazon S3 returns a response with Content-Length being non-zero.
			 * The policy sent along with the POST MUST therefore contain a condition
			 * enabling use of the success_action_status parameter with a value of 201.
			 * 
			 * There are many possible conditions satisfying the above requirements.
			 * This policy generator adds one for you below.
			 */
			writeCondition(buffer, "eq", "$success_action_status", "201", false);
                        
			write(buffer, "\n");
			outdent(buffer);
			write(buffer, "]");
                    
			write(buffer, "\n");
			outdent(buffer);
			write(buffer, "}");
                
			_policyString = buffer.join("");
		}

		private function write(buffer:Array, value:String):void 
		{
			if (buffer.length > 0) 
			{
				var lastPush:String = String(buffer[buffer.length - 1]);
				
				if (lastPush.length && lastPush.charAt(lastPush.length - 1) == "\n") 
				{
					writeIndents(buffer);
				}
			}
			
			buffer.push(value);
		}

		private function indent(buffer:Array):void 
		{
			buffer.indents++;
		}

		private function outdent(buffer:Array):void 
		{
			buffer.indents = Math.max(0, buffer.indents - 1);
		}

		private function writeIndents(buffer:Array):void 
		{
			for (var i:int = 0;i < buffer.indents;i++) 
			{
				buffer.push("    ");
			}
		}

		private function writeCondition(buffer:Array, type:String, name:String, value:String, commaNewLine:Boolean):void 
		{
			write(buffer, "['");
			write(buffer, type);
			write(buffer, "', '");
			write(buffer, name);
			write(buffer, "', '");
			write(buffer, value);
			write(buffer, "'");
			write(buffer, "]");
			
			if (commaNewLine) 
			{
				write(buffer, ",\n");
			}
		}

		private function writeSimpleCondition(buffer:Array, name:String, value:String, commaNewLine:Boolean):void 
		{
			write(buffer, "{'");
			write(buffer, name);
			write(buffer, "': ");
			write(buffer, "'");
			write(buffer, value);
			write(buffer, "'");
			write(buffer, "}");
			
			if (commaNewLine) 
			{
				write(buffer, ",\n");
			}
		}

		private function signPolicy():void 
		{
			var secretKey:String = _accessKeys.secretAccessKeyId;
			
			if (!secretKey)
			{
				trace("You must enter your AWS secret key!");
				return;
			}
			
			var unsignedPolicy:String = _policyString;    
			
			if (!unsignedPolicy)
			{
				trace("You must enter a policy document!\n" + "Use the policy generator (following instructions for part A) " + "or author your own policy document in the text field labeled 'Policy'.");
				return;
			}
			
			var base64policy:String = Base64.encode(unsignedPolicy);
			_base64PolicyString = base64policy;
			_signatureString = generateSignature(base64policy, secretKey);
		}

		private function generateSignature(data:String, secretKey:String):String 
		{
                
			var secretKeyByteArray:ByteArray = new ByteArray();
			secretKeyByteArray.writeUTFBytes(secretKey);
			secretKeyByteArray.position = 0;
                
			var dataByteArray:ByteArray = new ByteArray();
			dataByteArray.writeUTFBytes(data);
			dataByteArray.position = 0;
                
			var hmac:HMAC = new HMAC(new SHA1());            
			var signatureByteArray:ByteArray = hmac.compute(secretKeyByteArray, dataByteArray);
			return Base64.encodeByteArray(signatureByteArray);
		}
	}
}
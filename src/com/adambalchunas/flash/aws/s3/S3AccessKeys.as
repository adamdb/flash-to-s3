package com.adambalchunas.flash.aws.s3 
{
	/**
	 * @author Eric Wagner
	 * @author Adam Balchunas
	 */
	public class S3AccessKeys 
	{
		public var accessKeyId:String;
		public var secretAccessKeyId:String;
	
		public function S3AccessKeys(keyId:String = "", secretKeyId:String = "")
		{
			accessKeyId = keyId;
			secretAccessKeyId = secretKeyId;
		}
	}
}
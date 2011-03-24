package com.adambalchunas.flash.aws.s3
{
	/**
	 * @author Eric Wagner
	 * @author Adam Balchunas
	 * 
	 * Provides configuration options for sending a POST request to S3.
	 * 
	 * This class was originally provided by Eric Wagner as part of a larger example utilizing the Flex framework.
	 * It has been modified to work on the Flash player runtime without requiring the Flex framework.
	 * The original work can be found here: http://aws.amazon.com/code/1092?_encoding=UTF8&jiveRedirect=1
	 */
	public class S3PostOptions 
	{
		public static const ACL_PRIVATE:String = "private";
		public static const ACL_PUBLIC_READ:String = "public-read";
		public static const ACL_PUBLIC_READ_WRITE:String = "public-read-write";
		public static const ACL_AUTHENTICATED_READ:String = "ACL_AUTHENTICATED_READ";
		
		public static const CONTENT_TYPE_IMAGE_JPEG:String = "image/jpeg";
		public static const CONTENT_TYPE_IMAGE_PNG:String = "image/png";
		public static const CONTENT_TYPE_IMAGE_GIF:String = "image/gif";
		public static const CONTENT_TYPE_TEXT_HTML:String = "text/html";
		public static const CONTENT_TYPE_TEXT_CSS:String = "text/css";
		public static const CONTENT_TYPE_AUDIO_BASIC:String = "audio/basic";
		public static const CONTENT_TYPE_VIDEO_MPEG:String = "video/mpeg";
		
		/**
		 * A canned access control list for the object being uploaded to S3.
		 * 
		 * Valid values are:
		 *    private
		 *    public-read
		 *    public-read-write
		 *    authenticated-read
		 */
		public var acl:String;
		
		/**
		 * The MIME type of the object being uploaded.
		 */
		public var contentType:String;
		
		/**
		 * Base64 encoded S3 POST policy document used to validate this request.
		 *
		 * For more details on how to build a policy document, see:
		 * http://docs.amazonwebservices.com/AmazonS3/2006-03-01/
		 */
		public var policy:String;
		
		/**
		 * Base64 encoded signature of the S3 POST policy document used to validate this request.
		 *
		 * For more details on how to build a policy document, see:
		 * http://docs.amazonwebservices.com/AmazonS3/2006-03-01/
		 * 
		 * You can use the S3PostSamplePolicyGenerator application included in this sample code to
		 * generate policy documents and sign them with your secret key.
		 */
		public var signature:String;
		
		/**
		 * A flag indicating whether HTTPS should be used.
		 */
		public var secure:Boolean;
	}
}
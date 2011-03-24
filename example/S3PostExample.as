package  
{
	/**
	 * @author Adam Balchunas
	 * 
	 * This is an example of how to implement the flash-to-s3 library.
	 * You will need to use your own S3 instance and replace the the constants
	 * below with the appropriate data in order for this example to work.
	 */
	import com.adambalchunas.flash.aws.s3.S3AccessKeys;
	import com.adambalchunas.flash.aws.s3.S3Policy;
	import com.adambalchunas.flash.aws.s3.S3PostOptions;
	import com.adambalchunas.flash.aws.s3.S3PostRequest;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	/**
	 * @author Adam Balchunas
	 */
	public class S3PostExample extends Sprite 
	{
		public static const AMAZON_S3_DIRECTORY:String = "images/";
		public static const AMAZON_S3_BUCKET:String = "youramazonbucket";
		public static const AMAZON_S3_ACCESS_KEY:String = "YOUR AMAZON S3 ACCESS KEY";
		public static const AMAZON_S3_SECRET_ACCESS_KEY:String = "YOUR AMAZON S3 SECRET ACCESS KEY";
		
		private var _file:FileReference;
		private var _fileLoader:Loader;
		
		public function S3PostExample()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function init():void
		{
			_file = new FileReference();
			 
			var imageFileTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg)", "*.jpg;*.jpeg;");
			 
			//display file selction dialog box
			_file.browse([imageFileTypes]);
			_file.addEventListener(Event.SELECT, onSelectFile);
		}

		private function onSelectFile(e:Event):void
		{
			//check to see if the image size is less than 2 mbs
			if ((_file.size / 1024) / 1024 > 2) //in mbs
			{
				return;
			}
			else
			{
				_file.removeEventListener(Event.SELECT, onSelectFile);
				_file.addEventListener(Event.COMPLETE, onLoadFile);
				_file.load();
			}
		}

		private function onLoadFile(e:Event):void
		{
			_file.removeEventListener(Event.COMPLETE, onLoadFile);
			
			_fileLoader = new Loader();
			_fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_fileLoader.loadBytes(_file.data);
		}

		private function onLoadComplete(e:Event):void
		{
			_fileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		
			var key:String = AMAZON_S3_DIRECTORY + _file.name;
				
			var accessKeys:S3AccessKeys = new S3AccessKeys(AMAZON_S3_ACCESS_KEY, AMAZON_S3_SECRET_ACCESS_KEY);
			
			var options:S3PostOptions = new S3PostOptions();
			options.acl = S3PostOptions.ACL_PRIVATE;
			options.contentType = S3PostOptions.CONTENT_TYPE_IMAGE_JPEG;
			options.secure = false;
			
			var policy:S3Policy = new S3Policy("01", "01", "2012", AMAZON_S3_BUCKET, key, accessKeys, options);
			
			options.policy = policy.base64Policy;
			options.signature = policy.signature;
			
			var postRequest:S3PostRequest = new S3PostRequest(accessKeys, AMAZON_S3_BUCKET, key, options);
			postRequest.upload(_file);
		}

		private function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
			init();
		}
	}
}
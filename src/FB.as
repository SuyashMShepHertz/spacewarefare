package
{
	import com.facebook.graph.Facebook;
	
	import flash.external.ExternalInterface;

	public class FB
	{
		
		public function init(app_id:String,f:Function):void
		{
			trace("[Facebook] Initialising");
			ExternalInterface.call("console.log","[Facebook] Initialising");
			Facebook.init(app_id,f);
		}
		
		public function Login(f:Function):void
		{
			trace("[Facebook] Logging");
			ExternalInterface.call("console.log","[Facebook] Logging");
			Facebook.login(f,new Array("publish_stream"));
		}
		
		public function postOnWal(t:String,s:String,l:String,d:String,f:Function):void
		{
			Facebook.api("/me/feed",f,{
				message:s,
				link:l,
				name: t,
				description: d}
				,"post");
		}
		
		public function IniviteFBFriends():void
		{
			Facebook.ui("apprequests",{message:"Hi!! Check out this APP"});
		}
		
		public function GetMe(callback:Function):void
		{
			Facebook.api("/me",callback);
		}
	}
}
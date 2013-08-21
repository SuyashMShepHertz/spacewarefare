package screens
{
	import com.shephertz.appwarp.messages.LiveRoom;
	import com.shephertz.appwarp.types.ResultCode;
	
	import entities.Blast;
	import entities.Bullet;
	import entities.Character;
	import entities.Item;
	import entities.World;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class Game extends FlxState
	{
		private var world:World;
		private var player:Character;
		private const Width:int = 800;
		private const Height:int = 480;
		private var tileWidth:int = 25;
		
		private var roomID:String;
		private var remote:Array;
		private var remoteMsg:Array;
		private var msg:FlxText;
		private var youLable:FlxText;
		private var itemsFlx:FlxGroup;
		private var properties:Object;
		private var score:FlxText;
		private var BulletsFlx:FlxGroup;
		
		private var Health:int;
		private var Bullets:int;
		private var Points:int;
		
		private var user:String;
		private var name:String;
		
		public function Game(u:String,n:String)
		{
			user = u;
			name = n;
		}
		
		override public function create():void
		{
			setup();
		}
		
		override public function update():void
		{
			updateGame();
			super.update();
			FlxG.overlap(player, itemsFlx, gotItem);
		}
		
		public function setup():void
		{
			roomID = "410174383";
			remote = new Array();
			remoteMsg = new Array();
			Health = 10;
			Bullets = 100;
			Points = 0;
			FlxG.mouse.show();
			
			world = new World();
			world.create(this);
			
			player = new Character(1,1,0,0,Width,Height);
			add(player);
			if(name == "")
				youLable = new FlxText(player.x,player.y-8,32,"You");
			else
				youLable = new FlxText(player.x,player.y-8,64,name.search(" ") != -1 ? name.substring(0,name.search(" ")) : name);
			
			add(youLable);
			
			FlxG.worldBounds = new FlxRect(0,0,Width,Height);
			FlxG.camera.follow(player);
			FlxG.camera.setBounds(0,0,Width, Height);
			
			msg = new FlxText(0,0,128,"Connecting...");
			msg.scrollFactor.x = msg.scrollFactor.y = 0;
			add(msg);

			itemsFlx = new FlxGroup();
			add(itemsFlx);
			
			BulletsFlx = new FlxGroup();
			add(BulletsFlx)
			
			score = new FlxText(Width/2-128,0,128,"Score : "+Points+"\nHealth : "+Health+"\nBullets : "+Bullets);
			score.scrollFactor.x = score.scrollFactor.y = 0;
			score.alignment = "right";
			add(score);
			
			AppWarp.connect(this,user);
		}
		
		public function updateGame():void
		{
			var pos:FlxPoint;
			
			if(FlxG.keys.UP)
				pos = player.move(Character.Up);
			else if(FlxG.keys.LEFT)
				pos = player.move(Character.Left);
			else if(FlxG.keys.DOWN)
				pos = player.move(Character.Down);
			else if(FlxG.keys.RIGHT)
				pos = player.move(Character.Right);
			
			if(pos!=null)
				AppWarp.SendMove(pos.x,pos.y);
			
			if(remoteMsg.length > 0)
			{
				if(remote[remoteMsg[0].sender].moveXY(remoteMsg[0].x,remoteMsg[0].y) != null)
				{
					remoteMsg.shift();
				}
			}
			
			youLable.x = player.x;
			youLable.y = player.y - 10;
			
			if(FlxG.mouse.justReleased() && Bullets > 0)
			{
				var shot:Bullet = new Bullet(BulletsFlx,player.x+12,player.y+12,FlxG.mouse.x,FlxG.mouse.y,makeBlast);
				Bullets -= 1;
				score.text = "Score : "+Points+"\nHealth : "+Health+"\nBullets : "+Bullets;
				
				for (var sender:String in remote)
				{
					if(FlxG.mouse.x >= remote[sender].x && FlxG.mouse.x <= remote[sender].x+remote[sender].width)
					{
						if(FlxG.mouse.y >= remote[sender].y && FlxG.mouse.y <= remote[sender].y+remote[sender].height)
						{
							AppWarp.SendAttack(sender);
						}
					}
				}
			}
			
			if(Health <= 0)
			{
				AppWarp.leave(roomID);
				kill();
				FlxG.switchState(new GameOver());
			}
		}
		
		public function connectDone(res:int):void
		{
			if(res == ResultCode.success)
			{
				msg.text = "Joining Game...";
				AppWarp.join(roomID);		
			}
		}
		
		public function joinDone(res:int):void
		{
			if(res == ResultCode.success)
			{
				msg.text = "Connected";
				AppWarp.startListening();
				AppWarp.getRoomInfo(roomID);
			}
		}
		
		public function listen(sender:String,obj:Object):void
		{
			if(sender in remote)
			{
				if(obj.type == 1)
				{
					obj.sender = sender;
					//remote[sender].moveXY(obj.x,obj.y);
					remoteMsg.push(obj);
				}
				else if(obj.type == 2)
				{
					if(obj.p == AppWarp.getUser())
					{
						try
						{
							Health -= 1;
							score.text = "Score : "+Points+"\nHealth : "+Health+"\nBullets : "+Bullets;
							var shot:Bullet = new Bullet(BulletsFlx,remote[sender].x,remote[sender].y,player.x+12,player.y+12, makeBlast);
						}
						catch(e)
						{
							
						}
					}
				}
				
				trace("Already Added----------------------------------------------------------------------------");
			}
			else
			{
				var p:Character = new Character(obj.x/tileWidth,obj.y/tileWidth,0,0,Width,Height);
				add(p);	
				remote[sender] = p;
			}
		}
		
		public function makeBlast(px:int,py:int):void
		{
			var b:Blast = new Blast(this,px,py);
		}
		
		public function roomInfoDone(obj:LiveRoom):void
		{
			properties = obj.properties;
			
			itemsFlx.callAll("kill");
			itemsFlx.clear();
			for(var i:Object in properties)
			{
				var item:Item = new Item(properties[i].x,properties[i].y,parseInt(i.substr(-1,1)));
				item.ID = parseInt(i.substr(-1,1));
				itemsFlx.add(item);
			}
		}
		
		public function gotItem(player:FlxObject,item:FlxObject):void
		{
			var x:int = Math.random()*25;
			var y:int = Math.random()*15;
			
			if(item.ID == 1)
			{
				Health += 1;
				Points += 10;
			}
			else if(item.ID == 2)
			{
				Bullets += 3;
				Points += 10;
			}
			else
			{
				Points += 50;
			}
			
			score.text = "Score : "+Points+"\nHealth : "+Health+"\nBullets : "+Bullets;
			
			AppWarp.placeItems(roomID,properties,"item"+item.ID,x,y);
			itemsFlx.remove(item);
			item.kill();
		}
		
		public function leftRoom(user:String):void
		{
			if(user in remote)
			{
				remote[user].kill();
				delete remote[user];
			}
		}
	}
}
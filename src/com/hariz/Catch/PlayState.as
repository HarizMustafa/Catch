package com.hariz.Catch
{
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		[Embed(source = '../../../../levels/mapCSV_Group1_Map1.csv', mimeType = 'application/octet-stream')]public var levelMap:Class; //main level tiles, the level was made using DAME http://dambots.com/dame-editor/ . Horrible UI and unpleasant to use but it did the job
		[Embed(source = '../../../../levels/mapCSV_Group1_Map1back.csv', mimeType = 'application/octet-stream')]public var backgroundMap:Class; //cloud background tiles
		[Embed(source = '../../../../levels/mapCSV_Group1_Ladders.csv', mimeType = 'application/octet-stream')]public var laddersMap:Class; //ladder background tiles
		[Embed(source = '../../../../data/monstacoords.csv', mimeType = 'application/octet-stream')]public var mageList:Class;
		[Embed(source = '../../../../data/lurkcoords.csv', mimeType = 'application/octet-stream')]public var lurkList:Class;
		
		
		[Embed(source = '../../../../art/tiles.png')]public var levelTiles:Class;
		[Embed(source = "../../../../art/back2.png")]private var ImgBG:Class; //embed background image
		[Embed(source = '../../../../art/mongibs.png')]public var imgGibs:Class;
		[Embed(source = '../../../../art/magegibs.png')]public var imgMageGibs:Class;
		[Embed(source = '../../../../music/DunkaDunka.mp3')]public var bgMusic:Class;
		
		public var map:FlxTilemap = new FlxTilemap;
		public var background:FlxTilemap = new FlxTilemap;
		public var ladders:FlxTilemap = new FlxTilemap;
		public var player:Player;
		public var _numTime:Number = 120;
		//public var mage:Enemy;
		
		protected var _gibs:FlxEmitter;
		protected var _mongibs:FlxEmitter;
		protected var _bullets:FlxGroup;
		protected var _badbullets:FlxGroup;
		protected var _restart:Boolean;
		protected var _text1:FlxText;
		protected var _text2:FlxText;
		protected var _enemies:FlxGroup;
		protected var _score:FlxText;
		protected var _textTimeN:FlxText;
		
		
		override public function create():void
		{
			_restart = false;
			// Set up the game over text
			_text1 = new FlxText(30, 30, 400, "Press R to Restart");
			_text1.visible = false;
			_text1.size = 40;
			_text1.color = 0x66FF0000;
			_text1.antialiasing = true;
			_text1.scrollFactor.x = _text1.scrollFactor.y = 0;
			
			// Set up the game win text
			_text2 = new FlxText(500, 100, 400, "You won!!! Press R to Restart ");
			_text2.visible = false;
			_text2.size = 60;
			_text2.color = 0x66FFD700;
			_text2.antialiasing = true;
			_text2.scrollFactor.x = _text2.scrollFactor.y = 0;
			
			//setting up the gibs
			_gibs= new FlxEmitter();
			_gibs.delay = 3;
			_gibs.setXSpeed( -150, 150);
			_gibs.setYSpeed( -200, 0);
			_gibs.setRotation( -720, 720);
			_gibs.createSprites(imgGibs, 50, 15, true, .5, 0.65);
			
			_mongibs= new FlxEmitter();
			_mongibs.delay = 3;
			_mongibs.setXSpeed( -150, 150);
			_mongibs.setYSpeed( -200, 0);
			_mongibs.setRotation( -720, -720);
			_mongibs.createSprites(imgMageGibs, 50, 15, true, 0.5, 0.65);
			
			//bullets created here
			_bullets = new FlxGroup;
			_badbullets = new FlxGroup;
			
			var bg:FlxSprite; //main background image
			bg = new FlxSprite(0, 0, ImgBG);
			add(bg);
			bg.scrollFactor.x = bg.scrollFactor.y = .5; //cheap parallax scrolling effect for background
			add(background.loadMap(new backgroundMap, levelTiles, 32, 32)); //cloud backgrounds
			background.scrollFactor.x = background.scrollFactor.y = .5;
			
			add(map.loadMap(new levelMap, levelTiles, 32, 32));  
			add(ladders.loadMap(new laddersMap, levelTiles, 32, 32));
			
			FlxU.setWorldBounds(0, 0, map.width, map.height);
			
			add(player = new Player(169, 180, this, _gibs, _bullets)); //player added here
			
			FlxG.follow(player,1); //Attach the camera to the player
			FlxG.followAdjust(0,0); //Attach the camera speed with this
			FlxG.followBounds(0, 0, 1600,800);//Keep the camera from scrolling past the map edges
			
			//Enemies added here
			_enemies = new FlxGroup; //set up the group
			placeMonsters(new mageList, Enemy); //Initialize each creature
			placeMonsters(new lurkList, Lurker);
			add(_enemies); //Display them
			
			super.create();
			
			//set up the individual bullets
			for (var i:uint = 0; i < 4; i++)    // Allow 4 bullets at a time
				_bullets.add(new Bullet());
			add(_bullets); 
			add(_gibs);//adding the player and mage gibs to the game
			add(_mongibs);
			
			//HUD - score
			var ssf:FlxPoint = new FlxPoint(0,0);
			_score = new FlxText(0,0,FlxG.width);
			_score.color = 0xFFFF00;
			_score.size = 16;
			_score.alignment = "center";
			_score.scrollFactor = ssf;
			_score.shadow = 0x131c1b;
			add(_score);
			
			//Countdown timer
			_textTimeN = new FlxText(30,30,FlxG.width);
			_textTimeN.color = 0xFF0000;
			_textTimeN.size = 12;
			_textTimeN.alignment = "center";
			_textTimeN.scrollFactor = ssf;
			_textTimeN.shadow = 0x131c1b;
			add(_textTimeN);
			
			
			add(_text1); // Add last so it goes on top, you know the drill.
			add(_text2);
			
			//FlxG.showBounds = true;
			FlxG.playMusic(bgMusic, .5); //background music
			
		}
		
		override public function update():void
		{
			super.update();
			player.collide(map);
			_enemies.collide(map);
			_gibs.collide(map);
			_mongibs.collide(map);
			_bullets.collide(map);
			_badbullets.collide(map);
			
			_score.text = 'Mages Captured : ' + FlxG.score.toString();
			
			//Countdown timer
			_numTime -= FlxG.elapsed;//Reduce Number of seconds
			
			//Update timer
			_textTimeN.text = "Time left : "+FlxU.floor(_numTime);
			if (_numTime <= 0){ player.kill();} 
			
			if (_score.text == 'Mages Captured : 8') 
			{
				if (_numTime > 0)
				{
					_text2.visible = true;
					if (FlxG.keys.justPressed("R")) 
					{
						_restart = true;
					}
				}
				
			}
			
			if (player.dead)
			{
				_text1.visible = true;
				if (FlxG.keys.justPressed("R")) _restart = true;
			}
			
			FlxU.overlap(player, _enemies, hitPlayer);  // The new collision check
			FlxU.overlap(_bullets, _enemies, hitmonster);
			FlxU.overlap(player, _badbullets, hitPlayer);
			
			if (_restart)
			{ FlxG.state = new PlayState;
			  FlxG.score =0;
			}
		}
		
		private function hitPlayer(P:FlxObject,Monster:FlxObject):void 
		{
			if (Monster is Enemy)
			{	Monster.kill();
				FlxG.score++;
			}	
			else if (Monster is Lurker)
				P.hurt(1); // This should still be more interesting
		}
		
		private function hitmonster(Blt:FlxObject, Monster:FlxObject):void 
		{
			if (Monster.health > 0) 
			{
				Blt.kill();
				Monster.hurt(1);
			}
		}
		
		private function placeMonsters(MonsterData:String, Monster:Class):void
		{
			var coords:Array;
			var entities:Array = MonsterData.split("\n");   // Each line becomes an entry in the array of strings
			for (var j:int = 0; j < entities.length; j++) 
			{
				coords = entities[j].split(",");  //Split each line into two coordinates
				if (Monster == Enemy)
				{_enemies.add(new Monster(uint(coords[0]), uint(coords[1]), player, _mongibs)); }
				else if (Monster == Lurker)
				{ _enemies.add(new Monster(uint(coords[0]), uint(coords[1]), player, _badbullets));}
				else if (Monster!=null)
				{ _enemies.add(new Monster(uint(coords[0]), uint(coords[1]), player));}
			}
		}
	}
}
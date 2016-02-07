package com.hariz.Catch 
{
	import com.hariz.Catch.Player;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxU;

	public class Lurker extends EnemyTemplate 
	{
		
		
		[Embed(source = '../../../../art/lurker.png')]public var imgLurker:Class;
		[Embed(source = '../../../../sounds/monhurt2.mp3')]public var sndHurt:Class;
		[Embed(source = '../../../../sounds/mondead2.mp3')]public var sndDead:Class;
		[Embed(source = '../../../../sounds/badshoot.mp3')]public var sndShoot:Class;
		
		protected static const RUN_SPEED:int = 100;
		protected static const GRAVITY:int = 300;
		protected static const HEALTH:int = 2;
		protected static const SPAWNTIME:Number = 45;
		protected static const JUMP_SPEED:int = 60;
		protected static const BURNTIME:int = 2;

		
		protected var _spawntimer:Number;
		protected var _burntimer:Number;
		protected var _playdeathsound:Boolean;
		protected var _cooldown:Number;
		public function Lurker(X:Number, Y:Number, ThePlayer:Player, Bullets:FlxGroup) 
		{
			super(X, Y, ThePlayer);
			
			_spawntimer = 0;
			_burntimer = 0;
			_playdeathsound = true;
			_cooldown = 0;
			
			loadGraphic(imgLurker, true, true , 16, 16);
			addAnimation("walking", [0, 1], 18, true);
			addAnimation("burning", [0, 2], 18, true);
			addAnimation("wrecked", [2, 3], 18, true);
			addAnimation("idle", [0]);
			drag.x = RUN_SPEED * 9;
			drag.y = JUMP_SPEED * 7;
			acceleration.y = GRAVITY;
			maxVelocity.x = RUN_SPEED;
			maxVelocity.y = JUMP_SPEED;
			health = HEALTH;
			offset.x = 3;
			width = 10;
		}
		override public function update():void 
		{
			//Animation
			if (!velocity.x && !velocity.y) { play("idle"); }
			else if (health < HEALTH) 
			{ 
				if (velocity.y == 0) { play("wrecked");}
				else {play("burning");} 
			}
			else { play("walking"); }	
			
			if (health>0)
			{
				if (velocity.y == 0) { acceleration.y = -acceleration.y }
				if (x != _startx)
				{acceleration.x = ((_startx - x)); }
				
				var xdistance:Number = _player.x - x;
				var ydistance:Number = _player.y - y;
				var distancesquared:Number = xdistance * xdistance + ydistance * ydistance;
				if (distancesquared < 100000)
				{
					if (_player.x < x)
					{
						facing = RIGHT; // The sprite is facing the opposite direction than flixel is expecting, so hack it into the right direction
						acceleration.x = -drag.x;
					}
					else if (_player.x > x)
					{
						facing = LEFT;
						acceleration.x = drag.x;
					}
					if (_player.y < y) { acceleration.y = -drag.y; }
					else if (_player.y > y) { acceleration.y = drag.y;}
				}
			}
			
			if (health<=0)
			{
				maxVelocity.y = JUMP_SPEED * 4;
				acceleration.y = GRAVITY*3;
				velocity.x = 0;
				_burntimer += FlxG.elapsed;
				if (_burntimer >= BURNTIME)
				{
					x = -10;
					y = -10;
					visible = false;
					acceleration.y = 0;
					super.kill();
				}

			}
			_cooldown += FlxG.elapsed;
			super.update();
		}
		
		override public function hurt(Damage:Number):void 
		{
			if (x > _player.x)
				velocity.x = drag.x * 4;
			else
				velocity.x = -drag.x * 4;
			flicker(.5);
			FlxG.play(sndHurt,1,false,50)
			health -= 1;
			super.hurt(Damage);
		}

		override public function kill():void 
		{
			exists = true;
			solid = true;
			visible = true;
			acceleration.y = GRAVITY;
			velocity.x = 0;
		}
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void 
		{
			if (health <= 0 && _playdeathsound)
			{
				FlxG.play(sndDead, 1, false, 50);
				_playdeathsound = false;
			}
			super.hitBottom(Contact, Velocity);
		}
		
	}
	
}
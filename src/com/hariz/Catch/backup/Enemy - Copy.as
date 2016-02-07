package com.hariz.Catch 
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxObject;

	
	/**
	 * ...
	 * @author David Bell
	 */
	public class Enemy extends EnemyTemplate
	{
		[Embed(source = '../../../../art/mage.png')]public var Mage:Class;
		[Embed(source = '../../../../sounds/hit.mp3')]public var sndHurt:Class;
		
		protected static const RUN_SPEED:int = 90;
		protected static const GRAVITY:int =0;
		protected static const JUMP_SPEED:int = 200;
		protected static const HEALTH:int = 5;
		
		//protected var _player:Player;
		protected var _gibs:FlxEmitter;
		
		public function Enemy(X:Number, Y:Number, ThePlayer:Player, Gibs:FlxEmitter) 
		{
			super(X, Y, ThePlayer);
			
			loadGraphic(Mage, true, true);  //Set up the graphics
			addAnimation("walking", [0, 1, 2, 3], 10, true);
			addAnimation("idle", [0]);
			//_player = ThePlayer;
			
			drag.x = RUN_SPEED * 7;
			drag.y = JUMP_SPEED * 7;
			acceleration.y = GRAVITY;
			maxVelocity.x = RUN_SPEED;
			maxVelocity.y = JUMP_SPEED;
			health = HEALTH;
			
			_gibs = Gibs;
			
		}
		
		public override function update():void
		{
			acceleration.x = acceleration.y = 0; // Coast to 0 when not chasing the player
			
			var xdistance:Number = _player.x - x; // distance on x axis to player
			var ydistance:Number = _player.y - y; // distance on y axis to player
			var distancesquared:Number = xdistance * xdistance + ydistance * ydistance; // absolute distance to player (squared, because there's no need to spend cycles calculating the square root)
			if (distancesquared < 1200000) // 65000 = 16 tiles
			{
				if (_player.x < x)
				{
					facing = RIGHT; // The sprite is facing the opposite direction than flixel is expecting, so hack it into the right direction
					acceleration.x = drag.x;
				}
				else if (_player.x > x)
				{
					facing = LEFT;
					acceleration.x = -drag.x;
				}
				if (_player.y < y) { acceleration.y = -drag.y;}
				else if (_player.y > y) { acceleration.y = drag.y;}
			}
			//Animation
			
			if (!velocity.x && !velocity.y) { play("idle"); }
			else {play("walking");}
			
			super.update();
		}
		
		override public function hurt(Damage:Number):void 
		{
			if (facing == RIGHT) // remember, right means facing left
				velocity.x = -drag.x * 4; // Knock him to the left
			else if (facing == LEFT) 
				velocity.x = drag.x * 4; //knock him to the right
			flicker(.5);
			FlxG.play(sndHurt, 1, false)
			//super.hurt(Damage);
		}
		
		override public function kill():void 
		{
			if (dead) { return };
			if (_gibs != null)
			{
				_gibs.at(this);
				_gibs.start(true, 2.80);
				FlxG.play(sndHurt, 1, false);
			}
			super.kill();
		}
		
	}
	
}
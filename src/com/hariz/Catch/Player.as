package com.hariz.Catch
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	public class Player extends FlxSprite
	{
		[Embed(source='../../../../art/neumonsta.png')]public var Monsta:Class;
		[Embed(source = '../../../../sounds/jump.mp3')]public var sndJump:Class;
		[Embed(source = '../../../../sounds/shoot2.mp3')]public var sndShoot:Class;
		[Embed(source = '../../../../sounds/death.mp3')]public var sndDeath:Class;
		
		protected static const RUN_SPEED:int = 80;
		protected static const GRAVITY:int =420;
		protected static const JUMP_SPEED:int = 200;
		protected static const BULLET_SPEED:int = 200;
		protected static const GUN_DELAY:Number = .4;
		
		protected var _gibs:FlxEmitter;
		protected var _bullets:FlxGroup;
		protected var _blt:Bullet;
		protected var _cooldown:Number;
		protected var _parent:*;
		protected var _onladder:Boolean;
		
		private var _jump:Number;
		private var _canDJump:Boolean;
		private var _xgrid:int;
		private var _ygrid:int;
		
		public var climbing:Boolean
		
		public function Player(X:int, Y:int,Parent:*, Gibs:FlxEmitter, Bullets:FlxGroup):void //X,Y: Starting coordinates
		{
			super(X, Y);
			
			_bullets = Bullets;
			
			loadGraphic(Monsta, true, true);
			addAnimation("walking", [0 ,1 ,2 ,3 ,4], 12, true); //animations defined here, the array is loading the sprites from the sprite sheet. Can be rearranged as you like, 12 is the fps for the animation, the boolean is if it's looping
			addAnimation("idle", [0]); //Getting spritesheets to load correctly is a slow trial and error process through photoshop because if the spritesheet resolution is incorrect animations will go haywire :/
			addAnimation("jump", [8]);
			addAnimation("attack", [6]);
			
			drag.x = RUN_SPEED * 8;  // How quickly monsta slows down when not pushing a button. By using a multiplier, it will always scale to the run speed, even if we change it.
			drag.y = RUN_SPEED*8;
			acceleration.y = GRAVITY; // Always try to push monsta in the direction of gravity
			maxVelocity.x = RUN_SPEED;
			maxVelocity.y = JUMP_SPEED;
			height = 52;  //hitbox height               //these 4 are very important or else we would get to big or too large hitboxes for the player/ values are based on size of spritesheet
			offset.y = 4; //hitbox y-axis offset
			width = 44;   //hitbox width
			offset.x = 6; //hitbox x-axis offset
			
			_cooldown = GUN_DELAY; // Initialize the cooldown so that monsta can shoot right away.
			_gibs = Gibs;
			_parent = Parent;  // So can look at properties of the playstate's tilemaps
			_jump = 0;
			_onladder = false;
			
			climbing = false; 
		}
		
		public override function update():void
		{
			
			acceleration.x = 0; //Reset to 0 when no button is pushed
			
			if(FlxG.keys.LEFT)
			{
				facing = LEFT;
				acceleration.x = -drag.x;
			}
			else if (FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				acceleration.x = drag.x;
			}
			
			// Climbing
			if (FlxG.keys.UP)
			{
				if (_onladder) 
				{
					climbing = true;
					_canDJump = true;
				}
				if (climbing && (_parent.ladders.getTile(_xgrid, _ygrid-1))) velocity.y = -RUN_SPEED;
			}
			if (FlxG.keys.DOWN) 
			{
				if (_onladder) 
				{
					climbing = true;
					_canDJump = true;
				}
				if (climbing) velocity.y = RUN_SPEED;
			}
			
			if (FlxG.keys.justPressed("C"))
			{
				if (climbing)
				{
					_jump = 0;
					climbing = false;
					FlxG.play(sndJump, 1, false, 50);
				}
				if (!velocity.y)
					FlxG.play(sndJump, 1, false, 50);
			}
			
			if (FlxG.keys.justPressed("C") && (velocity.y > 0) && _canDJump==true)
			{
				FlxG.play(sndJump, 1, false, 50);
				_jump = 0;
				_canDJump = false;
			}
			
			if((_jump >= 0) && (FlxG.keys.C)) 
			{
				climbing = false;
				_jump += FlxG.elapsed;
				if(_jump > 0.25) _jump = -1; //Can't jump for more than 0.25 seconds
			}
			else _jump = -1;
			
			if (_jump > 0)
			{
				if(_jump < 0.035)   // this number is how long before a short slow jump shifts to a faster, high jump
					velocity.y = -.6 * maxVelocity.y; //This is the minimum height of the jump
					
				else 
					velocity.y = -.8 * maxVelocity.y;
			}
			//Shooting
			if (FlxG.keys.X)
			{
				shoot();  
			}
			//Animation
			if (velocity.x > 0 || velocity.x <0 ) { play("walking"); }  // Make sure to check for positive or negative velocity, so the animation will play when moving in both directions
			else if (!velocity.x) { play("idle"); }
			if (velocity.y<0) { play("jump"); }
			if(FlxG.keys.X){play("attack");}
			
			
			
			if (FlxG.keys.justPressed("B"))
			{
				FlxG.showBounds = !FlxG.showBounds;
			}
			_cooldown += FlxG.elapsed;
			
			// Don't let monster walk off the edge of the map
			if (x < 0)
				x = 0;
			if (x > _parent.map.width)
				x = _parent.map.width - width;
			
			_xgrid = int((x+width/2) / 32);   // Convert pixel positions to grid positions. int and floor are functionally the same, 
			_ygrid = int((y+height-1) / 32);   // but I hear int is faster so let's go with that.
			
			if (_parent.ladders.getTile(_xgrid,_ygrid)) {_onladder = true;}
			else 
			{
				_onladder = false;
				climbing = false;
			}
			if (climbing) solid = false;
			else solid = true;
			
			super.update();
		}
		
		private function shoot():void 
		{
			// Prepare some variables to pass on to the bullet
			var bulletX:int = x;
			var bulletY:int = y+4;
			var bXVeloc:int = 0;
			var bYVeloc:int = 0;
			
			if (_cooldown >= GUN_DELAY)
				if (_blt = _bullets.getFirstAvail() as Bullet)
				{
					if (facing == LEFT)
					{
						bulletX -= _blt.width-8; // nudge it a little to the side so it doesn't emerge from the middle of the monster
						bXVeloc = -BULLET_SPEED;
					}
					else
					{
						bulletX += width-8;
						bXVeloc = BULLET_SPEED;
					}
					_blt.shoot(bulletX, bulletY, bXVeloc, bYVeloc);
					FlxG.play(sndShoot, 1, false);
					_cooldown = 0; // reset the shot clock
				}
		}
		
		override public function overlaps(Object:FlxObject):Boolean 
		{
			if (!(Object.dead))
				return super.overlaps(Object);
			else
				return false;
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void  // This fires off whenever the player's bottom edge collides with something i.e. the tilemap.
		{
			if (!FlxG.keys.C) // Don't let the player jump again until he lets go of the button
				_jump = 0;
			_canDJump=true;
			super.hitBottom(Contact, Velocity);
			
		}
		
		override public function kill():void
		{
			if (dead) { return; }
			//solid = false;
			super.kill();
			//exists = false;
			//visible = false;
			FlxG.quake.start(0.005, .35);
			FlxG.flash.start(0xffDB3624, .35);
			if (_gibs != null)
			{
				_gibs.at(this);
				_gibs.start(true, 2.80);
			}
			FlxG.play(sndDeath, 1, false, 50);
		}
	}
}
package com.hariz.Catch 
{
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	
	public class Bullet extends FlxSprite 
	{
		[Embed(source = '../../../../art/bullet.png')]public var ImgBullet:Class;
		
		
		
		public function Bullet() 
		{
			super();
			loadGraphic(ImgBullet, false);
			exists = false; // Don't want the bullets to exist anywhere before they are called.
		}
		
		override public function update():void 
		{
			if (dead && finished) //Finished refers to animation, only included here in case animation is added later
				exists = false;   // Stop paying attention when the bullet dies. 
			if (getScreenXY().x < -64 || getScreenXY().x > FlxG.width+64) { kill();} // If the bullet makes it 64 pixels off the side of the screen, kill it
			else super.update();
		}
		
		//We want the bullet to go away when it hits something, not just stop.
		override public function hitSide(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitTop(Contact:FlxObject,Velocity:Number):void { kill(); }
		
		// We need some sort of function other classes can call that will let us actually fire the bullet. 
		public function shoot(X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			super.reset(X, Y);  // reset() makes the sprite exist again, at the new location you tell it.
			solid = true;
			velocity.x = VelocityX*4;
			velocity.y = VelocityY;
		}
		
		
	}
	
}
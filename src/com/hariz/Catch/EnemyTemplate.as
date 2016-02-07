package com.hariz.Catch
{
	import org.flixel.FlxSprite;
	
	public class EnemyTemplate extends FlxSprite 
	{
		
		protected var _player:Player;
		protected var _startx:Number;
		protected var _starty:Number;
		
		public function EnemyTemplate(X:Number, Y:Number, ThePlayer:Player) 
		{
			super(X, Y);
			_startx = X;
			_starty = Y;
			_player = ThePlayer;
		}
		
		override public function kill():void 
		{
			if (dead) { return };
			super.kill();
			//We need to keep updating for the respawn timer, so set exists back on.
			exists = true;
			visible = false;
			//Shove it off the map just to avoid any accidents before it respawns
			x = -10;
			y = -10;
		}
	}
}
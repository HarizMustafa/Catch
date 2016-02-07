package com.hariz.Catch 
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxU;
	
	public class MenuState extends FlxState 
	{
		[Embed(source = '../../../../art/pointer.png')]public var imgPoint:Class;
		[Embed(source = '../../../../sounds/coin.mp3')]public var sndClick:Class;
		[Embed(source = '../../../../sounds/menu.mp3')]public var sndPoint:Class;
		
		static public const OPTIONS:int=1; //How many menu options there are.
		static public const TEXT_SPEED:Number=200;
		
		private var _text1:FlxText;
		private var _text2:FlxText;
		private var _text3:FlxText;
		private var _pointer:FlxSprite;
		private var _option:int;     // This will indicate what the pointer is pointing at
		
		override public function create():void 
		{
			//Each word is its own object so we can position them independantly
			//_text1 = new FlxText(FlxG.width/5, FlxG.height / 4, 320, "Project");
			_text1 = new FlxText(-220, FlxG.height / 4, 320, "Hoods, Wands and ");
			_text1.size = 40;
			_text1.color = 0xFFFF00;
			_text1.antialiasing = true;
			add(_text1);
			
			//Base everything off of text1, so if any change in color or size, only have to change one
			_text2 = new FlxText(FlxG.width-50, FlxG.height / 2.5, 320, "Monsters");
			_text2.size = _text1.size;
			_text2.color = _text1.color;
			_text2.antialiasing = _text1.antialiasing;
			add(_text2);
			
			//Set up the menu options
			_text3 = new FlxText(FlxG.width * 2 / 3, FlxG.height * 2 / 3, 150, "Play");
			_text3.color =0xAAFFFF00; 
			_text3.size =16;
			_text3.antialiasing = true;
			add(_text3);
			
			_pointer = new FlxSprite();
			_pointer.loadGraphic(imgPoint);
			_pointer.x = _text3.x - _pointer.width - 10;
			add(_pointer);
			_option = 0;
			super.create();
		}
		
		override public function update():void 
		{
			if (_text1.x < FlxG.width / 5)	_text1.velocity.x = TEXT_SPEED;
			else _text1.velocity.x = 0;
			if (_text2.x > FlxG.width / 2.5) _text2.velocity.x = -TEXT_SPEED;
			else _text2.velocity.x = 0;
			
			switch(_option)    //more options could be placed here
			{
				case 0:
					_pointer.y = _text3.y;
					break;

			}
			if (FlxG.keys.justPressed("UP")) //up and down added to navigate just in case if I added more options in the future
			{
				_option = (_option +OPTIONS- 1) % OPTIONS;  // Unorthodox, because % doesn't work on negative numbers. Added to the to-do list of improvements for the near future :P
				FlxG.play(sndPoint, 1, false, 50);
			}
			if (FlxG.keys.justPressed("DOWN"))
			{
				_option = (_option +OPTIONS + 1) % OPTIONS;
				FlxG.play(sndPoint, 1, false, 50);
			}
			if (FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("ENTER"))
				switch (_option) 
				{
					case 0:
						FlxG.fade.start(0xFF969867, 1, startGame);
						FlxG.play(sndClick, 1, false, 50);
						break;

				}
			
			super.update();
		}
		
		
		private function startGame():void
		{
			FlxG.state = new PlayState;
		}
	}
}
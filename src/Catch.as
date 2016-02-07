package
{
	import org.flixel.*; //Refer to all flixel objects in your code
	import com.hariz.Catch.*;
	[SWF(width="1024", height="768", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass="Preloader")]
	
	public class Catch extends FlxGame
	{
		public function Catch()
		{
			super(1024,768, MenuState, 1); //Create a new FlxGame object at 1024x768 with 1x pixels, then load MenuState
			FlxState.bgColor = 0xFF101414;
		}
	}
}
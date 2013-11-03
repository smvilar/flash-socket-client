package
{
	import flash.display.Sprite;
	
	public class Actor extends Sprite
	{
		public function Actor(color:uint)
		{
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, 30);
			graphics.endFill();
		}
	}
}
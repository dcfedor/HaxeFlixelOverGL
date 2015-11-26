package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class PlayState extends FlxState
{
	private var objGLR:GLRenderer;
	
	private var strDiffuseMap:String = "assets/images/wabbit_alpha.png";
	private var strNormalMap:String = "assets/images/wabbit_alpha_n.png";
	
	private var nFlixelWabbits:Int = 100;
	private var nGLWabbits:Int = 100;
	
	override public function create():Void
	{
		super.create();

		//add a bunch of Flixel sprites with random transforms
		var sprFWabbit:FlxSprite;
		for (i in 0...nFlixelWabbits)
		{
			sprFWabbit = new FlxSprite(FlxG.width * Math.random(), FlxG.height * Math.random(), strDiffuseMap);
			sprFWabbit.angle = Math.random() * 360;
			add(sprFWabbit);
		}
		
		//instantiate the GLRenderer (which is an openfl.display.Sprite)
		objGLR = new GLRenderer();
		//add the renderer Sprite to the stage below the Flixel camera
		FlxG.stage.addChildAt(objGLR, 0);
		//adjust the Flixel camera background to be almost fully-transparent (0x00ffffff seems to fail)
		FlxG.camera.bgColor = 0x01ffffff;
		
		//add a bunch of OpenFL+OpenGL sprites with random transforms
		var objGLWabbit:GLObject;
		for (i in 0...nGLWabbits)
		{
			objGLWabbit = objGLR.AddObject(strDiffuseMap, strNormalMap, FlxG.width * Math.random(), FlxG.height * Math.random(), 360 * Math.random());
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}	
}
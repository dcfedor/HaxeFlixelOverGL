# HaxeFlixelOverGL
A quick and dirty demo of HaxeFlixel rendering over an OpenFL GLView.

Based on openfl-samples's SimpleOpenGLView (OpenFL GL viewport with shaders)
[https://github.com/openfl/openfl-samples/tree/master/features/display/SimpleOpenGLView](https://github.com/openfl/openfl-samples/tree/master/features/display/SimpleOpenGLView)

and

Matt DesLauriers's ShaderLesson6 (point+ambient light normal-mapping without rotation)
[https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6](https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6)

with

Robert Basler's Tutorial (getting lighting working with arbitrary object rotations)
[http://www.gamasutra.com/blogs/RobertBasler/20131122/205462/Three_Normal_Mapping_Techniques_Explained_For_the_Mathematically_Uninclined.php?print=1](http://www.gamasutra.com/blogs/RobertBasler/20131122/205462/Three_Normal_Mapping_Techniques_Explained_For_the_Mathematically_Uninclined.php?print=1)

## Note
This is not optimized, nor even good. But it works. It will allow you to render Flixel sprites atop a GL view containing GL models that use custom shaders.

## Dependencies
The following libs were used to make this project:
- flixel "dev" branch (a.k.a. 4.0.0)
- openfl 3.4.0
- lime 2.7.0

Also, this project uses OpenFL "Next" instead of "Legacy."

## Contact
If you have any questions, feel free to ping @dcfedor on Twitter, or dcfedor@bluebottlegames.com. I may not know the answer, but I can try to help.

More importantly, if you're able to make this better/faster/stronger, I'd love to hear about it. (Or even submit some changes of your own!)
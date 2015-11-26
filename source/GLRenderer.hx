package;

import openfl.display.OpenGLView;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix3D;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLTexture;
import openfl.gl.GLUniformLocation;
import openfl.Lib;
import openfl.utils.Float32Array;
import openfl.Assets;

/**
 * Based on openfl-samples's SimpleOpenGLView (OpenFL GL viewport with shaders)
 * https://github.com/openfl/openfl-samples/tree/master/features/display/SimpleOpenGLView
 * 
 * and
 * 
 * Matt DesLauriers's ShaderLesson6 (point+ambient light normal-mapping without rotation)
 * https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6
 * 
 * with
 * 
 * Robert Basler's Tutorial (getting lighting working with arbitrary object rotations)
 * http://www.gamasutra.com/blogs/RobertBasler/20131122/205462/Three_Normal_Mapping_Techniques_Explained_For_the_Mathematically_Uninclined.php?print=1
 */
class GLRenderer extends Sprite 
{
	private var textureDiffuse:GLTexture;
	private var textureNormal:GLTexture;
	private var texCoordBufferDiffuse:GLBuffer;
	private var vertexBufferDiffuse:GLBuffer;
	
	private var diffuseUniform:GLUniformLocation;
	private var normalUniform:GLUniformLocation;
	private var modelMatrixUniform:GLUniformLocation;
	private var viewMatrixUniform:GLUniformLocation;
	private var projectionMatrixUniform:GLUniformLocation;
	private var modelViewMatrixUniform:GLUniformLocation;
	private var modelView3x3MatrixUniform:GLUniformLocation;
	private var mvpMatrixUniform:GLUniformLocation;
	private var normalMatrixUniform:GLUniformLocation;
	private var resolutionUniform:GLUniformLocation;
	private var timeUniform:GLUniformLocation;
	private var v3LightPos:GLUniformLocation;
	private var v4LightColor:GLUniformLocation;
	private var v4AmbientColor:GLUniformLocation;
	private var v3Falloff:GLUniformLocation;

	private var texCoordAttribute:Int;
	private var vertexAttribute:Int;
	private var nStartTime:Int;
	
	private var aObjects:Array<GLObject>;
	
	private var shaderProgram:GLProgram;
	private var view:OpenGLView;
	
	public function new () 
	{
		super ();
		addEventListener(Event.ADDED_TO_STAGE, OnAddToStage);
	}
	
	private function OnAddToStage(e:Event):Void
	{
		nStartTime = Lib.getTimer();
		aObjects = [];

		if (OpenGLView.isSupported) {
			
			view = new OpenGLView ();
			view.render = renderView;
			addChild (view);
		}
	}
	
	/**
	 * Per-frame draw function
	 * @param	rect
	 */
	private function renderView (rect:Rectangle):Void 
	{
		var nTime:Int = Lib.getTimer() - nStartTime; //used for timer functions here and in shaders
		GL.viewport (Std.int (rect.x), Std.int (rect.y), Std.int (rect.width), Std.int (rect.height));
		
		//clear the GL screen
		GL.clearColor (0.0, 0.0, 0.0, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT);
		
		//used for tracking mouse both here and in shaders
		var positionX = stage.mouseX;
		var positionY = stage.mouseY;
		
		//camera setup
		var projectionMatrix:Matrix3D = Matrix3D.createOrtho (0, rect.width, rect.height, 0, 1000, -1000); //matches screen dimensions with distant near and far clip planes
		var viewMatrix:Matrix3D = Matrix3D.create2D (0, 0, 1, 0); //creates a view matrix w/camera at x,y,0, looking at 0,0,0
		
		//Highly unoptimized draw setup per-object.
		var modelMatrix:Matrix3D;
		var modelViewMatrix:Matrix3D;
		var modelView3x3Matrix:Matrix3D;
		var mvpMatrix:Matrix3D;
		var normalMatrix:Matrix3D;
		for (objGL in aObjects)
		{
			//tell GL which shader to use
			GL.useProgram(objGL.shaderProgram);
			//tell GL where to find vertex data?
			GL.enableVertexAttribArray(objGL.vertexAttribute);
			GL.enableVertexAttribArray(objGL.texCoordAttribute);
			
			//tell GL which textures to use
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, objGL.textureDiffuse);
			GL.uniform1i(objGL.diffuseUniform, 0);
			GL.activeTexture(GL.TEXTURE1);
			GL.bindTexture(GL.TEXTURE_2D, objGL.textureNormal);
			GL.uniform1i(objGL.normalUniform, 1);
			
			//tell GL we're using 2D textures?
			GL.enable(GL.TEXTURE_2D);
			
			//tell GL about the vertices we're using
			GL.bindBuffer(GL.ARRAY_BUFFER, objGL.vertexBufferDiffuse);
			GL.vertexAttribPointer(objGL.vertexAttribute, 3, GL.FLOAT, false, 0, 0);
			GL.bindBuffer(GL.ARRAY_BUFFER, objGL.texCoordBufferDiffuse);
			GL.vertexAttribPointer(objGL.texCoordAttribute, 2, GL.FLOAT, false, 0, 0);
			GL.uniform2f(objGL.resolutionUniform, rect.width, rect.height);
			
			//lighting and other shader settings
			GL.uniform4f(objGL.v4AmbientColor, 0.6, 0.6, 1, 0.2);
			GL.uniform4f(objGL.v4LightColor, 1, 0.8, 0.6, 1);
			GL.uniform3f(objGL.v3LightPos, mouseX, mouseY, 50.075);
			GL.uniform3f(objGL.v3Falloff, 0.4, 1, 20);
			GL.uniform1f(objGL.timeUniform, nTime / 1000);
			
			//setup model's transforms and other matrices (not all needed at the moment)
			modelMatrix = new Matrix3D([1.0, 0.0, 0.0, 0.0,
										0.0, 1.0, 0.0, 0.0,
										0.0, 0.0, 1.0, 0.0,
										objGL.fX, objGL.fY, 0.0, 1.0]); //translation row. values should be negative of desired camera position.
			modelMatrix.prependRotation(objGL.fRotation, new Vector3D(0, 0, 1, 0));
			modelViewMatrix = modelMatrix.clone();
			modelViewMatrix.append(viewMatrix);
			modelView3x3Matrix = new Matrix3D([modelViewMatrix.rawData[0], modelViewMatrix.rawData[1], modelViewMatrix.rawData[2], 
															modelViewMatrix.rawData[4], modelViewMatrix.rawData[5], modelViewMatrix.rawData[6], 
															modelViewMatrix.rawData[8], modelViewMatrix.rawData[9], modelViewMatrix.rawData[10]]);
			mvpMatrix = modelViewMatrix.clone();
			mvpMatrix.append(projectionMatrix);
			normalMatrix = modelView3x3Matrix.clone(); //gl_NormalMatrix is transpose(inverse(gl_ModelViewMatrix))
			normalMatrix.invert();
			normalMatrix.transpose();
			
			//tell GL about these matrices
			GL.uniformMatrix4fv(objGL.projectionMatrixUniform, false, new Float32Array(projectionMatrix.rawData));
			GL.uniformMatrix4fv(objGL.modelMatrixUniform, false, new Float32Array(modelMatrix.rawData));
			GL.uniformMatrix4fv(objGL.viewMatrixUniform, false, new Float32Array(viewMatrix.rawData));
			GL.uniformMatrix4fv(objGL.modelViewMatrixUniform, false, new Float32Array(modelViewMatrix.rawData));
			GL.uniformMatrix4fv(objGL.modelView3x3MatrixUniform, false, new Float32Array(modelView3x3Matrix.rawData));
			GL.uniformMatrix4fv(objGL.mvpMatrixUniform, false, new Float32Array(mvpMatrix.rawData));
			GL.uniformMatrix4fv(objGL.normalMatrixUniform, false, new Float32Array(normalMatrix.rawData));
			
			//draw the model
			GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		
			//tell GL to stop using this info to find vertex data?
			GL.disableVertexAttribArray(objGL.vertexAttribute);
			GL.disableVertexAttribArray(objGL.texCoordAttribute);
		}
		
		//clear vertex info from GL
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.bindTexture(GL.TEXTURE_2D, null);
		
		//tell GL to stop doing 2D textures?
		GL.disable(GL.TEXTURE_2D);
		//tell GL to stop using shaders
		GL.useProgram(null);
	}
	
	public function AddObject(strDiffuse:String, strNormal:String, fX:Float, fY:Float, fRotation:Float):GLObject
	{
		var objGL:GLObject = new GLObject(strDiffuse, strNormal, fX, fY, fRotation);
		aObjects.push(objGL);
		return objGL;
	}
}
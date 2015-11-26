package;

import openfl.display.BitmapData;
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


class GLObject 
{
	private var bmpDiffuse:BitmapData;
	private var bmpNormal:BitmapData;
	
	private var strDiffuse:String;
	private var strNormal:String;

	public var textureDiffuse:GLTexture;
	public var textureNormal:GLTexture;
	public var texCoordBufferDiffuse:GLBuffer;
	public var vertexBufferDiffuse:GLBuffer;
	
	public var diffuseUniform:GLUniformLocation;
	public var normalUniform:GLUniformLocation;
	public var modelMatrixUniform:GLUniformLocation;
	public var viewMatrixUniform:GLUniformLocation;
	public var projectionMatrixUniform:GLUniformLocation;
	public var modelViewMatrixUniform:GLUniformLocation;
	public var modelView3x3MatrixUniform:GLUniformLocation;
	public var mvpMatrixUniform:GLUniformLocation;
	public var normalMatrixUniform:GLUniformLocation;
	public var resolutionUniform:GLUniformLocation;
	public var timeUniform:GLUniformLocation;
	public var v3LightPos:GLUniformLocation;
	public var v4LightColor:GLUniformLocation;
	public var v4AmbientColor:GLUniformLocation;
	public var v3Falloff:GLUniformLocation;

	public var texCoordAttribute:Int;
	public var vertexAttribute:Int;
	public var fX:Float;
	public var fY:Float;
	public var fRotation:Float;
	
	public var shaderProgram:GLProgram;
	
	public function new (strDiffuse:String, strNormal:String, fX:Float, fY:Float, fRotation:Float) 
	{
		this.strNormal = strNormal;
		bmpDiffuse = Assets.getBitmapData(strDiffuse);
		bmpNormal  = Assets.getBitmapData(strNormal);

		this.fX = fX;
		this.fY = fY;
		this.fRotation = fRotation;

		if (OpenGLView.isSupported) 
		{
			initializeShaders ();
			
			createBuffers(bmpDiffuse);
			textureDiffuse = createTexture(bmpDiffuse);
			textureNormal = createTexture(bmpNormal);
		}
	}
	
	/**
	 * Setup vertex buffers, scaled to match bmp size.
	 * @param	bmp - bitmap to use for size info
	 */
	private function createBuffers(bmp:BitmapData):Void
	{
		//Origin Top-left
		/*var vertices = [
			
			bmp.width, bmp.height, 0,
			0, bmp.height, 0,
			bmp.width, 0, 0,
			0, 0, 0
			
		];*/
		//Origin Center
		var vertices = [
			
			bmp.width / 2, bmp.height / 2, 0,
			-bmp.width / 2, bmp.height / 2, 0,
			bmp.width / 2, -bmp.height / 2, 0,
			-bmp.width / 2, -bmp.height / 2, 0
		];
		
		vertexBufferDiffuse = GL.createBuffer();
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBufferDiffuse);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (vertices), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		
		var texCoords = [
			
			1, 1, 
			0, 1, 
			1, 0, 
			0, 0, 
			
		];
		
		texCoordBufferDiffuse = GL.createBuffer();
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBufferDiffuse);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (texCoords), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
	}
	
	/**
	 * Generate GL textures for each used bitmap.
	 * @param	bmp - bitmap to use
	 * @return	a GLTexture for the bitmap
	 */
	private function createTexture (bmp:BitmapData):GLTexture
	{
		var pixelData = bmp.image.data;
		
		var texture = GL.createTexture ();
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bmp.width, bmp.height, 0, GL.BGRA_EXT, GL.UNSIGNED_BYTE, pixelData);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.bindTexture (GL.TEXTURE_2D, null);
		return texture;
	}
	
	/**
	 * Setup vertex and fragment (pixel) shaders. 
	 * Loads source code, compiles, and registers shader attributes and uniforms
	 */
	private function initializeShaders ():Void {
		
		var vertexShaderSource = Assets.getText("assets/shaders/vertex.vert");
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			
			throw "Error compiling vertex shader: " + GL.getShaderInfoLog(vertexShader);
			
		}
		
			
		var fragmentShaderSource = Assets.getText("assets/shaders/normals.frag");
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			
			throw "Error compiling fragment shader: " + GL.getShaderInfoLog(fragmentShader);
			
		}
		
		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			
			throw "Unable to initialize the shader program.";
			
		}
		
		vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
		texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
		
		projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
		viewMatrixUniform = GL.getUniformLocation (shaderProgram, "uViewMatrix");
		modelMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelMatrix");
		modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
		modelView3x3MatrixUniform = GL.getUniformLocation (shaderProgram, "uModelView3x3Matrix");
		mvpMatrixUniform = GL.getUniformLocation (shaderProgram, "uMVPMatrix");
		normalMatrixUniform = GL.getUniformLocation (shaderProgram, "uNormalMatrix");
		
		diffuseUniform = GL.getUniformLocation (shaderProgram, "uImage0");
		normalUniform = GL.getUniformLocation (shaderProgram, "uImageN");
		resolutionUniform = GL.getUniformLocation (shaderProgram, "uResolution");

		v3LightPos = GL.getUniformLocation(shaderProgram, "uLightPos");
		v4LightColor = GL.getUniformLocation(shaderProgram, "uLightColor");
		v4AmbientColor = GL.getUniformLocation(shaderProgram, "uAmbientColor");
		v3Falloff = GL.getUniformLocation(shaderProgram, "uFalloff");
		timeUniform = GL.getUniformLocation(shaderProgram, "uTime");
	}
}
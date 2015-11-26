attribute vec3 aVertexPosition;
attribute vec2 aTexCoord;

uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelView3x3Matrix;
uniform mat4 uMVPMatrix;
uniform mat4 uProjectionMatrix;
uniform mat3 uNormalMatrix; //gl_NormalMatrix is transpose(inverse(gl_ModelViewMatrix))
uniform vec3 uLightPos; /* World coordinates */

varying vec3 vLightDir;
varying vec2 vTexCoord;

varying vec3 N;
varying vec3 V;
varying vec3 E;

varying vec3 T;
varying vec3 B;
varying mat3 matTBN;

void main()
{
	vec3 normal = vec3(0.0, 0.0, 1.0);
	vec4 tangent = vec4(1.0, 0.0, 0.0, 0.0);
	vec4 vertex = vec4( aVertexPosition.xyz, 1.0 );
	vec3 vertexWorld = ( uModelMatrix * vertex ).xyz;

	vec3 n = normalize( ( uModelMatrix * vec4( normal, 0.0 ) ).xyz );
	vec3 t = normalize( ( uModelMatrix * vec4( tangent.xyz, 0.0 ) ).xyz );
	vec3 b = normalize( ( uModelMatrix * vec4( ( cross( normal, tangent.xyz ) ), 0.0 ) ).xyz );
	matTBN = mat3( t, b, n );
	vLightDir = uLightPos - vertexWorld;

	vTexCoord = aTexCoord;
    //gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 1.0);
	gl_Position = uMVPMatrix * vertex;
}
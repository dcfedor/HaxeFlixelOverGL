varying vec3 vLightDir;
varying vec2 vTexCoord;
varying vec3 N;
varying mat3 matTBN;

uniform vec3 uLightPos;
uniform vec4 uLightColor;
uniform vec3 uFalloff;
uniform vec4 uAmbientColor;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform sampler2D uImageN;

void main()
{
    vec4 textureColor = texture2D(uImage0, vTexCoord);
	vec3 pixelNormal = matTBN * normalize( texture2D( uImageN, vTexCoord.st ).xyz * 2.0 - 1.0 );
	vec3 normalizedLightDirection = normalize( vLightDir );
	float fLambert = max( 0.0, dot( pixelNormal, normalizedLightDirection ) );
	float fLightDist = length(vLightDir) / uResolution.x;
	
	vec3 vLightDiffuse = (uLightColor.rgb * uLightColor.a) * fLambert;
	vec3 vLightAmbient = uAmbientColor.rgb;// * uAmbientColor.a;
	float fAttenuation = 1.0 / ( uFalloff.x + (uFalloff.y*fLightDist) + (uFalloff.z*fLightDist*fLightDist) );
	vec3 vIntensity = vLightAmbient + vLightDiffuse * fAttenuation;

	vec3 vColorFinal = textureColor.rgb * vIntensity;
	//vec4 vColorFinal = textureColor * fLambert;
	
	//gl_FragColor = vec4(fLambert, fLambert, fLambert, 1.0 );
	gl_FragColor = vec4(vColorFinal.rgb, textureColor.a);
}
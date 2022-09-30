#ifndef DEMOWATER_HELPERS_INCLUDE
#define DEMOWATER_HELPERS_INCLUDE

#include "DemoWaterVariables.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

#define AIR_RI 1.000293

float ComputePixelDepth(float3 positionWS) 
{
	// TransformWorldToView转换出来的z值是为负的
	return - TransformWorldToView(positionWS).z;
}

// From DeclareDepthTexture.hlsl
float SampleRawDepth(float2 uv)
{
	/*
	#if UNITY_REVERSED_Z
		real depth = SampleSceneDepth(uv);
	#else
		// Adjust z to match NDC for OpenGL
		real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
	#endif
	*/

	//Manual mode in case Unity breaks this feature
	//UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, sampler_ScreenTextures_linear_clamp, uv);

	float depth = SampleSceneDepth(uv);

	return depth;
}

float RawDepthToLinear(float rawDepth) 
{
	#if _ORTHO_ON
		float persp = LinearEyeDepth(rawDepth, _ZBufferParams);
		float ortho = (_ProjectionParams.z - _ProjectionParams.y) * (1 - rawDepth) + _ProjectionParams.y;
		return lerp(persp, ortho, unity_OrthoParams.w);
	#else
		return LinearEyeDepth(rawDepth, _ZBufferParams);
	#endif
}

float SampleDepth(float2 uv) 
{
	return RawDepthToLinear(SampleRawDepth(uv));
}

float4 DualAnimatedUV(float2 uv, float4 tilings, float4 speeds) 
{
	float4 coords;

	coords.xy = uv * tilings.xy;
	coords.zw = uv * tilings.zw;

	#if _WORLD_UV
	coords += speeds * _Time.x;
	#else
	coords += frac(speeds * _Time.x);
	#endif

	return coords;
}

//Specular Blinn-phong reflection in world-space
float3 SpecularReflection(Light light, float3 viewDirectionWS, float3 normalWS, float perturbation, float size, float intensity)
{
	float3 upVector = float3(0, 1, 0);
	float3 offset = 0;
	
	#if _RIVER
	//Can't assume the surface is flat. Perturb the normal vector instead
	upVector = lerp(float3(0, 1, 0), normalWS, perturbation);
	#else
	//Perturb the light view vector
	offset = normalWS * perturbation;
	#endif
	
	const float3 halfVec = SafeNormalize(light.direction + viewDirectionWS + offset);
	half NdotH = saturate(dot(upVector, halfVec));

	half specSize = lerp(8196, 64, size);
	float specular = pow(NdotH, specSize);
	
	//Attenuation includes shadows, if available
	const float3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
	
	float3 specColor = attenuatedLightColor * specular * intensity;
	
	#if UNITY_COLORSPACE_GAMMA
	specColor = LinearToSRGB(specColor);
	#endif

	return specColor;
}

float ReflectionFresnel(float3 worldNormal, float3 viewDir, float exponent)
{
	float cosTheta = saturate(dot(worldNormal, viewDir));
	return pow(max(0.0, 1.0 - cosTheta), exponent);
}


// float3 SampleReflections(float3 reflectionVector, float smoothness, float mask, float4 screenPos, float3 wPos, float3 normal, float3 viewDir, float2 pixelOffset)
// {
// 	#if VERSION_GREATER_EQUAL(12,0)
// 	float3 probe = saturate(GlossyEnvironmentReflection(reflectionVector, wPos, smoothness, 1.0)).rgb;
// 	#else
// 	float3 probe = saturate(GlossyEnvironmentReflection(reflectionVector, smoothness, 1.0)).rgb;
// 	#endif

// 	#if !_RIVER //Planar reflections are pointless on curve surfaces, skip
// 	screenPos.xy += pixelOffset.xy * lerp(1.0, 0.1, unity_OrthoParams.w);
// 	screenPos /= screenPos.w;
	
// 	float4 planarLeft = SAMPLE_TEXTURE2D(_PlanarReflectionLeft, sampler_PlanarReflectionLeft, screenPos.xy);
// 	//Terrain add-pass can output negative alpha values. Clamp as a safeguard against this
// 	planarLeft.a = saturate(planarLeft.a);
	
// 	return lerp(probe, planarLeft.rgb, planarLeft.a * mask);
// 	#else
// 	return probe;
// 	#endif
// }

#endif // DEMOWATER_HELPERS_INCLUDE

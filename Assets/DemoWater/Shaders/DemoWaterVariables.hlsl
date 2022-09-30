#ifndef DEMOWATER_VARIABLES_INCLUDE
#define DEMOWATER_VARIABLES_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

SamplerState DemoWater_trilinear_repeat_sampler;
SamplerState DemoWater_linear_repeat_sampler;
SamplerState DemoWater_linear_clamp_sampler;

struct appdata
{
	float4 vertex		: POSITION;
	float4 color		: COLOR;
	float3 normal		: NORMAL;
	float4 tangent 		: TANGENT;
	float2 texcoord		: TEXCOORD0;
};

struct v2f
{
	float4 uv : TEXCOORD0;
	float4 positionCS : SV_POSITION;
	
	float3 normalWS : TEXCOORD1;
	float3 tangentWS : TEXCOORD2;
	float3 bitangentWS : TEXCOORD3;
	
	float3 positionWS : TEXCOORD4;
	float4 screenCoord : TEXCOORD5;
};

struct GlobalData 
{
	float depth;		// Remapped Depth
	float sceneDepth;	// Linear Depth
	float rawDepthDst;	// Raw Depth Distorted
	float pixelDepth;
	float foamMask;
	float2 refractionOffset;
	float2 refractionUV;
	float3 finalColor;
	float4 refractionData;	// RGB: Refraction Color A: Refraction Depth
	float3 clearColor;		// RGB: Clear Color
	float3 shadowColor;
	float3 worldPosition;
	float3 worldNormal;
	float3 worldViewDir;
	float4 screenUV;
	float3 tangentNormal;

	#if _DYNAMIC_EFFECTS_ON
	float4 dynamicData;
	#endif

	#if _DOUBLE_SIDED_ON
	float vFace;
	#endif

	#if _SCATTERING_ON
	float3 scattering;
	#endif

	Light mainLight;
	float3 addLight;
	real3x3 tangentToWorld;

	// Debug purpose only
	float4 debug;
};

void InitializeGlobalData(inout GlobalData data, v2f i)
{
	data.depth = 0;
	data.sceneDepth = 0;
	data.rawDepthDst = 0;
	data.pixelDepth = i.screenCoord.z;
	data.foamMask = 0;
	data.refractionOffset = float2(0, 0);
	data.refractionUV = float2(0, 0);
	data.refractionData = float4(0, 0, 0 ,0);
	data.clearColor = float3(1, 1, 1);
	data.finalColor = float3(1, 1, 1);
	data.shadowColor = float3(1, 1, 1);
	data.tangentNormal = float3(0, 1, 0);
	data.worldPosition = i.positionWS;//float3(IN.normal.w, IN.tangent.w, IN.bitangent.w);
	data.worldNormal = float3(0, 1, 0);
	data.worldViewDir = GetWorldSpaceNormalizeViewDir(data.worldPosition); //SafeNormalize(_WorldSpaceCameraPos.xyz - data.worldPosition);
	data.screenUV = float4(i.screenCoord.xyz / i.screenCoord.w, i.positionCS.z); //ComputeScreenPos(TransformWorldToHClip(data.worldPosition), _ProjectionParams.x);

	#if _DYNAMIC_EFFECTS_ON
	data.dynamicData = float4(0, 0, 0, 0);
	#endif

	#if _DOUBLE_SIDED_ON
	data.vFace = 1;
	#endif

	#if _SCATTERING_ON
	data.scattering = float3(0,0,0);
	#endif

	data.mainLight = GetMainLight(TransformWorldToShadowCoord(data.worldPosition));
	data.addLight = float3(0, 0, 0);
	data.tangentToWorld = float3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz);

	data.debug = float4 (0, 0, 0, 1);
}

#endif // DEMOWATER_VARIABLES_INCLUDE

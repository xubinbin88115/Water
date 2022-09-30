#ifndef DEMOWATER_NORMALS_INCLUDE
#define DEMOWATER_NORMALS_INCLUDE

TEXTURE2D(_NormalMapA);
float4 _NormalMapSpeeds;
float4 _NormalMapTilings;
float _NormalMapAIntensity;
half _NormalStrength;

float3 UnpackScaleNormal(float4 packednormal, float bumpScale)
{
	#if defined(UNITY_NO_DXT5nm)
		return packednormal.xyz * 2 - 1;
	#else
		half3 normal;
		normal.xy = (packednormal.wy * 2 - 1);
		#if (SHADER_TARGET >= 30)
			// SM2.0: instruction count limitation
			// SM2.0: normal scaler is not supported
			normal.xy *= bumpScale;
		#endif
		normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
		return normal;
	#endif
}

float3 NormalBlendReoriented(float3 A, float3 B)
{
	float3 t = A.xyz + float3(0.0, 0.0, 1.0);
	float3 u = B.xyz * float3(-1.0, -1.0, 1.0);
	return (t / t.z) * dot(t, u) - u;
}

void ComputeNormals(inout GlobalData data, v2f IN)
{
	float3 tangentNormal;

	// 同一张纹理通过不同的UV进行采样
	float4 nA = SAMPLE_TEXTURE2D(_NormalMapA, DemoWater_trilinear_repeat_sampler, IN.uv.xy);
	float4 nB = SAMPLE_TEXTURE2D(_NormalMapA, DemoWater_trilinear_repeat_sampler, IN.uv.zw);

	// UnpackNormal然后再乘以_NormalMapAIntensity
	float3 normalA = UnpackScaleNormal(nA, _NormalMapAIntensity);
	float3 normalB = UnpackScaleNormal(nB, _NormalMapAIntensity);

	// 使用类似RNM法线混合算法
	tangentNormal = NormalBlendReoriented(normalA, normalB);
	data.tangentNormal = tangentNormal;

	float3 normalWS = TransformTangentToWorld(tangentNormal, data.tangentToWorld);
	data.worldNormal = normalize(normalWS);
}

#endif // DEMOWATER_NORMALS_INCLUDE

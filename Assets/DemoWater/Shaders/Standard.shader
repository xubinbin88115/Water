Shader "PBRDemoWater/Standard"
{
    Properties
    {
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        
		_SineWaveCount("Wave Count", Range(1,4)) = 1
        _SineWaveA ("Direction, Amplitude, WaveLength", Vector) = (1, 0, 0.2, 4)
        _SineSpeedA ("Sine Speed A", Float) = 1
        _SineWaveB ("Direction, Amplitude, WaveLength", Vector) = (0, 1, 0.2, 4)
        _SineSpeedB ("Sine Speed B", Float) = 1
        _SineWaveC ("Direction, Amplitude, WaveLength", Vector) = (0, 1, 0.05, 4)
        _SineSpeedC ("Sine Speed C", Float) = 1
        _SineWaveD ("Direction, Amplitude, WaveLength", Vector) = (1, 1, 0.05, 4)
        _SineSpeedD ("Sine Speed D", Float) = 1
        
		// _GerstnerWaveCount("Wave Count", Range(1,4)) = 1
        // _GerstnerWaveA("Direction, Steepness, WaveLength ", Vector) = (1,0,0.05,4)
		// _GerstnerSpeedA("Speed A", float) = 1
		// _GerstnerWaveB("Direction, Steepness, WaveLength ", vector) = (0,1,0.05,4)
		// _GerstnerSpeedB("Speed B", float) = 1
		// _GerstnerWaveC("Direction, Steepness, WaveLength ", Vector) = (1,0,0.05,4)
		// _GerstnerSpeedC("Speed C", float) = 1
		// _GerstnerWaveD("Direction, Steepness, WaveLength ", vector) = (1,0,0.05,4)
		// _GerstnerSpeedD("Speed D", float) = 1
    	
    	[HDR]_WaterColor1 ("Water Color1", Color) = (1, 1, 1, 1)
    	[HDR]_WaterColor2 ("Water Color2", Color) = (1, 1, 1, 1)
    	
    	_DepthVertical("Distance Depth", Range(0.01, 16)) = 4
    	_DepthHorizontal("Vertical Depth", Range(0.01 , 8)) = 1
		_DepthExp("Exponential", Range(0 , 1)) = 1
    	
		_RefractionStrength("Refraction Strength", Range(0 , 3)) = 0.1
    	
		_EdgeFade("Edge Fade", Float) = 0.1
    	
		_NormalMapA("Normal Map A", 2D) = "bump" {}
		_NormalMapTilings("Normal Map: Tilings", Vector) = (1,1,1,1)
		_NormalMapSpeeds("Normal Map: Speeds", Vector) = (1,1,0.5,0.5)
		_NormalMapAIntensity("Normal Map: Intensity", Range(0,1)) = 1
		_NormalStrength("WaveNormal Strength", Range(0, 1)) = 0.1
    	
    	
		_FoamMap("Foam Map", 2D) = "white" {}
		_ShoreWaveRamp("Shore Wave Ramp", 2D) = "white" {}
    	
		_NoiseMap("Noise Map", 2D) = "white" {}
		_NoiseMapTilingOffset("Noise Map: Tilings, Offset", Vector) = (0.1,0.1,0.1,0.1)
    	_NoiseStrength("Noise Strength", Range(0, 1)) = 0.3
        
		_CausticsBrightness("Caustics Brightness", Float) = 2
		_CausticsTiling("Caustics Tiling", Float) = 0.5
		_CausticsSpeed("Caustics Speed", Float) = 0.1
		_CausticsDistortion("Caustics Distortion", Range(0, 1)) = 0.15
		_CausticsTex("Caustics Mask", 2D) = "black" {}

		_SparkleIntensity("Sparkle Intensity", Range(0 , 10)) = 0
		_SparkleSize("Sparkle Size", Range( 0 , 1)) = 0.28

		_SunReflectionSize("Sun Size", Range(0 , 1)) = 0.5
		_SunReflectionStrength("Sun Strength", Float) = 10
		_SunReflectionDistortion("Sun Distortion", Range( 0 , 2)) = 0.49

		_ReflectionStrength("Reflection Strength", Range( 0 , 1)) = 0
		_ReflectionDistortion("Reflection Distortion", Range( 0 , 2)) = 0.05
		_ReflectionBlur("Reflection Blur", Range( 0 , 1)) = 0	
		_ReflectionFresnel("Reflection Fresnel", Range( 0.01 , 20)) = 5	

        [Toggle(_DEBUG)] _Debug ("Debug Enabled", Float) = 0
		[Toggle(_GERSTNER)] _Gerstner ("Gerstner Enabled", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile __ _DEBUG _GERSTNER
            
            #include "DemoWaterWaves.hlsl"
            #include "DemoWaterHelpers.hlsl"
            #include "DemoWaterNormals.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            half4 _Color;
            half4 _WaterColor1;
            half4 _WaterColor2;
            
            float _DepthVertical;
            float _DepthHorizontal;
            half _DepthExp;

			float _ReflectionStrength;
			float _ReflectionDistortion;
			float _ReflectionBlur;
			float _ReflectionFresnel;
            
            half _EdgeFade;
            
			TEXTURE2D(_FoamMap);
			TEXTURE2D(_ShoreWaveRamp);
            
			TEXTURE2D(_NoiseMap);
            float4 _NoiseMapTilingOffset;
            float _NoiseStrength;
            float _RefractionStrength;

			TEXTURE2D(_CausticsTex);
			float _CausticsDistortion;
			float _CausticsSpeed;
			float _CausticsTiling;
			float _CausticsBrightness;

			float _SparkleSize;
			float _SparkleIntensity;

			float _SunReflectionSize;
			float _SunReflectionStrength;
			float _SunReflectionDistortion;

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
            	
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                ComputeSineWaves(v);

                o.positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.positionCS = TransformWorldToHClip(o.positionWS);
            	
				VertexNormalInputs vertexTBN = GetVertexNormalInputs(v.normal, v.tangent);
				o.normalWS = vertexTBN.normalWS;
				o.tangentWS = vertexTBN.tangentWS;
				o.bitangentWS = vertexTBN.bitangentWS;
            	
				o.screenCoord = ComputeScreenPos(o.positionCS);
				o.screenCoord.z = ComputePixelDepth(o.positionWS);

				o.uv = DualAnimatedUV(v.texcoord, _NormalMapTilings, _NormalMapSpeeds);
            	
                return o;
            }

			float GetWaterDepthMask(float viewDepth, float verticalDepth)
			{
				float depthAttenuation = 1.0 - exp(-viewDepth * _DepthVertical * 0.1);
				float heightAttenuation = saturate(lerp(verticalDepth * _DepthHorizontal, 1.0 - exp(-verticalDepth * _DepthHorizontal), _DepthExp));
				return max(depthAttenuation, heightAttenuation);
			}

            half4 frag (v2f i) : SV_Target
            {
				UNITY_SETUP_INSTANCE_ID(i);
            	
				GlobalData data = (GlobalData)0;
				InitializeGlobalData(data, i);

            	ComputeNormals(data, i);
            	
                Light light = GetMainLight();

            	float3 viewDir = GetWorldSpaceViewDir(data.worldPosition);
            	float3 viewDirNorm = normalize(viewDir);
            	half3 waveNormal = i.normalWS;

            	// viewDepth是视图空间下的深度值
            	float sceneDepth = SampleDepth(data.screenUV.xy);
            	float viewDepth = saturate(sceneDepth - data.pixelDepth);
            	
            	// 世界空间下的场景坐标，没搞懂怎么算出来的
            	float3 sceneWorldPos = GetCurrentViewPosition().xyz - sceneDepth * (viewDir / i.screenCoord.w);
            	
            	// 下面也是计算世界坐标的方法，但是比较中庸的写法
				// float rawDepth = SampleSceneDepth(data.screenUV.xy);
				// #if UNITY_REVERSED_Z
				// rawDepth = rawDepth;
				// #else
				// // Adjust z to match NDC for OpenGL
				// rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawDepth);
				// #endif
				// float3 sceneWorldPos = ComputeWorldSpacePosition(data.screenUV.xy, rawDepth, UNITY_MATRIX_I_VP);
            	
            	// 世界空间下的深度
            	float3 verticalDepth = length((data.worldPosition - sceneWorldPos) * waveNormal);

            	float depthMask = GetWaterDepthMask(viewDepth, verticalDepth);
            	
            	//////////////////////////////////////////
            	// 水体通透性
            	half3 baseColor = lerp(_WaterColor2, _WaterColor1, depthMask);

            	// 法向方向的偏移
				float4 pixelOffset = float4(0, 0, 0, 0);
            	pixelOffset.xy = data.worldNormal.xz * (_RefractionStrength * 0.1);
            	
				float4 screenPos = i.screenCoord + pixelOffset;
            	float3 sceneColor = SampleSceneColor(screenPos.xy / screenPos.w).rgb;
            	float3 waterColor = lerp(sceneColor, baseColor, 0.8);

            	//////////////////////////////////////////
            	// 岸边缘渐变
				float edgeFade = saturate(verticalDepth / (_EdgeFade * 0.01));
            	
            	//////////////////////////////////////////
            	// 噪声贴图
            	float2 noiseUV = i.positionWS.xz * _NoiseMapTilingOffset.xy + _NoiseMapTilingOffset.zw;
				float noise = SAMPLE_TEXTURE2D(_NoiseMap, DemoWater_trilinear_repeat_sampler, noiseUV).z;

            	// 泡沫贴图
				float4 foam = SAMPLE_TEXTURE2D(_FoamMap, DemoWater_trilinear_repeat_sampler, i.positionWS.xz + noise);

            	float depth = viewDepth + noise * _NoiseStrength;
            	half foamUV = frac(depth + _Time.y * 0.08);
				float4 ramp = SAMPLE_TEXTURE2D(_ShoreWaveRamp, DemoWater_trilinear_repeat_sampler, half2(foamUV, 0.5));
            	float waveFoam1 = dot(ramp.xxy, foam.xxy);
            	
            	foamUV = frac(depth + _Time.y * 0.08 + 0.5);
				ramp = SAMPLE_TEXTURE2D(_ShoreWaveRamp, DemoWater_trilinear_repeat_sampler, half2(foamUV, 0.5));
            	float waveFoam2 = dot(ramp.xxy, foam.xxy);
            	
            	float foamMask = 1 - saturate(pow(viewDepth, 5));
            	float waveFoam = max(waveFoam1, waveFoam2) * foamMask;

            	//////////////////////////////////////////
				// 焦散
				float2 casticsUV = i.positionWS.xz + lerp(waveNormal.xz, data.worldNormal.xz, _CausticsDistortion);
				float2 casticsUV1 = casticsUV * _CausticsTiling + _Time.y * _CausticsSpeed;
				float3 caustics1 = SAMPLE_TEXTURE2D(_CausticsTex, DemoWater_trilinear_repeat_sampler, casticsUV1).rgb;

				float2 casticsUV2 = casticsUV * _CausticsTiling * 0.8 - _Time.y * _CausticsSpeed;
				float3 caustics2 = SAMPLE_TEXTURE2D(_CausticsTex, DemoWater_trilinear_repeat_sampler, casticsUV2).rgb;

				float causticsMask = saturate(1 - depthMask);
				float3 caustics = min(caustics1, caustics2) * causticsMask;
				caustics = caustics * _CausticsBrightness; 

            	//////////////////////////////////////////
				// Sparkles
            	// step(a, x) 如果x<a, 返回0；否则返回1
				half3 sparkles = light.color * saturate(step(_SparkleSize, data.tangentNormal.y)) * _SparkleIntensity;
				half sunAngle = saturate(dot(i.normalWS, light.direction));
				half angleMask = saturate(sunAngle * 10);
				sparkles *= angleMask;
    
            	//////////////////////////////////////////
				// 高光
				float3 sunReflectionNormals = data.worldNormal;
				half3 sunSpec = SpecularReflection(light, viewDirNorm, sunReflectionNormals, _SunReflectionDistortion, _SunReflectionSize, _SunReflectionStrength);

            	//////////////////////////////////////////
				// 反射
				// float3 refWorldTangentNormal = lerp(i.normalWS, normalize(i.normalWS + data.worldNormal), _ReflectionDistortion);
				float3 refWorldTangentNormal = lerp(i.normalWS, data.worldNormal, _ReflectionDistortion);
				float3 reflectionVector = reflect(-viewDirNorm, refWorldTangentNormal);
				float3 reflections = saturate(GlossyEnvironmentReflection(reflectionVector, _ReflectionBlur, 1.0)).rgb;

				float cosTheta = saturate(dot(refWorldTangentNormal, viewDirNorm));
				half reflectionFresnel = pow(max(0, 1.0 - cosTheta), _ReflectionFresnel);
				// float refelctionMask = _ReflectionStrength + (1 - _ReflectionStrength) * reflectionFresnel;
				float refelctionMask = _ReflectionStrength * reflectionFresnel; 
            	
				// half reflectionFresnel = ReflectionFresnel(refWorldTangentNormal, viewDirNorm, _ReflectionFresnel);
				// float refelctionMask = _ReflectionStrength + (1 - _ReflectionStrength) * reflectionFresnel;

            	//////////////////////////////////////////
				// 漫反射向量，由顶点法向纹理法线插值
            	float3 diffuseNormal = lerp(waveNormal, data.worldNormal, _NormalStrength);
            	half3 lightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                half3 diffuse = waterColor * LightingLambert(lightColor, light.direction, diffuseNormal);

            	//////////////////////////////////////////
				// 混合
				float3 finalColor = diffuse + waveFoam + caustics + sunSpec + sparkles;
				finalColor = lerp(finalColor, reflections, refelctionMask); 
            	
            	// return float4(1 - depthMask.xxx, 1);
                return float4(finalColor, edgeFade);
            }
            ENDHLSL
        }
    }
}

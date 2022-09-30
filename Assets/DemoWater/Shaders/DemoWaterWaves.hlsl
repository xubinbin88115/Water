#ifndef DEMOWATER_WAVES_INCLUDE
#define DEMOWATER_WAVES_INCLUDE

#include "DemoWaterVariables.hlsl"

struct WaveData {
	float4 wave;
	float speed;
};

float4 _GerstnerWaveA;
float4 _GerstnerWaveB;
float4 _GerstnerWaveC;
float4 _GerstnerWaveD;
float _GerstnerSpeedA;
float _GerstnerSpeedB;
float _GerstnerSpeedC;
float _GerstnerSpeedD;
float _GerstnerWaveCount;

float3 GerstnerWave(WaveData data, float3 p, inout float3 tangent, inout float3 binormal)
{
    // to do in inspector
    //float angle = wave.x;
    //float2 dir = float2(cos(angle), sin(angle));

    float speed = _Time.y * data.speed;
    float steepness = data.wave.z * 0.1;
    float wavelength = data.wave.w;
    float k = 6.28318 / wavelength; // 2 * PI
    float c = sqrt(9.8 / k);
    float2 d = normalize(data.wave.xy);
    float f = k * (dot(d, p.xz) - c * speed);
    float a = steepness / k;
    float sinF = sin(f);
    float cosF = cos(f);
    float sinSteepness = steepness * sinF;
    float cosSteepness = steepness * cosF;

    tangent += float3(
        -d.x * d.x * sinSteepness,
        d.x * cosSteepness,
        -d.x * d.y * sinSteepness
        );
    binormal += float3(
        -d.x * d.y * sinSteepness,
        d.y * cosSteepness,
        -d.y * d.y * sinSteepness
        );
    return float3(
        d.x * (a * cosF),
        a * sinF,
        d.y * (a * cosF)
        );
}

// 盖斯特纳波
void ComputeGerstnerWaves(inout appdata v)
{
    float3 gridPoint = TransformObjectToWorld(v.vertex.xyz);
    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);
    float3 p = gridPoint;

    WaveData waveData[4];
    waveData[0].wave = _GerstnerWaveA;
    waveData[0].speed = _GerstnerSpeedA;

    waveData[1].wave = _GerstnerWaveB;
    waveData[1].speed = _GerstnerSpeedB;

    waveData[2].wave = _GerstnerWaveC;
    waveData[2].speed = _GerstnerSpeedC;

    waveData[3].wave = _GerstnerWaveD;
    waveData[3].speed = _GerstnerSpeedD;

    UNITY_LOOP
    for (uint i = 0; i < _GerstnerWaveCount; i++)
    {
        p += GerstnerWave(waveData[i], gridPoint, tangent, binormal);
    }

    float3 normal = normalize(cross(binormal, tangent));

    p = TransformWorldToObject(p);

    // float fakeOffset = (p.y + _WaveEffectsBoost) - v.vertex.y;
    // float amplitude = _WaveAmplitude;

    // #if _DISPLACEMENT_MASK_ON
    // amplitude *= v.color.b;
    // #endif

    // v.waveHeight = amplitude * (fakeOffset * 0.5 + 0.5);
    v.vertex.xyz = p;//lerp(v.vertex.xyz, p, amplitude);
    v.normal = normal;//lerp(v.normal, normal, amplitude * _WaveNormal);
}

float _SineWaveCount;
float4 _SineWaveA;
float4 _SineWaveB;
float4 _SineWaveC;
float4 _SineWaveD;

float _SineSpeedA;
float _SineSpeedB;
float _SineSpeedC;
float _SineSpeedD;

float3 SineWave(WaveData data, float3 p, inout float3 tangent, inout float3 binormal)
{
    float w = 6.28318 / data.wave.w;
    float a = data.wave.z;
    float2 d = normalize(data.wave.xy);
    float s = data.speed;
    float t = _Time.y;
    
    float f = w * (dot(d, p.xz) + s * t);
    float sinF = sin(f);
    float cosF = cos(f);

    tangent += float3(1, a * w * d.x * cosF, 0);
    binormal += float3(0, a * w * d.y * cosF, 1);
    return float3(0, a * sinF, 0);
}

// 正弦波
void ComputeSineWaves(inout appdata v)
{
    float3 gridPoint = v.vertex.xyz;
    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);
    float3 p = gridPoint;
    
    WaveData waveData[4];
    waveData[0].wave = _SineWaveA;
    waveData[0].speed = _SineSpeedA;
    
    waveData[1].wave = _SineWaveB;
    waveData[1].speed = _SineSpeedB;
    
    waveData[2].wave = _SineWaveC;
    waveData[2].speed = _SineSpeedC;
    
    waveData[3].wave = _SineWaveD;
    waveData[3].speed = _SineSpeedD;
    
    UNITY_LOOP
    for (uint i = 0; i < _SineWaveCount; ++i)
    {
        p += SineWave(waveData[i], gridPoint, tangent, binormal);
    }

    float3 normal = normalize(float3(-tangent.y, 1, -binormal.y));
    v.vertex.xyz = p;
    v.normal = normal;
    v.tangent.xyz = normalize(tangent);
}

#endif // DEMOWATER_WAVES_INCLUDE

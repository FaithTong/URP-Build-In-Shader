#ifndef FLOWING_LIGHT_INPUT_INCLUDED
#define FLOWING_LIGHT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// Declare property variables
CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half _Metallic;
half _Smoothness;
half _BumpScale;
half _OcclusionStrength;

half _LightSwitch;
half4 _LightColor;
half _FlowSpeed;
CBUFFER_END

TEXTURE2D(_MetallicGlossMap);       SAMPLER(sampler_MetallicGlossMap);
TEXTURE2D(_OcclusionMap);           SAMPLER(sampler_OcclusionMap);

//Define flowing light dynamic funcation
half FlowingLight (float2 uv)
{
    half range01 = frac(_Time.y * _FlowSpeed);
    return step(uv.x, range01);
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData.albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb * _BaseColor.rgb;

    half4 metallicGloss = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv);
    outSurfaceData.metallic = metallicGloss.r * _Metallic;
    outSurfaceData.smoothness = metallicGloss.a * _Smoothness;

    half4 normal = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
    outSurfaceData.normalTS = UnpackNormalScale(normal, _BumpScale);

    half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).r;
    outSurfaceData.occlusion = lerp(1.0, occ, _OcclusionStrength);

    half3 light = FlowingLight(uv) * _LightColor.rgb;
    outSurfaceData.emission = _LightSwitch ? light : half3(0.0, 0.0, 0.0);

    //Set up default values
    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
    outSurfaceData.alpha = 1.0;
}

#endif

#ifndef CAR_PAINT_INPUT_INCLUDED
#define CAR_PAINT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _PigmentColor;
half4 _EdgeColor;
half _EdgeFactor;
half _Occlusion;

half4 _SpecularColor;
half _FacingSpecular;
half _PerpendicularSpecular;
half _SpecularFactor;
half _Smoothness;

half4 _ClearCoatColor;
half _ReflectionContrast;
half _FacingReflection;
half _PerpendicularReflection;
half _ReflectionFactor;

half _FlakeDensity;
half _FlakeReflection;
half _FlakeFactor;
CBUFFER_END

TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
TEXTURE2D(_FlakeMap);           SAMPLER(sampler_FlakeMap);

//Define fresnel function
half FresnelEffect(float3 NormalWS, float3 ViewDirWS, half Power)
{
    half NdotV = saturate(dot(normalize(NormalWS), normalize(ViewDirWS)));
    return pow((1.0 - NdotV), Power);
}

inline void InitializeStandardLitSurfaceData(float4 uv, float3 NormalWS, float3 ViewDirWS, out SurfaceData outSurfaceData)
{
    half albedoFresnel = FresnelEffect(NormalWS, ViewDirWS, _EdgeFactor);
    outSurfaceData.albedo = lerp(_PigmentColor.rgb, _EdgeColor.rgb, albedoFresnel);

    //Flake for Specular and Smoothness
    half flakeTex = SAMPLE_TEXTURE2D(_FlakeMap, sampler_FlakeMap, uv.zw).r;
    half flakeFresnel = 1.0 - FresnelEffect(NormalWS, ViewDirWS, _FlakeFactor);
    half flake = flakeTex * _FlakeReflection * flakeFresnel;

    half specularFresnel = FresnelEffect(NormalWS, ViewDirWS, _SpecularFactor);
    outSurfaceData.specular = lerp(_FacingSpecular, _PerpendicularSpecular, specularFresnel) * _SpecularColor.rgb + flake;

    outSurfaceData.smoothness = _Smoothness + flake;

    half clearcoatFresnel = FresnelEffect(NormalWS, ViewDirWS, _ReflectionFactor);
    outSurfaceData.emission = lerp(_FacingReflection, _PerpendicularReflection, clearcoatFresnel) * _ClearCoatColor.rgb;

    half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv.xy).r;
    outSurfaceData.occlusion = lerp(1.0, occ, _Occlusion);

    //Set up default values in SurfaceData Structure
    outSurfaceData.metallic = 1.0;
    outSurfaceData.normalTS = half3(0.0, 0.0, 1.0);
    outSurfaceData.alpha = 1.0;
}

#endif

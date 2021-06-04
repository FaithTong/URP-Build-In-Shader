#ifndef CAR_PAINT_FORWARD_PASS_INCLUDED
#define CAR_PAINT_FORWARD_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uv                       : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
    float3 normalWS                 : TEXCOORD2;
    float3 viewDirWS                : TEXCOORD3;
    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);
    inputData.viewDirectionWS = SafeNormalize(input.viewDirWS);
    inputData.shadowCoord = float4(0, 0, 0, 0);
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
}

//Adjust reflection contrast
half3 UnityContrast(half3 In, half Contrast)
{
    half midpoint = pow(0.5, 2.2);
    return lerp(midpoint, In, Contrast);
}

//Get cubemap reflection
half3 GetReflection(float3 viewDirWS, float3 normalWS)
{
    float3 reflectVec = reflect(-viewDirWS, normalWS);

    //Sample cubemap in Environment and decode
    return DecodeHDREnvironment(SAMPLE_TEXTURECUBE(unity_SpecCube0, samplerunity_SpecCube0, reflectVec), unity_SpecCube0_HDR);
}

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.normalWS = normalInput.normalWS;
    output.viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.uv.xy = input.texcoord;
    output.uv.zw = input.texcoord * _FlakeDensity;

    return output;
}

half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, input.normalWS, input.viewDirWS, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    //Adjust reflection contrast
    half3 contrastReflection = UnityContrast(GetReflection(input.viewDirWS, input.normalWS), _ReflectionContrast);
    surfaceData.emission = saturate(surfaceData.emission * contrastReflection);

    half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);
    
    return color;
}

#endif

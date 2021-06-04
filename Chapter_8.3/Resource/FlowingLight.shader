Shader "Example/FlowingLight"
{
    Properties
    {
        [Header(Base Properties)]
        [Space(10)]
        [NoScaleOffset] _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1.0, 1.0, 1.0, 0.0)

        [NoScaleOffset] _MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.0

        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Strength", Range(0.0, 1.0)) = 1.0

        [NoScaleOffset] _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0

        [Header(Light Properties)]
        [Space(10)]
        [Toggle] _LightSwitch("Light Switch", Float) = 0
        [HDR] _LightColor("Light Color", Color) = (3.4, 2.6, 1.7, 1.0)
        _FlowSpeed("Flow Speed", Float) = 1.0
    }
    SubShader
    {
        Tags
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_instanceing

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "FlowingLightInput.hlsl"
            #include "FlowingLightForwardPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}

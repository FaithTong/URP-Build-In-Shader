Shader "Example/Car Paint"
{
    Properties
    {
        [Header(____________________ Base Layer ____________________)]
        [Space(10.0)]
        [MainColor] _PigmentColor("Pigment Color", Color) = (1,1,1,1)
        _EdgeColor("Edge Color", Color) = (0,0,0,0)
        [PowerSlider(4.0)] _EdgeFactor("Edge Falloff Factor", Range(0.01, 10.0)) = 0.3

        [NoScaleOffset] _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _Occlusion("Occlusion", Range(0.0, 1.0)) = 1.0

        _SpecularColor("Specular Color", Color) = (0,0,0,0)
        _FacingSpecular("Facing Specular", Range(0.0, 1.0)) = 0.1
        _PerpendicularSpecular("Perpendicular Specular", Range(0.0, 1.0)) = 0.3
        [PowerSlider(4.0)] _SpecularFactor("Specular Falloff Factor", Range(0.01, 10.0)) = 0.3

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.1

        [Header(__________________ Clear Coat Layer __________________)]
        [Space(10.0)]
        _ClearCoatColor("Clear Coat Color", Color) = (0.5, 0.5, 0.5)
        _ReflectionContrast("Reflection Contrast", Range(0.01, 2.0)) = 1.0
        _FacingReflection("Facing Reflection", Range(0.0, 1.0)) = 0.1
        _PerpendicularReflection("Perpendicular Reflection", Range(0.0, 1.0)) = 1.0
        [PowerSlider(4.0)] _ReflectionFactor("Reflection Falloff Factor", Range(0.01, 10)) = 1.0

        [Header(______________________ Flake Layer ______________________)]
        [Space(10.0)]
        [NoScaleOffset] _FlakeMap("Flake Map", 2D) = "black" {}
        _FlakeDensity("Flake Density", Float) = 1.0
        [PowerSlider(4.0)] _FlakeReflection("Flake Reflection", Range(0.0, 10.0)) = 0.0
        _FlakeFactor("Flake Falloff Factor", Range(0.01, 1.0)) = 0.1
    }
    SubShader
    {
        Tags
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
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

            #pragma multi_compile_instancing

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            //Set specular as current workflowk
            #define _SPECULAR_SETUP

            #include "CarPaintInput.hlsl"
            #include "CarPaintForwardPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}

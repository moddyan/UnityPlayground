// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/part 11 - transparency"
{
    Properties {
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1
		
		[NoScaleOffset] _MetallicMap ("Metallic", 2D) = "white" {}
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.1
		
		[NoScaleOffset] _EmissionMap ("Emission", 2D) = "black" {}
		_Emission ("Emission", Color) = (0, 0, 0)
		
		_DetailTex ("Detail Albedo", 2D) = "gray" {}
		[NoScaleOffset] _DetailNormalMap ("Detail Normals", 2D) = "bump" {}
		_DetailBumpScale ("Detail Bump Scale", Float) = 1
		
		[NoScaleOffset] _OcclusionMap ("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
		
		[NoScaleOffset] _DetailMask ("Detail Mask", 2D) = "white" {}
    }

    SubShader {
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
        
            CGPROGRAM
            #pragma target 3.0
          
            #pragma shader_feature _METALLIC_MAP  
            #pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
            #pragma shader_feature _NORMAL_MAP
            #pragma shader_feature _OCCLUSION_MAP
	        #pragma shader_feature _EMISSION_MAP
	        #pragma shader_feature _DETAIL_MASK
	        #pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
	
            #pragma multi_compile _ VERTEXLIGHT_ON
            #pragma multi_compile _ SHADOWS_SCREEN
             
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS 

            #include "mylighting.cginc"

            ENDCG

        }
        
        Pass {
			Tags {
				"LightMode" = "ForwardAdd"
			}
            
            Blend One One
            ZWrite Off
            
			CGPROGRAM

			#pragma target 3.0
			
            #pragma shader_feature _ _METALLIC_MAP  
            #pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
            #pragma shader_feature _NORMAL_MAP
            #pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
			
            //#pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT
			#pragma multi_compile_fwdadd_fullshadows
                        
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			
            #include "mylighting.cginc"

			ENDCG
		}
		
		Pass {
			Tags {
				"LightMode" = "ShadowCaster"
			}
			
			CGPROGRAM

			#pragma target 3.0
			                    
			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

			#include "myshadow.cginc"

			ENDCG
		}
    }
  
    CustomEditor "MyLightingShaderGUI"
}

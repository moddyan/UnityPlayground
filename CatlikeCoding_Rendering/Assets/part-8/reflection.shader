// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/part 8 - reflection"
{
    Properties {
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.1
		_DetailTex ("Detail Texture", 2D) = "gray" {}
		[NoScaleOffset] _DetailNormalMap ("Detail Normals", 2D) = "bump" {}
		_DetailBumpScale ("Detail Bump Scale", Float) = 1
    }

    SubShader {
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
        
            CGPROGRAM
            #pragma target 3.0
            
            #pragma multi_compile _ VERTEXLIGHT_ON
            #pragma multi_compile _ SHADOWS_SCREEN
             
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS 

            #include "part8.cginc"

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

            //#pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT
			#pragma multi_compile_fwdadd_fullshadows
                        
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			
            #include "part8.cginc"

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
  
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/part 5 - multi light shader"
{
    Properties {
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _MainTex("Albedo", 2D) = "White" {}
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range (0, 1)) = 0.5
    }

    SubShader {
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
        
            CGPROGRAM
            #pragma target 3.0
            
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "part5.cginc"

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

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			
            #define POINT

            #include "part5.cginc"

			ENDCG
		}
    }
  
}

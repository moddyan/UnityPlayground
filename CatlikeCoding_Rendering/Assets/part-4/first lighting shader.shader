// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/First lighting shader"
{
    Properties {
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _MainTex("Albedo", 2D) = "White" {}
        _SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
        _Smoothness ("Smoothness", Range (0, 1)) = 0.5
    }

    SubShader {
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
        
            CGPROGRAM
            
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityStandardBRDF.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _SpecularTint;
            float _Smoothness;


            struct VertexData {
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};


            struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos: TEXCOORD2;
			};

            Interpolators MyVertexProgram (VertexData v) {
                Interpolators i;
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.position = UnityObjectToClipPos(v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                return i;
			}

			float4 MyFragmentProgram (Interpolators i): SV_TARGET {
			    i.normal = normalize(i.normal);
                
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //float3 reflectionDir = reflect(-lightDir, i.normal);
                
                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                float3 diffuse = albedo * lightColor * saturate(dot(lightDir, i.normal));
                                
                float3 halfVector = normalize(lightDir + viewDir);
                float3 specular = _SpecularTint.rgb * pow(saturate(dot(halfVector, i.normal)),
                           _Smoothness * 100);
                
                //return pow(saturate(dot(viewDir, reflectionDir)),
                //            _Smoothness * 100);
                           
			
			    return float4(diffuse + specular, 1);
			}


            ENDCG

        }        
    }
  
}

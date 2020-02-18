// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/First lighting shader"
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

            #include "UnityPBSLighting.cginc"
			

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Metallic;
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

            // part 4
			// float4 MyFragmentProgram (Interpolators i): SV_TARGET {
			//     i.normal = normalize(i.normal);
                
            //     float3 lightDir = _WorldSpaceLightPos0.xyz;
            //     float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
            //     //float3 reflectionDir = reflect(-lightDir, i.normal);
                
            //     float3 lightColor = _LightColor0.rgb;
            //     float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                
            //     float3 specularTint;
            //     float oneMinusReflectivity;
            //     //albedo = EnergyConservationBetweenDiffuseAndSpecular(
            //     //    albedo, _SpecularTint.rgb, oneMinusReflectivity); 
            //     albedo = DiffuseAndSpecularFromMetallic(
			// 		albedo, _Metallic, specularTint, oneMinusReflectivity
			// 	);
                
            //     float3 diffuse = albedo * lightColor * saturate(dot(lightDir, i.normal));
                                
            //     float3 halfVector = normalize(lightDir + viewDir);
            //     float3 specular = specularTint * pow(saturate(dot(halfVector, i.normal)),
            //                _Smoothness * 100);
                
            //     //return pow(saturate(dot(viewDir, reflectionDir)),
            //     //            _Smoothness * 100);
                           
			
			//     return float4(diffuse + specular, 1);
			// }

            // part 5, pbs
	        float4 MyFragmentProgram (Interpolators i): SV_TARGET {
			    i.normal = normalize(i.normal);
                
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //float3 reflectionDir = reflect(-lightDir, i.normal);
                
                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                
                float3 specularTint;
                float oneMinusReflectivity;
                //albedo = EnergyConservationBetweenDiffuseAndSpecular(
                //    albedo, _SpecularTint.rgb, oneMinusReflectivity); 
                albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);
                
                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                light.ndotl = saturate(dot(i.normal, lightDir));
                
                UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;
                
                return UNITY_BRDF_PBS(
                    albedo, specularTint,
                    oneMinusReflectivity, _Smoothness,
                    i.normal, viewDir,
                    light, indirectLight
                );
                       
			}

            ENDCG

        }        
    }
  
}

#ifndef PART_5_INCLUDE
#define PART_5_INCLUDE

#include "AutoLight.cginc"
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

UnityLight CreateLight (Interpolators i) {
	UnityLight light;
	//light.dir = _WorldSpaceLightPos0.xyz;
	light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

// part 5, pbs
float4 MyFragmentProgram (Interpolators i): SV_TARGET {
    i.normal = normalize(i.normal);
    
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
    
    float3 specularTint;
    float oneMinusReflectivity;

    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
       
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;
    
    return UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir,
        CreateLight(i), indirectLight
    );
           
}

#endif
#ifndef PART_6_INCLUDE
#define PART_6_INCLUDE

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

float4 _Tint;
sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

float _Metallic;
float _Smoothness;


struct VertexData {
    float4 position : POSITION;
    float3 normal : NORMAL;
    float4 tangent: TANGENT;
    float2 uv : TEXCOORD0;
};


struct Interpolators {
    float4 position : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float4 tangent: TEXCOORD2;    
    float3 worldPos: TEXCOORD3;
    
#ifdef VERTEXLIGHT_ON
    float3 vertexLightColor : TEXCOORD4;
#endif
    
};

void ComputeVertexLightColor (inout Interpolators i) {
#ifdef VERTEXLIGHT_ON
    i.vertexLightColor = Shade4PointLights(
        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
        unity_LightColor[0].rgb, unity_LightColor[1].rgb,
        unity_LightColor[2].rgb, unity_LightColor[3].rgb,
        unity_4LightAtten0, i.worldPos, i.normal
    );
#endif
}

Interpolators MyVertexProgram (VertexData v) {
    Interpolators i;
    i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
    i.position = UnityObjectToClipPos(v.position);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
    i.worldPos = mul(unity_ObjectToWorld, v.position);
    ComputeVertexLightColor(i);
    return i;
}

UnityLight CreateLight (Interpolators i) {
	UnityLight light;
#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
	light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
	light.dir = _WorldSpaceLightPos0.xyz;
#endif
	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight (Interpolators i) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif
	
	#ifdef FORWARD_BASE_PASS
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
	#endif
	
	return indirectLight;
}

void InitializeFragmentNormal(inout Interpolators i) {
	//float2 du = float2(_HeightMap_TexelSize.x * 0.5, 0);
	//float u1 = tex2D(_HeightMap, i.uv - du);
	//float u2 = tex2D(_HeightMap, i.uv + du);
	
	//float2 dv = float2(0, _HeightMap_TexelSize.y * 0.5);
	//float v1 = tex2D(_HeightMap, i.uv - dv);
	//float v2 = tex2D(_HeightMap, i.uv + dv);
	
	//i.normal = float3(u1 - u2, 1, v1 - v2);

    //i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 -1;
    //i.normal.xy *= _BumpScale;
    //i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
    
    float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
    float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
    
    //i.normal = float3(mainNormal.xy / mainNormal.z + detailNormal.xy / detailNormal.z, 1);
    //whiteout bending
    //i.normal = float3(mainNormal.xy + detailNormal.xy, mainNormal.z * detailNormal.z);
    float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);
    tangentSpaceNormal = tangentSpaceNormal.xzy;
    
    float3 binormal = cross(i.normal, i.tangent.xyz) * (i.tangent.w * unity_WorldTransformParams.w);
    
  	i.normal = normalize(
		tangentSpaceNormal.x * i.tangent +
		tangentSpaceNormal.y * binormal +
		tangentSpaceNormal.z * i.normal
	);
   
}


float4 MyFragmentProgram (Interpolators i): SV_TARGET {
    InitializeFragmentNormal(i);
    
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    
    float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;
    albedo *= tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;
        
    float3 specularTint;
    float oneMinusReflectivity;

    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
             
    return UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir,
        CreateLight(i), CreateIndirectLight(i)
    );
           
}

#endif
// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

#ifndef PART_7_INCLUDE
#define PART_7_INCLUDE

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

float4 _Tint;
sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

float _Metallic;
float _Smoothness;


struct VertexData {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent: TANGENT;
    float2 uv : TEXCOORD0;
};


struct Interpolators {
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float4 tangent : TEXCOORD2;    
    float3 worldPos: TEXCOORD3;
    
    SHADOW_COORDS(4)
    
#ifdef VERTEXLIGHT_ON
    float3 vertexLightColor : TEXCOORD5;
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

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

Interpolators MyVertexProgram (VertexData v) {
    Interpolators i;
    i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
    i.pos = UnityObjectToClipPos(v.vertex);
    i.worldPos = mul(unity_ObjectToWorld, v.vertex);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
    
    TRANSFER_SHADOW(i);

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


	UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

float3 BoxProjection (float3 direction, float3 position,
	float4  cubemapPosition, float3 boxMin, float3 boxMax) {
#if UNITY_SPECCUBE_BOX_PROJECTION	
	UNITY_BRANCH
	if(cubemapPosition.w > 0) {
        float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
        float scalar = min(min(factors.x, factors.y), factors.z);
        direction = direction * scalar + (position - cubemapPosition);;
    }
#endif
    return direction;
}


UnityIndirect CreateIndirectLight (Interpolators i, float3 viewDir) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif
	
	#ifdef FORWARD_BASE_PASS
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
        float3 reflectionDir = reflect(-viewDir, i.normal);
        
        Unity_GlossyEnvironmentData envData;
		envData.roughness = 1 - _Smoothness;
		
		envData.reflUVW = BoxProjection(reflectionDir, i.worldPos,
		    unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float3 probe0 =  Unity_GlossyEnvironment(
            UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
        
        #if UNITY_SPECCUBE_BLENDING
			float interpolator = unity_SpecCube0_BoxMin.w;
			UNITY_BRANCH
			if (interpolator < 0.99999) {
				float3 probe1 = Unity_GlossyEnvironment(
					UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
					unity_SpecCube0_HDR, envData
				);
				indirectLight.specular = lerp(probe1, probe0, interpolator);
			}
			else {
				indirectLight.specular = probe0;
			}
		#else
			indirectLight.specular = probe0;
		#endif
	#endif
	
	return indirectLight;
}

void InitializeFragmentNormal(inout Interpolators i) {

    float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
    float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
    
    float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);
    
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
        CreateLight(i), CreateIndirectLight(i, viewDir)
    );
           
}

#endif
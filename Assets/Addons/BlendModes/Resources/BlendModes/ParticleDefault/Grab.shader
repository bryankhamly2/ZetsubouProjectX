﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BlendModes/ParticleDefault/Grab" 
{
	Properties 
	{
		_Color ("Tint Color", Color) = (1,1,1,1)
		_MainTex ("Particle Texture", 2D) = "white" {}
		
		[MaterialToggle] 
		_IsSelectiveBlendingActive("Selective Blending", Float) = 0
	}

	Category 
	{
		Tags 
		{ 
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True" 
			"RenderType" = "Transparent" 
		}
		
		AlphaTest Greater .01
		ColorMask RGB
		Cull Off 
		Lighting Off 
		ZWrite Off 
		Fog { Color (0,0,0,0) }
		Blend SrcAlpha OneMinusSrcAlpha
		
		SubShader 
		{
			GrabPass { }
			
			Pass 
			{
				CGPROGRAM
			
				#include "UnityCG.cginc"
				#include "../BlendModes.cginc"

				#pragma target 3.0				
				#pragma multi_compile BMDarken BMMultiply BMColorBurn BMLinearBurn BMDarkerColor BMLighten BMScreen BMColorDodge BMLinearDodge BMLighterColor BMOverlay BMSoftLight BMHardLight BMVividLight BMLinearLight BMPinLight BMHardMix BMDifference BMExclusion BMSubtract BMDivide BMHue BMSaturation BMColor BMLuminosity
				#pragma vertex ComputeVertex
				#pragma fragment ComputeFragment

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				sampler2D _GrabTexture;
				float _IsSelectiveBlendingActive;
				
				struct VertexInput 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct VertexOutput 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float4 screenPos : TEXCOORD1;
				};

				VertexOutput ComputeVertex(VertexInput vertexInput)
				{
					VertexOutput vertexOutput;
					
					vertexOutput.vertex = UnityObjectToClipPos(vertexInput.vertex);
					vertexOutput.screenPos = vertexOutput.vertex;
					vertexOutput.color = vertexInput.color;
					vertexOutput.texcoord = TRANSFORM_TEX(vertexInput.texcoord, _MainTex);
					
					return vertexOutput;
				}
				
				fixed4 ComputeFragment(VertexOutput vertexOutput) : SV_Target
				{
					fixed4 color = tex2D(_MainTex, vertexOutput.texcoord) * vertexOutput.color * _Color;
					
					float2 grabTexcoord = vertexOutput.screenPos.xy / vertexOutput.screenPos.w; 
					grabTexcoord.x = (grabTexcoord.x + 1.0) * .5;
					grabTexcoord.y = (grabTexcoord.y + 1.0) * .5; 
					#if UNITY_UV_STARTS_AT_TOP
					grabTexcoord.y = 1.0 - grabTexcoord.y;
					#endif
					
					fixed4 grabColor = tex2D(_GrabTexture, grabTexcoord); 
					
					#include "../BlendOps.cginc"
				}
				
				ENDCG 
			}
		}	
	}
	
	FallBack "Particles/Additive"
	CustomEditor "BMMaterialEditor"
}

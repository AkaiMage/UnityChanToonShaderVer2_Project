﻿//UCTS_ShadowCaster.cginc
// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// https://github.com/ACIIL/UnityChanToonShaderVer2_Project
// Source:
// https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;

			uniform half _DetachShadowClipping;
			uniform half _Clipping_Level;
			uniform half _Clipping_Level_Shadow;
			uniform half _Inverse_Clipping;
			uniform half _IsBaseMapAlphaAsClippingMask;






			struct VertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};



			struct VertexOutput {
				V2F_SHADOW_CASTER;
				float2 uv0 : TEXCOORD1;
			};






			VertexOutput vert (VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.pos = UnityObjectToClipPos( v.vertex );
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}






			float4 frag(VertexOutput i) : SV_TARGET {
#ifndef NotAlpha
				float2 Set_UV0			= i.uv0;
				float4 clippingMaskTex	= tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
				float4 mainTex			= tex2D(_MainTex, TRANSFORM_TEX(Set_UV0, _MainTex));
				float useMainTexAlpha	= lerp( clippingMaskTex.r, mainTex.a, _IsBaseMapAlphaAsClippingMask );
				float alpha				= lerp( useMainTexAlpha, (1.0 - useMainTexAlpha), _Inverse_Clipping );

				float clipTest			= (_DetachShadowClipping) ? _Clipping_Level_Shadow : _Clipping_Level;
				clipTest				= (( -clipTest * 1.01 + alpha));
				clip(clipTest);
				
				SHADOW_CASTER_FRAGMENT(i)
#else
				SHADOW_CASTER_FRAGMENT(i)
#endif
			}

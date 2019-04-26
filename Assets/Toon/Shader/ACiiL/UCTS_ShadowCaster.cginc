//UCTS_ShadowCaster.cginc
// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// https://github.com/ACIIL/UnityChanToonShaderVer2_Project
// Source:
// https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
#ifdef Dither
			sampler3D _DitherMaskLOD;
#endif

			uniform half _DetachShadowClipping;
			uniform half _Tweak_transparency;
			uniform half _Clipping_Level;
			uniform half _Clipping_Level_Shadow;
			uniform half _Inverse_Clipping;
			uniform half _IsBaseMapAlphaAsClippingMask;






			struct VertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};



			struct VertexOutput {
				// V2F_SHADOW_CASTER;
				float2 uv0 : TEXCOORD0;
				float4 worldPos	: TEXCOORD1;
			};

			//
			float hash13(float3 p3)
			{
				// p3 = frac(p3 * .1031);
				p3 = frac(p3 * 13);
				p3 += dot(p3, p3.yzx + 19.19);
				return frac((p3.x + p3.y) * p3.z);
			}






			VertexOutput vert (
				float4 vertex : POSITION,
				float2 uv : TEXCOORD0,
				out float4 outpos : SV_POSITION
			) {
				VertexOutput o	= (VertexOutput)0;
				o.uv0			= uv;
				outpos		= UnityObjectToClipPos( vertex );
				o.worldPos		= mul( unity_ObjectToWorld, vertex);
				// TRANSFER_SHADOW_CASTER(o)
				return o;
			}
			// VertexOutput vert (VertexInput v, out float4 outpos : SV_POSITION) {
			// 	VertexOutput o	= (VertexOutput)0;
			// 	o.uv0			= v.texcoord0;
			// 	outpos			= UnityObjectToClipPos( v.vertex );
			// 	TRANSFER_SHADOW_CASTER(o)
			// 	return o;
			// }






			float4 frag(VertexOutput i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_TARGET {
#ifndef NotAlpha
				float2 Set_UV0			= i.uv0;
				float4 clippingMaskTex	= tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
				float4 mainTex			= tex2D(_MainTex, TRANSFORM_TEX(Set_UV0, _MainTex));
				float useMainTexAlpha	= lerp( clippingMaskTex.r, mainTex.a, _IsBaseMapAlphaAsClippingMask );
				float alpha				= lerp( useMainTexAlpha, (1.0 - useMainTexAlpha), _Inverse_Clipping );

				float clipTest			= (_DetachShadowClipping) ? _Clipping_Level_Shadow : _Clipping_Level;
				clip( alpha - clipTest - 0.001);
				clipTest				= saturate(alpha + _Tweak_transparency);

	#ifdef Dither
				float dither			= tex3D(_DitherMaskLOD, float3(screenPos.xy * .25, clipTest * .99)).a;
				// float dither2			= hash13(i.worldPos.xyz * 50);
				// alpha					=  dither * (clipTest % 16);
				alpha					= dither;
				alpha					= ((alpha - 0.01)) ;
				clip(alpha );
	#else
				clip(clipTest);
	#endif
				SHADOW_CASTER_FRAGMENT(i)
#else
				SHADOW_CASTER_FRAGMENT(i)
#endif
			}

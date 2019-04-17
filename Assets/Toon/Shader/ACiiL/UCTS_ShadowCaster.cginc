//UCTS_ShadowCaster.cginc
// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// https://github.com/ACIIL/UnityChanToonShaderVer2_Project
// Source:
// https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;

			uniform half _Clipping_Level;
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
				float2 Set_UV0					= i.uv0;
				float4 _ClippingMask_var		= tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
				float4 _MainTex_var				= tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
				float Set_MainTexAlpha			= _MainTex_var.a;
				float _IsBaseMapAlphaAsClippingMask_var	= lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
				float _Inverse_Clipping_var		= lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
				float Set_Clipping				= saturate((_Inverse_Clipping_var + _Clipping_Level));
				clip(Set_Clipping - 0.5);
				SHADOW_CASTER_FRAGMENT(i)
			}

// UCTS_Outline.cginc
// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
//
			uniform float4 _Color;
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform float _Outline_Width;
			uniform float _Farthest_Distance;
			uniform float _Nearest_Distance;
			uniform sampler2D _Outline_Sampler; uniform float4 _Outline_Sampler_ST;
			uniform float4 _Outline_Color;
			uniform fixed _Is_BlendBaseColor;
			uniform fixed _Is_LightColor_Base;
			uniform float _Offset_Z;
			uniform sampler2D _OutlineTex; uniform float4 _OutlineTex_ST;
			uniform fixed _Is_OutlineTex;
			uniform float _OutlineshadowCastMin_black;
#ifdef _IS_OUTLINE_CLIPPING_YES
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform float _Clipping_Level;
			uniform fixed _Inverse_Clipping;
			uniform fixed _IsBaseMapAlphaAsClippingMask;
#endif
			//static const float3 grayscale_vector = float3(0, 0.3823529, 0.01845836);
			static const float softGI = .5;

			// ambient color
			fixed3 DecodeLightProbe_average( fixed3 N ){
				//return (1 - softGI) * ShadeSH9( float4(N, 1)) + (softGI) * ShadeSH9( float4(0,0,0,1));
				return ShadeSH9( float4(0,0,0,1));
			}

			// unity's modified version without the lambert tint darkening and with attenuation pass out.
			float3 softShade4PointLights_Atten (
				float4 lightPosX, float4 lightPosY, float4 lightPosZ,
				float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
				float4 lightAttenSq,
				float3 pos, float3 normal, inout float attenVert)
			{
				// to light vectors
				float4 toLightX = lightPosX - pos.x;
				float4 toLightY = lightPosY - pos.y;
				float4 toLightZ = lightPosZ - pos.z;
				// squared lengths
				float4 lengthSq = 0;
				lengthSq += toLightX * toLightX;
				lengthSq += toLightY * toLightY;
				lengthSq += toLightZ * toLightZ;
				// don't produce NaNs if some vertex position overlaps with the light
				lengthSq = max(lengthSq, 0.000001);

				/*// NdotL.
 				float4 ndotl = 0;
				ndotl += toLightX * normal.x;
				ndotl += toLightY * normal.y;
				ndotl += toLightZ * normal.z; 
				// correct NdotL
				float4 corr = rsqrt(lengthSq);
				ndotl = max (float4(0,0,0,0), ndotl * corr);*/
				// attenuation
				float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
				attenVert = atten;
				float4 diff = atten;
				// final color
				float3 col = 0;
				col += lightColor0 * diff.x;
				col += lightColor1 * diff.y;
				col += lightColor2 * diff.z;
				col += lightColor3 * diff.w;
				return col;
			}

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv0 : TEXCOORD0;
				float3 normalDir : TEXCOORD2;
				LIGHTING_COORDS(3,4)
				UNITY_FOG_COORDS(5)
				half3 vertexLighting : COLOR0;
				half attenVert : COLOR1;
			};



//// vert			
			VertexOutput vert (VertexInput v) {
				VertexOutput o				= (VertexOutput)0;
				o.uv0						= v.texcoord0;
				o.normalDir					= UnityObjectToWorldNormal( v.normal);
				o.posWorld					= mul( unity_ObjectToWorld, v.vertex);
				float4 objPos				= mul ( unity_ObjectToWorld, float4(0,0,0,1) );
				float3 lightColor			= _LightColor0.rgb;
				float2 Set_UV0				= o.uv0;
				float4 _Outline_Sampler_var	= tex2Dlod( _Outline_Sampler, float4( TRANSFORM_TEX( Set_UV0, _Outline_Sampler), 0.0, 0));
				float Set_Outline_Width		= 
					(
						_Outline_Width * 0.001 
						* 
							smoothstep( 
								_Farthest_Distance, _Nearest_Distance, distance( o.posWorld.rgb, _WorldSpaceCameraPos) 
							) 
						* _Outline_Sampler_var.rgb
					).r;
				float3 viewDirection		= ( _WorldSpaceCameraPos.xyz - o.pos.xyz);
				float4 viewDirectionVP		= mul( UNITY_MATRIX_VP, float4( viewDirection.xyz, 1));
#if defined(UNITY_REVERSED_Z)
				_Offset_Z = _Offset_Z * -0.01;
#else
				_Offset_Z = _Offset_Z * 0.01;
#endif
#ifdef _OUTLINE_NML
				o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + v.normal * Set_Outline_Width, 1) );
#elif _OUTLINE_POS
				Set_Outline_Width		= Set_Outline_Width * 2;
				o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + normalize(v.vertex) * Set_Outline_Width, 1) );
#endif
				UNITY_TRANSFER_FOG( o, o.pos);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				o.pos.z					= o.pos.z + _Offset_Z * viewDirectionVP.z;
#ifdef VERTEXLIGHT_ON
				o.vertexLighting		= softShade4PointLights_Atten(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0
					, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3]
					, unity_4LightAtten0, o.posWorld, o.normalDir, o.attenVert);
#endif					
				return o;
			}





//// Redefine UNITY_LIGHT_ATTENUATION without shadow multiply from AutoLight.cginc
#ifdef POINT
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif

#ifdef SPOT
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord4 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
	fixed destName = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
#endif

#ifdef DIRECTIONAL
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) fixed destName = 1;
// #define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) fixed destName = UNITY_SHADOW_ATTENUATION(input, worldPos);
#endif

#ifdef POINT_COOKIE
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL * texCUBE(_LightTexture0, lightCoord).w;
#endif

#ifdef DIRECTIONAL_COOKIE
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord2 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xy; \
	fixed destName = tex2D(_LightTexture0, lightCoord).w;
#endif






//// frag			
			float4 frag(VertexOutput i) : SV_Target{
				UNITY_LIGHT_ATTENUATION_NOSHADOW(lightAtten, i, i.posWorld.xyz);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, i.posWorld.xyz);
				float nLightAtten		= 1 - lightAtten;
				float nShadowAtten		= 1 - shadowAtten;
				float attenRampB		= ( (-(nLightAtten * nLightAtten) + 1));
				float shadowAttenB		= ( (-(nShadowAtten * nShadowAtten) + 1));
				float attenRamp			= attenRampB;



#ifdef _IS_PASS_FWDBASE
				float3 lightColor		= _LightColor0.rgb;
				float shadowBlackness	= max(_OutlineshadowCastMin_black, shadowAttenB);
				float3 ambientLight		= DecodeLightProbe_average( i.normalDir);
				lightColor				= lightColor * shadowBlackness * attenRamp;
				lightColor				= (lightColor + ambientLight) + (i.vertexLighting * i.attenVert);
#elif _IS_PASS_FWDDELTA
				float shadRings			= shadowAttenB;
				float shadowBlackness	= max(_OutlineshadowCastMin_black, shadowAttenB);
				float3 lightColor		= _LightColor0.rgb;
				float shadBlackScale	= lerp(1, shadowBlackness, attenRamp);
				lightColor				= lightColor * shadBlackScale * attenRamp;
#endif



				float2 Set_UV0					= i.uv0;
				float4 _MainTex_var				= tex2D(_MainTex, TRANSFORM_TEX( Set_UV0, _MainTex));
				float3 _BaseColorMap_var		= ( _Color.rgb * _MainTex_var.rgb );
				float3 Set_BaseColor			= lerp( _BaseColorMap_var * lightColor, (_BaseColorMap_var * lightColor.rgb), _Is_LightColor_Base );			
				float3 _Is_BlendBaseColor_var	= lerp( (_Outline_Color.rgb * lightColor.rgb), (_Outline_Color.rgb * Set_BaseColor), _Is_BlendBaseColor );
				float3 _OutlineTex_var			= tex2D( _OutlineTex, TRANSFORM_TEX( Set_UV0, _OutlineTex));
#ifdef _IS_OUTLINE_CLIPPING_NO
				float3 Set_Outline_Color		= lerp( _Is_BlendBaseColor_var, _OutlineTex_var.rgb * _Is_BlendBaseColor_var, _Is_OutlineTex );
				UNITY_APPLY_FOG( i.fogCoord, Set_Outline_Color);
				return fixed4(Set_Outline_Color, 1);
#elif _IS_OUTLINE_CLIPPING_YES
				float4 _ClippingMask_var				= tex2D( _ClippingMask, TRANSFORM_TEX( Set_UV0, _ClippingMask));
				float Set_MainTexAlpha					= _MainTex_var.a;
				float _IsBaseMapAlphaAsClippingMask_var	= lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
				float _Inverse_Clipping_var				= lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
				float Set_Clipping						= saturate( (_Inverse_Clipping_var + _Clipping_Level));
				clip(Set_Clipping - 0.5);
				float4 Set_Outline_Color				=
					lerp( 
						float4( _Is_BlendBaseColor_var, Set_Clipping)
						, float4( (_OutlineTex_var.rgb * _Is_BlendBaseColor_var), Set_Clipping)
						, _Is_OutlineTex 
					);
				UNITY_APPLY_FOG( i.fogCoord, Set_Outline_Color);
				return Set_Outline_Color;
#endif
			}
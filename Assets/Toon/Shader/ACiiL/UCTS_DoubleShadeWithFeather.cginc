// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// Coding goal is both as a personal study to self improve shader writting and make UTS redundant and compatible 
// in all typical vrchat map scene light situations.
// I did manual conversion to human-readable from node graph generation in some parts.
//
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform fixed _Is_LightColor_Base;
			uniform sampler2D _1st_ShadeMap; uniform float4 _1st_ShadeMap_ST;
			uniform float4 _1st_ShadeColor;
			uniform fixed _Is_LightColor_1st_Shade;
			uniform sampler2D _2nd_ShadeMap; uniform float4 _2nd_ShadeMap_ST;
			uniform float4 _2nd_ShadeColor;
			uniform fixed _Is_LightColor_2nd_Shade;
			uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
			uniform fixed _Is_NormalMapToBase;
			uniform fixed _Set_SystemShadowsToBase;
			uniform float _Tweak_SystemShadowsLevel;
			uniform float _BaseColor_Step;
			uniform float _BaseShade_Feather;
			uniform sampler2D _Set_1st_ShadePosition; uniform float4 _Set_1st_ShadePosition_ST;
			uniform float _ShadeColor_Step;
			uniform float _1st2nd_Shades_Feather;
			uniform sampler2D _Set_2nd_ShadePosition; uniform float4 _Set_2nd_ShadePosition_ST;
			uniform float4 _HighColor;
			uniform sampler2D _HighColor_Tex; uniform float4 _HighColor_Tex_ST;
			uniform fixed _Is_LightColor_HighColor;
			uniform fixed _Is_NormalMapToHighColor;
			uniform float _HighColor_Power;
			uniform fixed _Is_SpecularToHighColor;
			uniform fixed _Is_BlendAddToHiColor;
			uniform fixed _Is_UseTweakHighColorOnShadow;
			uniform float _TweakHighColorOnShadow;
			uniform sampler2D _Set_HighColorMask; uniform float4 _Set_HighColorMask_ST;
			uniform float _Tweak_HighColorMaskLevel;
			uniform fixed _RimLight;
			uniform float4 _RimLightColor;
			uniform fixed _Is_LightColor_RimLight;
			uniform fixed _Is_NormalMapToRimLight;
			uniform float _RimLight_Power;
			uniform float _RimLight_InsideMask;
			uniform fixed _RimLight_FeatherOff;
			uniform fixed _LightDirection_MaskOn;
			uniform float _Tweak_LightDirection_MaskLevel;
			uniform fixed _Add_Antipodean_RimLight;
			uniform float4 _Ap_RimLightColor;
			uniform fixed _Is_LightColor_Ap_RimLight;
			uniform float _Ap_RimLight_Power;
			uniform fixed _Ap_RimLight_FeatherOff;
			uniform sampler2D _Set_RimLightMask; uniform float4 _Set_RimLightMask_ST;
			uniform float _Tweak_RimLightMaskLevel;
			uniform fixed _MatCap;
			uniform sampler2D _MatCap_Sampler; uniform float4 _MatCap_Sampler_ST;
			uniform float4 _MatCapColor;
			uniform fixed _Is_LightColor_MatCap;
			uniform fixed _Is_BlendAddToMatCap;
			uniform float _Tweak_MatCapUV;
			uniform float _Rotate_MatCapUV;
			uniform fixed _Is_NormalMapForMatCap;
			uniform sampler2D _NormalMapForMatCap; uniform float4 _NormalMapForMatCap_ST;
			uniform float _Rotate_NormalMapForMatCapUV;
			uniform fixed _Is_UseTweakMatCapOnShadow;
			uniform float _TweakMatCapOnShadow;
			uniform sampler2D _Set_MatcapMask; uniform float4 _Set_MatcapMask_ST;
			uniform float _Tweak_MatcapMaskLevel;
			uniform sampler2D _Emissive_Tex; uniform float4 _Emissive_Tex_ST;
			uniform float4 _Emissive_Color;
			uniform float _shadowCastMin_black;

			uniform float _testMix;
			uniform float _shaSatRatio;



#ifdef _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform float _Clipping_Level;
			uniform fixed _Inverse_Clipping;
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform fixed _IsBaseMapAlphaAsClippingMask;
			uniform float _Clipping_Level;
			uniform fixed _Inverse_Clipping;
			uniform float _Tweak_transparency;
#elif _IS_CLIPPING_OFF
//DoubleShadeWithFeather
#endif
			static const float3 defaultLightDirection = float3(0, 1, 0);
			static const float softGI = .98;



			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord0 : TEXCOORD0;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 bitangentDir : TEXCOORD4;
				float3 GIdirection : COLOR0;
				UNITY_SHADOW_COORDS(5)
				// LIGHTING_COORDS(5,6)
				UNITY_FOG_COORDS(7)
				half3 vertexLighting : COLOR1;
				half attenVert : COLOR2;
				float4 center : COLOR3;
			};



			// raw ambient color by direction
			fixed3 DecodeLightProbe( fixed3 N ){
				return ShadeSH9( float4(N,1));
			}
			
			// ambient color
			fixed3 DecodeLightProbe_average( fixed3 N ){
				//return (1 - softGI) * ShadeSH9( float4(N, 1)) + (softGI) * ShadeSH9( float4(0,0,0,1));
				return ShadeSH9( float4(0,0,0,1));
			}

			// Merlin's post. Shader community
			bool IsInMirror()
			{
				return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
			}

			// Neitri's Help
			float3 GIsonarDirection(){
				// float3 GIsonar_dir_vec = (unity_SHAr.xyz*unity_SHAr.w + unity_SHAg.xyz*unity_SHAg.w + unity_SHAb.xyz*unity_SHAb.w);
				float3 GIsonar_dir_vec = (unity_SHAr.xyz*unity_SHAr.w + unity_SHAg.xyz*unity_SHAg.w + unity_SHAb.xyz*unity_SHAb.w);
				UNITY_FLATTEN
				if ( length( GIsonar_dir_vec) > 0){
					GIsonar_dir_vec = normalize(GIsonar_dir_vec);
				} else {
					GIsonar_dir_vec = float3(0,0,0);
				}
				return GIsonar_dir_vec;
			}
			
			// unity's modified version without the lambert tint darkening and with attenuation pass out.
			float3 softShade4PointLights_Atten (
				float4 lightPosX, float4 lightPosY, float4 lightPosZ,
				float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
				float4 lightAttenSq,
				float3 pos, float3 normal, inout float attenVert){
					

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

			/*
			 // this source should be easy to find...
			// discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3
			float3 random3(float3 c) {
				float j = 4096.0*sin(dot(c,float3(17.0, 59.4, 15.0)));
				float3 r;
				r.z = frac(512.0*j);
				j *= .125;
				r.x = frac(512.0*j);
				j *= .125;
				r.y = frac(512.0*j);
				return r-0.5;
			}
			
			//
			const float F3 =  0.3333333;
			const float G3 =  0.1666667;
			//
			float snoise(float3 p) {

				float3 s = floor(p + dot(p, float3(F3,F3,F3)));
				float3 x = p - s + dot(s, float3(G3,G3,G3));
				
				float3 e = step(float3(0.0,0.0,0.0), x - x.yzx);
				float3 i1 = e*(1.0 - e.zxy);
				float3 i2 = 1.0 - e.zxy*(1.0 - e);
				
				float3 x1 = x - i1 + G3;
				float3 x2 = x - i2 + 2.0*G3;
				float3 x3 = x - 1.0 + 3.0*G3;
				
				float4 w, d;
				
				w.x = dot(x, x);
				w.y = dot(x1, x1);
				w.z = dot(x2, x2);
				w.w = dot(x3, x3);
				
				w = max(0.6 - w, 0.0);
				
				d.x = dot(random3(s), x);
				d.y = dot(random3(s + i1), x1);
				d.z = dot(random3(s + i2), x2);
				d.w = dot(random3(s + 1.0), x3);
				
				w *= w;
				w *= w;
				d *= w;
				
				return dot(d, float4(52.0,52.0,52.0,52.0));
			} */

			//
			float3 StereoWorldViewPos( float3 worldPos ) {
#if UNITY_SINGLE_PASS_STEREO
				float3 cameraPos	= 
					float3((unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5); 
#else
				float3 cameraPos	= _WorldSpaceCameraPos;
#endif
				return cameraPos;
			}

			//
			float3 StereoWorldViewDir( float3 worldPos ) {
				float3 cameraPos	= StereoWorldViewPos(worldPos);
				float3 worldViewDir	= normalize((cameraPos - worldPos));
				return worldViewDir;
			}

			//
			float3 HSVToRGB( float3 c )
			{
				float4 K	= float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p	= abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}

			//
			float3 RGBToHSV(float3 c)
			{
				float4 K	= float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p	= lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q	= lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d		= q.x - min( q.w, q.y );
				float e		= 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}












//// vert			
			VertexOutput vert (VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv0					= v.texcoord0;
				o.normalDir				= UnityObjectToWorldNormal( v.normal);
				o.tangentDir			= normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0)).xyz );
				o.bitangentDir			= normalize( cross( o.normalDir, o.tangentDir) * v.tangent.w);
				o.posWorld				= mul( unity_ObjectToWorld, v.vertex);
				o.pos					= UnityObjectToClipPos( v.vertex );
				o.center				= mul( unity_ObjectToWorld, float4(0,0,0,1));
				UNITY_TRANSFER_FOG(o, o.pos);
				UNITY_TRANSFER_SHADOW(o, o.uv0);
				// TRANSFER_VERTEX_TO_FRAGMENT(o);
#ifdef VERTEXLIGHT_ON
				o.vertexLighting		= softShade4PointLights_Atten(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0
					, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3]
					, unity_4LightAtten0, o.posWorld, o.normalDir, o.attenVert);
#endif					
#ifdef UNITY_PASS_FORWARDBASE
				o.GIdirection			= GIsonarDirection();
#endif
				return o;
			}






//// frag
			float4 frag(VertexOutput i) : SV_TARGET {
				i.normalDir					= normalize( i.normalDir);
				float3 worldviewPos			= StereoWorldViewPos(i.posWorld.xyz);
				float3 viewDirection		= normalize(worldviewPos - i.posWorld.xyz);


				// normal map
				float2 Set_UV0				= i.uv0;
				float3 _NormalMap_var 		= UnpackNormal( tex2D( _NormalMap, TRANSFORM_TEX( Set_UV0, _NormalMap)));
				float3 normalLocal			= _NormalMap_var.rgb;
				float3x3 tangentTransform	= float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
				float3 normalDirection		= normalize( mul( normalLocal, tangentTransform )); // Perturbed normals


				// towards cam dot
				float _FaceFwdDot			= dot( i.normalDir, viewDirection);



//// albedo texure
				// base albedo
				float4 _MainTex_var			= tex2D( _MainTex, TRANSFORM_TEX( Set_UV0, _MainTex));

				// clip & alpha handling. Here now so clip() may interrupt flow.
#ifdef _IS_CLIPPING_MODE
				//DoubleShadeWithFeather_Clipping
				float4 _ClippingMask_var	= tex2D(_ClippingMask, TRANSFORM_TEX( Set_UV0, _ClippingMask));
				float Set_Clipping			= saturate( (lerp( _ClippingMask_var.r, (1.0 - _ClippingMask_var.r), _Inverse_Clipping ) + _Clipping_Level));
				clip(Set_Clipping - 0.5);

#elif _IS_CLIPPING_TRANSMODE
				//DoubleShadeWithFeather_TransClipping
				float4 _ClippingMask_var				= tex2D( _ClippingMask, TRANSFORM_TEX(Set_UV0, _ClippingMask));
				float Set_MainTexAlpha					= _MainTex_var.a;
				float _IsBaseMapAlphaAsClippingMask_var	= lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
				float _Inverse_Clipping_var				= lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
				float Set_Clipping						= saturate( (_Inverse_Clipping_var + _Clipping_Level));
				clip(Set_Clipping - 0.5);

#elif _IS_CLIPPING_OFF
				//DoubleShadeWithFeather
#endif

				// albedo shade 1 & 2
				float4 _1st_ShadeMap_var	= tex2D( _1st_ShadeMap, TRANSFORM_TEX( Set_UV0, _1st_ShadeMap));
				float4 _2nd_ShadeMap_var	= tex2D( _2nd_ShadeMap, TRANSFORM_TEX( Set_UV0, _2nd_ShadeMap));






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






//// Light attenuation and direction:

// testing shadow sample offsets
/*
				float3 sOffset			= (i.posWorld.xyz - i.center) * sin(_Time.y * UNITY_PI ) ;
// return float4(sOffset.xyz,1);
				float yOffset			= sin(_Time.y * UNITY_PI ) * float3(0,1,0);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, sOffset + i.center);
*/

				UNITY_LIGHT_ATTENUATION_NOSHADOW(lightAtten, i, i.posWorld.xyz);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, i.posWorld.xyz);
				shadowAtten				= max(shadowAtten, i.attenVert);
				// float attenRampB		= lightAtten;
				// float shadowAttenB			= shadowAtten;
				float nLightAtten		= 1 - lightAtten;
				float nShadowAtten		= 1 - shadowAtten;
				float attenRampB		= ( (-(nLightAtten * nLightAtten) + 1));
				float shadowAttenB		= ( (-(nShadowAtten * nShadowAtten) + 1));
				float attenRamp			= attenRampB;



#ifdef UNITY_PASS_FORWARDBASE
				float3 cameraLightDirection	= normalize( UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
				float3 lightDirection		= normalize( _WorldSpaceLightPos0.xyz + (i.GIdirection) * .01 + cameraLightDirection *.0001);
#elif UNITY_PASS_FORWARDADD
				float3 lightDirection	= 
					normalize( 
						lerp( 
							_WorldSpaceLightPos0.xyz
							, _WorldSpaceLightPos0.xyz - i.posWorld.xyz
							, _WorldSpaceLightPos0.w)
					);
#endif






//// Mix light input colors
				//const half shadowRings			= .15;
#ifdef UNITY_PASS_FORWARDBASE
				//float shadRings		= (ceil( shadowAttenB / shadowRings) * (shadowRings));
				float shadRings			= shadowAttenB;
				float3 lightIndirect	= DecodeLightProbe_average( i.normalDir);
				float3 lightDirect		= _LightColor0.rgb;
				float shadowBlackness	= max(_shadowCastMin_black, shadRings);
				float shaBlackMix		= shadowBlackness * attenRamp;
				lightDirect				= lightDirect * shaBlackMix;

				// fuzzy logic for classifying direct light < indirect light
				float lightDirGray		=  dot(_LightColor0.rgb,	1) / 3;
				float lightInDirGray	=  dot(lightIndirect.rgb,	1) / 3;
				float colorIntSignal	= (smoothstep(0, lightDirGray, lightInDirGray));
				// float3 colorIntSignal	= (smoothstep(0, _LightColor0.rgb, lightIndirect));

				float3 lightColorFinal	= (lightDirect + lightIndirect) + (i.vertexLighting * i.attenVert);

#elif UNITY_PASS_FORWARDADD
				//float shadRings		= ceil( shadowAttenB / shadowRings) * shadowRings;
				float shadRings			= shadowAttenB;
				float3 lightDirect		= _LightColor0.rgb;
				float shadowBlackness	= max(_shadowCastMin_black, shadRings);
				float shadBlackScale	= lerp(1, shadowBlackness, attenRamp);
				shadowBlackness			= shadBlackScale;
				float shaBlackMix		= shadowBlackness * attenRamp;
				float3 lightColorFinal	= lightDirect * shaBlackMix;
				float colorIntSignal	= 0;
				// float3 colorIntSignal	= 0;

#endif
				float3 Set_LightColor	= lightColorFinal;
				
				// fight how the raw light of direct + indirect overbrights
				// Ill change this counter many times more than now. Which is to many already!
				Set_LightColor.x	= (Set_LightColor.x > 1) ? sqrt(Set_LightColor.x) : Set_LightColor.x;
				Set_LightColor.y	= (Set_LightColor.y > 1) ? sqrt(Set_LightColor.y) : Set_LightColor.y;
				Set_LightColor.z	= (Set_LightColor.z > 1) ? sqrt(Set_LightColor.z) : Set_LightColor.z;



				// float3 _fc_test_max		= max(Set_LightColor.r, max(Set_LightColor.g, Set_LightColor.b));
				// float3 _fc_test_min		= min(Set_LightColor.r, min(Set_LightColor.g, Set_LightColor.b));
				// float3 _fc_test_mix		= finalColor * pow(finalColor, 1-LinearRgbToLuminance(Set_LightColor / _fc_test_max));
				// float3 _fc_test_mix		=  pow(Set_LightColor, 0.5 );
				// float3 _fc_test_mix		=  sqrt(Set_LightColor);

				// float3 _fc_test_mix		= GammaToLinearSpace(finalColor);

				// Set_LightColor			= lerp(Set_LightColor, _fc_test_mix, _testMix);
				// _FinalColor_var			= lerp(_FinalColor_var, _FinalColor_var * _fc_test_mix, _testMix);




//// albedo textures
				// is using world color
				float3 baseColor_isLC		= lerp(attenRamp, Set_LightColor, _Is_LightColor_Base);
				float3 shadeColor1_isLC		= lerp(attenRamp, Set_LightColor, _Is_LightColor_1st_Shade);
				float3 shadeColor2_isLC		= lerp(attenRamp, Set_LightColor, _Is_LightColor_2nd_Shade);

				// get albedo samples
				float3 albeto_col_1			= _MainTex_var.rgb;
				float3 albeto_col_2			= _1st_ShadeMap_var.rgb;
				float3 albeto_col_3			= _2nd_ShadeMap_var.rgb;

				// get ramp shade color mix
				float3 ramp_world_col_1		= _Color.rgb * baseColor_isLC;
				float3 ramp_world_col_2		= _1st_ShadeColor.rgb * shadeColor1_isLC;
				float3 ramp_world_col_3		= _2nd_ShadeColor.rgb * shadeColor2_isLC;






//// Lambert
				float3 lambert_isNormalMap	= lerp( i.normalDir, normalDirection, _Is_NormalMapToBase);
				float _HalfLambert_var		= 0.5 + 0.5 * dot( lambert_isNormalMap, lightDirection);
				
//// Lambert & shadow attenuation mix
				float4 _Set_1st_ShadePosition_var	= tex2D( _Set_1st_ShadePosition, TRANSFORM_TEX( Set_UV0, _Set_1st_ShadePosition));
				float4 _Set_2nd_ShadePosition_var	= tex2D( _Set_2nd_ShadePosition, TRANSFORM_TEX( Set_UV0, _Set_2nd_ShadePosition));



				float shade_ramp_n1		= 
					saturate(
						1.0 
						+ 
							(
								(
									lerp(
										_HalfLambert_var
										//, ( _HalfLambert_var * saturate( ((shadowAtten * 0.5) + 0.5 + _Tweak_SystemShadowsLevel)))
										// , ( _HalfLambert_var * saturate(smoothstep(0, 1, shadowAtten + _Tweak_SystemShadowsLevel) ) )
										// Create a continuous function to set shadow strength independent cast zones upon the toon ramp.
										, ( _HalfLambert_var * smoothstep(_LightShadowData.x + 0.001, 1 + _Tweak_SystemShadowsLevel, shadowAtten))
										, _Set_SystemShadowsToBase 
									)
									- ( _BaseColor_Step - _BaseShade_Feather )
								)
								* ( (1.0 - _Set_1st_ShadePosition_var.rgb).r - 1.0 ) 
							) 
						/ (_BaseShade_Feather)						
					);



//// shadow1 to shadow2 mix
				float shade_ramp_n2			=
						saturate(
							1.0 
							+ ( _HalfLambert_var - (_ShadeColor_Step - _1st2nd_Shades_Feather) )
							* ( (1.0 - _Set_2nd_ShadePosition_var.rgb).r - 1.0 ) 
							/ ( _1st2nd_Shades_Feather )
						);



//// The 3 Shade mixer. Lerp: (base color, (shade 1, shade 2))
				// albedo mix
				float3 albedo_layer_23_mix		= lerp(albeto_col_2, albeto_col_3, shade_ramp_n2);
				float3 albedo_layer_1_23_mix	= lerp(albeto_col_1, albedo_layer_23_mix, shade_ramp_n1);

				// saturate albedo mix by shadows
				// saturate logic
				float colTest				= 1 - ((saturate( ( (shadowBlackness) + ( colorIntSignal)))));
				float colTest2				= colTest;
				float1 colSateOffset		= 1 + _shaSatRatio * colTest2;
				// saturate albedo
				float3 albedoSource			= albedo_layer_1_23_mix;
				float3 albedo_HSV			= RGBToHSV( albedoSource);
				float3 albedo_saturated		= HSVToRGB( float3(albedo_HSV.x, ( albedo_HSV.y * colSateOffset ), albedo_HSV.z));

				// shades mix
				float3 shade_layer_23_mix	= lerp(ramp_world_col_2, ramp_world_col_3, shade_ramp_n2);
				float3 shade_layer_1_23_mix	= lerp(ramp_world_col_1, shade_layer_23_mix, shade_ramp_n1);
				// combine albedo with shades.
				float3 _FinalColor_var		= albedo_saturated * shade_layer_1_23_mix;






//// High Color. Specular.
				float4 _Set_HighColorMask_var	= tex2D( _Set_HighColorMask, TRANSFORM_TEX( Set_UV0, _Set_HighColorMask));
				float3 halfDirection			= normalize( viewDirection + lightDirection);
				float3 highColorNormalType		= lerp( i.normalDir, normalDirection, _Is_NormalMapToHighColor );
				float3 _highColor_lambart		= 0.5 + 0.5 * dot(halfDirection, highColorNormalType);
				float _Specular_var				= _highColor_lambart;
				float _TweakHighColorMask_var	= 
					saturate( _Set_HighColorMask_var.g + _Tweak_HighColorMaskLevel)
					* lerp(
						( 1.0 - step(_Specular_var, ( 1.0 - _HighColor_Power)) )
						, pow( _Specular_var, exp2( lerp( 11, 1, _HighColor_Power)) )
						, _Is_SpecularToHighColor 
					);
				float4 _HighColor_Tex_var	= tex2D( _HighColor_Tex, TRANSFORM_TEX( Set_UV0, _HighColor_Tex));
				float3 highColor_isLC		= lerp( attenRamp, Set_LightColor, _Is_LightColor_HighColor);
				float3 highColor_mix		= _HighColor_Tex_var.rgb * _HighColor.rgb;
				float3 _HighColor_var		= ( highColor_isLC * highColor_mix * _TweakHighColorMask_var);






//// Rim Color
				float3 rimLightNormalType		= lerp( i.normalDir, normalDirection, _Is_NormalMapToRimLight);
				float _RimArea_var_n			= dot( rimLightNormalType, viewDirection); // 1=norm with cam, -1=not
				float _RimArea_var				= (1.0 - _RimArea_var_n);	
				_RimArea_var					= lerp(0,_RimArea_var, saturate(_RimArea_var_n + 1));


				float _VertHalfLambert_var		= 0.5 + 0.5 * dot( i.normalDir, lightDirection);
				float _RimLightPower_var		= pow(_RimArea_var, exp2( lerp( 3, 0, _RimLight_Power )));
				float _ApRimLightPower_var		= pow(_RimArea_var, exp2( lerp( 3, 0, _Ap_RimLight_Power )));				
				float3 _rimLight_isLC			= lerp(attenRamp, Set_LightColor, _Is_LightColor_RimLight);
				float3 _rimLight_color			= _RimLightColor.rgb * _rimLight_isLC;
				// build the generic rim ramp mask.
				float _Rimlight_Mask_var		= 
					saturate(
						lerp(
							((_RimLightPower_var - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask)) // soft
							, step( _RimLight_InsideMask, _RimLightPower_var) // hard
							, _RimLight_FeatherOff 
						)
					);
				float rimlightMaskToward		= saturate( _Rimlight_Mask_var - ((1.0 - _VertHalfLambert_var) + _Tweak_LightDirection_MaskLevel));
				float rimLightMaskAway			= (_VertHalfLambert_var) + _Tweak_LightDirection_MaskLevel ;

				// builds a directional rim mask with colors. 0= generic rim, 1= generic mix with light on surface direction.
				float rimLight_type				= lerp(_Rimlight_Mask_var, rimlightMaskToward, _LightDirection_MaskOn);
				float3 rimLight_WithMix			= _rimLight_color * rimLight_type;
				float3 _Ap_rimLight_isLC		= lerp( attenRamp, Set_LightColor, _Is_LightColor_Ap_RimLight);
				float3 _Ap_rimLignt_color		= _Ap_RimLightColor.rgb * _Ap_rimLight_isLC;

				// builds anti rimlight color by generic mask AND light dir mask.
				// strangely. Anti rimlight defaults to directional.
				float _Ap_Rimlight_Mask_var		= 
					saturate(
						lerp(
							((_ApRimLightPower_var - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask))
							, step( _RimLight_InsideMask, _ApRimLightPower_var)
							, _Ap_RimLight_FeatherOff
						)
					);
				float _Ap_Rimlight_Mask_Mix		= saturate(_Ap_Rimlight_Mask_var - rimLightMaskAway);
				float4 _Set_RimLightMask_var	= tex2D( _Set_RimLightMask, TRANSFORM_TEX( Set_UV0, _Set_RimLightMask));
				float3 _Ap_rimLight_mix			= _Ap_rimLignt_color * _Ap_Rimlight_Mask_Mix;
				float3 Set_RimLight_final		= 
					saturate( _Set_RimLightMask_var.g + _Tweak_RimLightMaskLevel)
					* lerp( 
						rimLight_WithMix
						, ( rimLight_WithMix + _Ap_rimLight_mix)
						, _Add_Antipodean_RimLight 
					);






//// Matcap				
				float _Rot_MatCapUV_var_ang			= ( _Rotate_MatCapUV * 3.141592654);
				float _Rot_MatCapUV_var_spd			= 1.0;
				float _Rot_MatCapUV_var_cos			= cos( _Rot_MatCapUV_var_spd * _Rot_MatCapUV_var_ang);
				float _Rot_MatCapUV_var_sin			= sin( _Rot_MatCapUV_var_spd * _Rot_MatCapUV_var_ang);
				float2 _Rot_MatCapUV_var_piv		= float2(0.5,0.5);
				float _Rot_MatCapNmUV_var_ang		= ( _Rotate_NormalMapForMatCapUV * 3.141592654);
				float _Rot_MatCapNmUV_var_spd		= 1.0;
				float _Rot_MatCapNmUV_var_cos		= cos( _Rot_MatCapNmUV_var_spd * _Rot_MatCapNmUV_var_ang);
				float _Rot_MatCapNmUV_var_sin		= sin( _Rot_MatCapNmUV_var_spd * _Rot_MatCapNmUV_var_ang);
				float2 _Rot_MatCapNmUV_var_piv		= float2(0.5,0.5);
				float2 _Rot_MatCapNmUV_var			= ( mul( Set_UV0 - _Rot_MatCapNmUV_var_piv, float2x2( _Rot_MatCapNmUV_var_cos, -_Rot_MatCapNmUV_var_sin, _Rot_MatCapNmUV_var_sin, _Rot_MatCapNmUV_var_cos)) + _Rot_MatCapNmUV_var_piv);
				float3 _NormalMapForMatCap_var		= UnpackNormal( tex2D( _NormalMapForMatCap, TRANSFORM_TEX( _Rot_MatCapNmUV_var, _NormalMapForMatCap)));				



				//v.2.0.5: MatCap with camera skew correction.  @kanihira
				float3 viewNormal					= (mul(UNITY_MATRIX_V, float4(lerp( i.normalDir, mul( _NormalMapForMatCap_var.rgb, tangentTransform ).rgb, _Is_NormalMapForMatCap ), 0))).xyz;
				float3 NormalBlend_MatcapUV_Detail	= viewNormal.xyz * float3(-1,-1,1);
				float3 NormalBlend_MatcapUV_Base	= (mul( UNITY_MATRIX_V, float4(viewDirection,0) ).rgb * float3(-1,-1,1)) + float3(0,0,1);
				float3 noSknewViewNormal			= NormalBlend_MatcapUV_Base * dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail) / NormalBlend_MatcapUV_Base.z - NormalBlend_MatcapUV_Detail;
				float2 _ViewNormalAsMatCapUV		= ((noSknewViewNormal).xy * 0.5) + 0.5;
				float2 _Rot_MatCapUV_var			= 
					(
						mul(
							(
								((_ViewNormalAsMatCapUV - (_Tweak_MatCapUV)) ) / (1.0 - 2 * _Tweak_MatCapUV)
							) - _Rot_MatCapUV_var_piv
							, float2x2( _Rot_MatCapUV_var_cos, -_Rot_MatCapUV_var_sin, _Rot_MatCapUV_var_sin, _Rot_MatCapUV_var_cos)
						) 
						+ _Rot_MatCapUV_var_piv
					);



				float4 _MatCap_Sampler_var			= tex2D( _MatCap_Sampler, TRANSFORM_TEX( _Rot_MatCapUV_var, _MatCap_Sampler));
				float3 _matcap_isLC					= lerp( attenRamp, Set_LightColor, _Is_LightColor_MatCap);
				float3 _Is_LightColor_MatCap_var	= _matcap_isLC * _MatCap_Sampler_var.rgb * _MatCapColor.rgb;
				float3 _MatCap_Color 				= 
					lerp( 
						_Is_LightColor_MatCap_var
						, (_Is_LightColor_MatCap_var * ( (1.0 - shade_ramp_n1) + (shade_ramp_n1 * _TweakMatCapOnShadow)))
						, _Is_UseTweakMatCapOnShadow
					);
				float4 _Set_MatcapMask_var			= tex2D(_Set_MatcapMask, TRANSFORM_TEX(Set_UV0, _Set_MatcapMask));
				float _Tweak_MatcapMaskLevel_var	= saturate(_Set_MatcapMask_var.g + _Tweak_MatcapMaskLevel);






//// Emission
				float4 _Emissive_Tex_var	= tex2D( _Emissive_Tex, TRANSFORM_TEX( Set_UV0, _Emissive_Tex));






//// Blend, Texture Color & High Color
				float3 heighColor_source	= _FinalColor_var;
				float highColor_onShadow	= 
					lerp(
						1
						, ((1.0 - shade_ramp_n1) + (shade_ramp_n1 * _TweakHighColorOnShadow))
						, _Is_UseTweakHighColorOnShadow
					);
				float3 Set_HighColor		= 
					lerp(
						( heighColor_source * (1 - _TweakHighColorMask_var))
						, heighColor_source
						, _Is_BlendAddToHiColor 
					)
					+ ( _HighColor_var * highColor_onShadow);



//// Blend, (Texture & High Color) & Rim Color
				float3 _RimLight_Source		= Set_HighColor;
				float3 _RimLight_combine	= 
					lerp( 
						_RimLight_Source
						, (_RimLight_Source + Set_RimLight_final)
						, _RimLight 
					);



//// Blend, (Texture & High & Rim) & Matcap & Emission
				float3 matCap_source		= _RimLight_combine;
				float3 matCap_isAdd			= matCap_source + _MatCap_Color * _Tweak_MatcapMaskLevel_var;
				float3 matCap_isMulti		= 
					((matCap_source * (1 - _Tweak_MatcapMaskLevel_var) 
					+ matCap_source * _MatCap_Color * _Tweak_MatcapMaskLevel_var));
				float3 matCap_type			= lerp(matCap_isMulti, matCap_isAdd, _Is_BlendAddToMatCap);
				float3 matCap_Combine		= lerp(matCap_source, matCap_type, _MatCap);



//// Blend, emission
				float3 emission_source		= matCap_Combine;
				// float emissiveMask			= saturate(dot(_Emissive_Tex_var.rgb, 1));
				float3 emissionMix			= (_Emissive_Tex_var.rgb * _Emissive_Color.rgb);
#ifdef UNITY_PASS_FORWARDBASE
				float3 emission_combine		= emission_source + emissionMix;
#else
				float3 emission_combine		= emission_source;
#endif



					// resolve NaN value colors.
					float3 finalColor_source	= emission_combine;
					float3 finalColor			= max(0, emission_combine);



// #ifdef _IS_CLIPPING_OFF
// //DoubleShadeWithFeather
// 	#ifdef UNITY_PASS_FORWARDBASE
// 					fixed4 finalRGBA	= fixed4(finalColor,1);
// 	#elif UNITY_PASS_FORWARDADD
// 					fixed4 finalRGBA	= fixed4(finalColor * 1,0);
// 	#endif

#ifdef _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
	#ifdef UNITY_PASS_FORWARDBASE
					fixed4 finalRGBA	= fixed4(finalColor,1);
	#elif UNITY_PASS_FORWARDADD
					fixed4 finalRGBA	= fixed4(finalColor * 1,0);
	#endif
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
					float Set_Opacity	= saturate((_Inverse_Clipping_var+_Tweak_transparency));
	#ifdef UNITY_PASS_FORWARDBASE
					fixed4 finalRGBA	= fixed4(finalColor,Set_Opacity);
	#elif UNITY_PASS_FORWARDADD
					fixed4 finalRGBA	= fixed4(finalColor * Set_Opacity,0);
	#endif
#else	// CLIPPING OFF
	//DoubleShadeWithFeather
	#ifdef UNITY_PASS_FORWARDBASE
					fixed4 finalRGBA	= fixed4(finalColor,1);
	#elif UNITY_PASS_FORWARDADD
					fixed4 finalRGBA	= fixed4(finalColor * 1,0);
	#endif
#endif
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}



			

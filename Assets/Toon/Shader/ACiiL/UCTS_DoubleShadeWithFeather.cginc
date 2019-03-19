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
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
				float4 tangent	: TANGENT;
				float2 uv		: TEXCOORD0;
			};

			struct VertexOutput {
				float4 pos		: SV_POSITION;
				float4 center	: TEXCOORD0;
				float4 worldPos	: TEXCOORD1;
				float3 wNormal	: TEXCOORD2;
				float4 tangent	: TEXCOORD3;
				float3 biNormal	: TEXCOORD4;
				half3 vertexLighting	: TEXCOORD5;
				half attenVert			: TEXCOORD6;
				float3 GIdirection	: TEXCOORD7;
				float2 uv			: TEXCOORD8;
				// LIGHTING_COORDS(9,10)
				UNITY_SHADOW_COORDS(9)
				UNITY_FOG_COORDS(10)
			};



			// raw ambient color by direction
			fixed3 DecodeLightProbe( fixed3 N ){
				return ShadeSH9( float4(N,1));
			}
			
			// ambient color
			fixed3 DecodeLightProbe_average(){
				//return (1 - softGI) * ShadeSH9( float4(N, 1)) + (softGI) * ShadeSH9( float4(0,0,0,1));
				return ShadeSH9( float4(0,0,0,1));
			}

			// vrchat shader community. Not sure exactly whom poked the mirror code to solve this.
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
				float3 pos,
				float3 normal,
				inout float attenVert){
					

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
			float3 StereoWorldViewPos( float3 worldPos) {
#if UNITY_SINGLE_PASS_STEREO
				float3 cameraPos	= 
					float3((unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5); 
#else
				float3 cameraPos	= _WorldSpaceCameraPos;
#endif
				return cameraPos;
			}

			//
			float3 StereoWorldViewDir( float3 worldPos) {
				float3 cameraPos	= StereoWorldViewPos(worldPos);
				float3 worldViewDir	= (cameraPos - worldPos);
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
				o.pos			= UnityObjectToClipPos( v.vertex );
				o.worldPos		= mul( unity_ObjectToWorld, v.vertex);
				o.center		= mul( unity_ObjectToWorld, float4(0,0,0,1));
				o.wNormal		= UnityObjectToWorldNormal( v.normal);
				o.tangent		= ( float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w));
				o.biNormal 		= ( cross( o.wNormal, o.tangent ) * o.tangent.w);
				// o.tangent			= normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0)).xyz );
				o.uv			= v.uv;


				// // testing shadow sample offsets
				// float3 sOffset			= (o.worldPos.xyz - o.center) * sin(_Time.y * UNITY_PI ) ;
				// // return float4(sOffset.xyz,1);
				// float3 yOffset			= sin(_Time.y * UNITY_PI ) * float3(0,1,0);
				// float shadowAtten		= UNITY_SHADOW_ATTENUATION(o, sOffset + o.center);

				// o.worldPos = mul(unity_ObjectToWorld, float4(0,1,0,1)); // 1m from mesh origin sample point
				// o.pos = UnityObjectToClipPos(float4(0,1,0,1));
				
				// o.worldPos = mul(unity_ObjectToWorld, v.vertex + yOffset); // Re-assign proper world and screen points for the vertex
				// o.pos = UnityObjectToClipPos(v.vertex + yOffset);
				// UNITY_TRANSFER_SHADOW(o, o.uv);

				// o.worldPos = mul(unity_ObjectToWorld, v.vertex); // Re-assign proper world and screen points for the vertex
				// o.pos = UnityObjectToClipPos(v.vertex);
				// o.pos = UnityObjectToClipPosEfficient(v.vertex);



				UNITY_TRANSFER_FOG(o, o.pos);
				UNITY_TRANSFER_SHADOW(o, o.uv);
				// TRANSFER_VERTEX_TO_FRAGMENT(o);

#ifdef VERTEXLIGHT_ON
				o.vertexLighting		= softShade4PointLights_Atten(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0
					, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3]
					, unity_4LightAtten0, o.worldPos, o.wNormal, o.attenVert);
#endif					
#ifdef UNITY_PASS_FORWARDBASE
				o.GIdirection			= GIsonarDirection();
#endif
				return o;
			}












//// frag
			float4 frag(VertexOutput i) : SV_TARGET {
				i.wNormal					= normalize( i.wNormal);
				float3 worldviewPos			= StereoWorldViewPos(i.worldPos.xyz);
				float3 viewDirection		= normalize(worldviewPos - i.worldPos.xyz);


				// normal map
				float3 normalMap			= UnpackNormal( tex2D( _NormalMap, TRANSFORM_TEX( i.uv, _NormalMap)));
				float3 normalLocal			= normalMap.rgb;
				float3x3 tangentTransform	= float3x3( i.tangent.xyz , i.biNormal.xyz, i.wNormal);
				float3 normalDirection		= ( mul( normalLocal, tangentTransform )); // Perturbed normals






//// albedo texure
				// base albedo
				float4 mainTex			= tex2D( _MainTex, TRANSFORM_TEX( i.uv, _MainTex));

				// clip & alpha handling. Here now so clip() may interrupt flow.
#ifdef _IS_CLIPPING_MODE
				//DoubleShadeWithFeather_Clipping
				float4 clipMask			= tex2D(_ClippingMask, TRANSFORM_TEX( i.uv, _ClippingMask));
				float clipTest			= saturate( (lerp( clipMask.r, (1.0 - clipMask.r), _Inverse_Clipping ) + _Clipping_Level));
				clip(clipTest - 0.5);

#elif _IS_CLIPPING_TRANSMODE
				//DoubleShadeWithFeather_TransClipping
				float4 clipMask			= tex2D( _ClippingMask, TRANSFORM_TEX(i.uv, _ClippingMask));
				float mainTexAlpha		= mainTex.a;
				float useMainTexAlpha	= lerp( clipMask.r, mainTexAlpha, _IsBaseMapAlphaAsClippingMask );
				float inverseClipping	= lerp( useMainTexAlpha, (1.0 - useMainTexAlpha), _Inverse_Clipping );
				float clipTest			= saturate( (inverseClipping + _Clipping_Level));
				clip(clipTest - 0.5);

#elif _IS_CLIPPING_OFF
				//DoubleShadeWithFeather
#endif

				float4 shadeMapTex_1	= tex2D( _1st_ShadeMap, TRANSFORM_TEX( i.uv, _1st_ShadeMap));
				float4 shadeMapTex_2	= tex2D( _2nd_ShadeMap, TRANSFORM_TEX( i.uv, _2nd_ShadeMap));






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






//// Light attenuation and direction
				UNITY_LIGHT_ATTENUATION_NOSHADOW(lightAtten, i, i.worldPos.xyz);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, i.worldPos.xyz);
				shadowAtten				= max(shadowAtten, i.attenVert);
				// float attenRampB		= lightAtten;
				// float shadowAttenB	= shadowAtten;
				float nLightAtten		= 1 - lightAtten;
				float nShadowAtten		= 1 - shadowAtten;
				float attenRampB		= ( (-(nLightAtten * nLightAtten) + 1));
				float shadowAttenB		= ( (-(nShadowAtten * nShadowAtten) + 1));
				float attenRamp			= attenRampB;



#ifdef UNITY_PASS_FORWARDBASE
				float3 viewLightDirection	= normalize( UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
				float3 lightDir				= normalize( _WorldSpaceLightPos0.xyz + (i.GIdirection) * .01 + viewLightDirection *.0001);
#elif UNITY_PASS_FORWARDADD
				float3 lightDir	= 
					normalize( 
						lerp( 
							_WorldSpaceLightPos0.xyz
							, _WorldSpaceLightPos0.xyz - i.worldPos.xyz
							, _WorldSpaceLightPos0.w)
					);
#endif






//// Mix light input colors
				//const half shadowRings			= .15;
#ifdef UNITY_PASS_FORWARDBASE
				//float shadRings		= (ceil( shadowAttenB / shadowRings) * (shadowRings));
				float shadRings			= shadowAttenB;
				float3 lightIndirect	= DecodeLightProbe_average();
				float3 lightDirect		= _LightColor0.rgb;
				float shadowBlackness	= max(_shadowCastMin_black, shadRings);
				float shaBlackMix		= shadowBlackness * attenRamp;
				lightDirect				= lightDirect * shaBlackMix;

				// float3 ndotl_lightDir	= saturate((_testMix) + (1 - _testMix) * dot(i.wNormal, lightDir));
				// float3 ndotl_lightDir	= saturate((_testMix) + (1 - _testMix) * DotClamped(i.wNormal, lightDir));
				// lightDirect				*= ndotl_lightDir;

				// fuzzy logic for classifying direct light < indirect light
				float lightDirGray		=  dot(_LightColor0.rgb,	1) / 3;
				float lightInDirGray	=  dot(lightIndirect.rgb,	1) / 3;
				float colorIntSignal	= (smoothstep(0, lightDirGray, lightInDirGray));

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
				// shadeColor			= lerp(shadeColor, shadeColor * _fc_test_mix, _testMix);




//// albedo textures
				// is using world color
				float3 baseColor_isLC	= lerp(attenRamp, Set_LightColor, _Is_LightColor_Base);
				float3 shadeColor1_isLC	= lerp(attenRamp, Set_LightColor, _Is_LightColor_1st_Shade);
				float3 shadeColor2_isLC	= lerp(attenRamp, Set_LightColor, _Is_LightColor_2nd_Shade);

				// get albedo samples
				float3 albetoCol_1		= mainTex.rgb;
				float3 albetoCol_2		= shadeMapTex_1.rgb;
				float3 albetoCol_3		= shadeMapTex_2.rgb;

				// get ramp shade color mix
				float3 rampWorldCol_1	= _Color.rgb * baseColor_isLC;
				float3 rampWorldCol_2	= _1st_ShadeColor.rgb * shadeColor1_isLC;
				float3 rampWorldCol_3	= _2nd_ShadeColor.rgb * shadeColor2_isLC;






//// toon Lambert 
				float3 useShadeNormal	= lerp( i.wNormal, normalDirection, _Is_NormalMapToBase);
				float ndotl_shade		= 0.5 + 0.5 * dot( useShadeNormal, lightDir);
				
				// Lambert & shadow attenuation mix
				float4 shadowTex_1	= tex2D( _Set_1st_ShadePosition, TRANSFORM_TEX( i.uv, _Set_1st_ShadePosition));
				float4 shadowTex_2	= tex2D( _Set_2nd_ShadePosition, TRANSFORM_TEX( i.uv, _Set_2nd_ShadePosition));

				float shadeRamp_n1		= 
					saturate(
						1.0 
						+ 
							(
								(
									lerp(
										ndotl_shade
										//, ( ndotl_shade * saturate( ((shadowAtten * 0.5) + 0.5 + _Tweak_SystemShadowsLevel)))
										// , ( ndotl_shade * saturate(smoothstep(0, 1, shadowAtten + _Tweak_SystemShadowsLevel) ) )
										// Create a continuous function to set shadow strength independent cast zones upon the toon ramp.
										, ( ndotl_shade * smoothstep(_LightShadowData.x + 0.001, 1 + _Tweak_SystemShadowsLevel, shadowAtten))
										, _Set_SystemShadowsToBase 
									)
									- ( _BaseColor_Step - _BaseShade_Feather )
								)
								* ( (1.0 - shadowTex_1.rgb).r - 1.0 ) 
							) 
						/ (_BaseShade_Feather)						
					);

				// shadow1 to shadow2 mix
				float shadeRamp_n2			=
						saturate(
							1.0 
							+ ( ndotl_shade - (_ShadeColor_Step - _1st2nd_Shades_Feather) )
							* ( (1.0 - shadowTex_2.rgb).r - 1.0 ) 
							/ ( _1st2nd_Shades_Feather )
						);



//// The 3 Shade mixer. Lerp: (base color, (shade 1, shade 2))
				// albedo mix
				float3 albedoMix_23		= lerp(albetoCol_2, albetoCol_3, shadeRamp_n2);
				float3 albedoMix_1_23	= lerp(albetoCol_1, albedoMix_23, shadeRamp_n1);

				// saturate albedo mix by shadows
				// logic
				float colTest			= 1 - ((saturate( ( (shadowBlackness) + ( colorIntSignal)))));
				float colTest2			= colTest;
				float colSateOffset		= 1 + _shaSatRatio * colTest2;
				// mix
				float3 albedoRGBIn		= albedoMix_1_23;
				float3 albedoHSV		= RGBToHSV( albedoRGBIn);
				float3 albedoSaturated	= HSVToRGB( float3(albedoHSV.x, ( albedoHSV.y * colSateOffset ), albedoHSV.z));

				// shades mix
				float3 shadeMix_23		= lerp(rampWorldCol_2, rampWorldCol_3, shadeRamp_n2);
				float3 shadeMix_1_23	= lerp(rampWorldCol_1, shadeMix_23, shadeRamp_n1);

				float3 shadeColor		= albedoSaturated * shadeMix_1_23;






//// High Color. Specular.
				float4 highColorMask		= tex2D( _Set_HighColorMask, TRANSFORM_TEX( i.uv, _Set_HighColorMask));
				float3 halfDirection		= normalize( viewDirection + lightDir);
				float3 highColorNormalType	= lerp( i.wNormal, normalDirection, _Is_NormalMapToHighColor );
				float3 hdotl_highColor		= 0.5 + 0.5 * dot(halfDirection, highColorNormalType);
				// float3 hdotl_highColor		= DotClamped(halfDirection, highColorNormalType);
				
				float highColorMaskSetup	= 
					saturate( highColorMask.g + _Tweak_HighColorMaskLevel)
					* lerp(
						( 1.0 - step(hdotl_highColor, ( 1.0 - _HighColor_Power)) )
						, pow( hdotl_highColor, exp2( lerp( 11, 1, _HighColor_Power)) )
						, _Is_SpecularToHighColor 
					);
				
				float4 highColorTex			= tex2D( _HighColor_Tex, TRANSFORM_TEX( i.uv, _HighColor_Tex));
				float3 highColor_isLC		= lerp( attenRamp, Set_LightColor, _Is_LightColor_HighColor);
				float3 highColorMix			= highColorTex.rgb * _HighColor.rgb;
				float3 highColorTotalCol	= ( highColor_isLC * highColorMix * highColorMaskSetup);






//// Rim Color
				float3 useRimLightNormal	= lerp( i.wNormal, normalDirection, _Is_NormalMapToRimLight);
				float ndov_rim				= dot( useRimLightNormal, viewDirection); // 1=norm with cam, -1=not
				float rimArea				= (1.0 - ndov_rim);	
				rimArea						= lerp(0, rimArea, saturate(ndov_rim + 1));


				float ndotl_pure			= 0.5 + 0.5 * dot( i.wNormal, lightDir);
				float rimLightPower			= pow(rimArea, exp2( lerp( 3, 0, _RimLight_Power )));
				float RimLightPowerAp		= pow(rimArea, exp2( lerp( 3, 0, _Ap_RimLight_Power )));				
				float3 rimLight_isLC		= lerp(attenRamp, Set_LightColor, _Is_LightColor_RimLight);
				float3 rimLightMix			= _RimLightColor.rgb * rimLight_isLC;
				// build the generic rim ramp mask.
				float rimlightMaskSetup		= 
					saturate(
						lerp(
							((rimLightPower - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask)) // soft
							, step( _RimLight_InsideMask, rimLightPower) // hard
							, _RimLight_FeatherOff 
						)
					);
				float rimlightMaskToward	= saturate( rimlightMaskSetup - ((1.0 - ndotl_pure) + _Tweak_LightDirection_MaskLevel));
				float rimLightMaskAway		= (ndotl_pure) + _Tweak_LightDirection_MaskLevel ;

				// builds a directional rim mask with colors. 0= generic rim, 1= generic mix with light on surface direction.
				float useRimLightDirMask	= lerp(rimlightMaskSetup, rimlightMaskToward, _LightDirection_MaskOn);
				float3 rimLightCol			= rimLightMix * useRimLightDirMask;



				// anti rimlight color by generic mask AND light dir mask.
				// strangely. Anti rimlight defaults to directional.
				float rimlightApMaskSetup	= 
					saturate(
						lerp(
							((RimLightPowerAp - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask))
							, step( _RimLight_InsideMask, RimLightPowerAp)
							, _Ap_RimLight_FeatherOff
						)
					);
				float rimlightApMask		= saturate(rimlightApMaskSetup - rimLightMaskAway);

				float3 rimLightAp_isLC		= lerp( attenRamp, Set_LightColor, _Is_LightColor_Ap_RimLight);
				float3 rimLigntApMix		= _Ap_RimLightColor.rgb * rimLightAp_isLC;
				float3 rimLightApCol		= rimLigntApMix * rimlightApMask;



				float4 rimLightMaskTex		= tex2D( _Set_RimLightMask, TRANSFORM_TEX( i.uv, _Set_RimLightMask));
				float3 rimLightTotalCol		= 
					saturate( rimLightMaskTex.g + _Tweak_RimLightMaskLevel)
					* lerp( 
						rimLightCol
						, ( rimLightCol + rimLightApCol)
						, _Add_Antipodean_RimLight 
					);






//// Matcap				
				float rot_MatCapUV_ang			= ( _Rotate_MatCapUV * 3.141592654);
				float rot_MatCapUV_spd			= 1.0;
				float rot_MatCapUV_cos			= cos( rot_MatCapUV_spd * rot_MatCapUV_ang);
				float rot_MatCapUV_sin			= sin( rot_MatCapUV_spd * rot_MatCapUV_ang);
				float2 rot_MatCapUV_piv			= float2(0.5,0.5);
				float rot_MatCapNmUV_ang		= ( _Rotate_NormalMapForMatCapUV * 3.141592654);
				float rot_MatCapNmUV_spd		= 1.0;
				float rot_MatCapNmUV_cos		= cos( rot_MatCapNmUV_spd * rot_MatCapNmUV_ang);
				float rot_MatCapNmUV_sin		= sin( rot_MatCapNmUV_spd * rot_MatCapNmUV_ang);
				float2 rot_MatCapNmUV_piv		= float2(0.5,0.5);
				float2 rot_MatCapNmUV			= ( mul( i.uv - rot_MatCapNmUV_piv, float2x2( rot_MatCapNmUV_cos, -rot_MatCapNmUV_sin, rot_MatCapNmUV_sin, rot_MatCapNmUV_cos)) + rot_MatCapNmUV_piv);
				float3 matCapNormalMapTex		= UnpackNormal( tex2D( _NormalMapForMatCap, TRANSFORM_TEX( rot_MatCapNmUV, _NormalMapForMatCap)));				



				//v.2.0.5: MatCap with camera skew correction.  @kanihira
				float3 viewNormal					= (mul(UNITY_MATRIX_V, float4(lerp( i.wNormal, mul( matCapNormalMapTex.rgb, tangentTransform ).rgb, _Is_NormalMapForMatCap ), 0))).xyz;
				float3 normalBlendMatcapUVDetail	= viewNormal.xyz * float3(-1,-1,1);
				float3 normalBlendMatcapUVBase		= (mul( UNITY_MATRIX_V, float4(viewDirection,0) ).rgb * float3(-1,-1,1)) + float3(0,0,1);
				float3 noSknewViewNormal			= normalBlendMatcapUVBase * dot(normalBlendMatcapUVBase, normalBlendMatcapUVDetail) / normalBlendMatcapUVBase.z - normalBlendMatcapUVDetail;
				float2 viewNormalAsMatCapUV			= ((noSknewViewNormal).xy * 0.5) + 0.5;
				float2 rot_MatCapUV					= 
					(
						mul(
							(
								((viewNormalAsMatCapUV - (_Tweak_MatCapUV)) ) / (1.0 - 2 * _Tweak_MatCapUV)
							) - rot_MatCapUV_piv
							, float2x2( rot_MatCapUV_cos, -rot_MatCapUV_sin, rot_MatCapUV_sin, rot_MatCapUV_cos)
						) 
						+ rot_MatCapUV_piv
					);



				float4 matCapTex		= tex2D( _MatCap_Sampler, TRANSFORM_TEX( rot_MatCapUV, _MatCap_Sampler));
				float3 matcap_isLC		= lerp( attenRamp, Set_LightColor, _Is_LightColor_MatCap);
				float3 matCapMix		= matcap_isLC * matCapTex.rgb * _MatCapColor.rgb;
				float3 matCapTotalCol		= 
					lerp( 
						matCapMix
						, (matCapMix * ( (1.0 - shadeRamp_n1) + (shadeRamp_n1 * _TweakMatCapOnShadow)))
						, _Is_UseTweakMatCapOnShadow
					);
				float4 matcapMaskTex	= tex2D(_Set_MatcapMask, TRANSFORM_TEX(i.uv, _Set_MatcapMask));
				float matcapMaskTweak	= saturate(matcapMaskTex.g + _Tweak_MatcapMaskLevel);






//// Emission
				float4 emissiveTex	= tex2D( _Emissive_Tex, TRANSFORM_TEX( i.uv, _Emissive_Tex));






//// Blend, Texture Color & High Color
				float3 highColorIn		= shadeColor;
				float highColorInShadow	= 
					lerp(
						1
						, ((1.0 - shadeRamp_n1) + (shadeRamp_n1 * _TweakHighColorOnShadow))
						, _Is_UseTweakHighColorOnShadow
					);
				float3 HighColorOut	= 
					lerp(
						( highColorIn * (1 - highColorMaskSetup))
						, highColorIn
						, _Is_BlendAddToHiColor 
					)
					+ ( highColorTotalCol * highColorInShadow);



//// Blend, (Texture & High Color) & Rim Color
				float3 rimLightIn			= HighColorOut;
				float3 rimLightOut	= 
					lerp( 
						rimLightIn
						, (rimLightIn + rimLightTotalCol)
						, _RimLight 
					);



//// Blend, (Texture & High & Rim) & Matcap & Emission
				float3 matCapIn				= rimLightOut;
				float3 matCap_isAdd			= matCapIn + matCapTotalCol * matcapMaskTweak;
				float3 matCap_isMulti		= 
					((matCapIn * (1 - matcapMaskTweak) 
					+ matCapIn * matCapTotalCol * matcapMaskTweak));
				float3 matCap_type			= lerp(matCap_isMulti, matCap_isAdd, _Is_BlendAddToMatCap);
				float3 matCapOut			= lerp(matCapIn, matCap_type, _MatCap);



//// Blend, emission
				float3 emissionIn		= matCapOut;
				// float emissiveMask			= saturate(dot(emissiveTex.rgb, 1));
				float3 emissionMix			= (emissiveTex.rgb * _Emissive_Color.rgb);
#ifdef UNITY_PASS_FORWARDBASE
				float3 emissionOut		= emissionIn + emissionMix;
#else
				float3 emissionOut		= emissionIn;
#endif



					// resolve NaN value colors.
					float3 finalColorIn	= emissionOut;
					float3 finalColor	= max(0, finalColorIn);






#ifdef _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
	#ifdef UNITY_PASS_FORWARDBASE
					fixed4 finalRGBA	= fixed4(finalColor,1);
	#elif UNITY_PASS_FORWARDADD
					fixed4 finalRGBA	= fixed4(finalColor * 1,0);
	#endif
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
					float Set_Opacity	= saturate((inverseClipping+_Tweak_transparency));
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
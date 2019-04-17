﻿Shader "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather_TransClippingFade" {
	Properties {
		[Enum(OFF,0,FRONT,1,BACK,2)] _CullMode	("Cull Mode", int)	= 2  //OFF/FRONT/BACK



		[Space(25)]
		[Header(Alpha mask)]
		_ClippingMask		("Clipping mask", 2D)					= "white" {}
		_Clipping_Level		("Clipping level", Range(0, 1))			= 0
		_Tweak_transparency	("Tweak transparency", Range(-1, 1))	= 0
		[Toggle(_)]_IsBaseMapAlphaAsClippingMask	("Use main texture Alpha", Float )	= 0
		[Toggle(_)]_Inverse_Clipping				("Inverse clipping", Float )		= 0
		[Enum(Off,0,On,1)] _ZWrite	("Z Write. Depth write", Int)						= 1



		[Space(25)]
		[Header(Normal map)]
		_NormalMap							("NormalMap", 2D)			= "bump" {}
		[Toggle(_)]_Is_NormalMapToBase		("On Toon", Float )			= 0
		[Toggle(_)]_Is_NormalMapToHighColor	("On High Color", Float )	= 0
		[Toggle(_)]_Is_NormalMapToRimLight	("On Rims", Float )			= 0
		[Toggle(_)]_Is_NormaMapToEnv		("On Reflection", Float)	= 0



		[Space(25)]
		[Header(Toon ramp)]
		_MainTex				("Main Tex", 2D)							= "white" {}
		_1st_ShadeMap			("1st shade Tex 1", 2D)						= "white" {}
		_2nd_ShadeMap			("2nd shade Tex 2", 2D)						= "white" {}
		[Enum(Self,0,BaseTex,1)]_Use_BaseAs1st	("1st shade source", float)	= 1
		[Enum(Self,0,Shade1,1)]_Use_1stAs2nd	("2st shade source", float)	= 1
		[HDR]_Color				("Base color", Color)						= (1,1,1,1)
		[HDR]_1st_ShadeColor	("1st shade color 1", Color)				= (1,1,1,1)
		[HDR]_2nd_ShadeColor	("2nd shade color 2", Color)				= (1,1,1,1)
		_BaseColor_Step			("Step: base|shades ", Range(0, 1))			= 0.6
		_ShadeColor_Step		("Step: shades 1|2", Range(0, 1))			= 0.4
		_BaseShade_Feather		("Feather: base|shades", Range(0.0001, 1))	= 0.0001
		_1st2nd_Shades_Feather	("Feather: shades 1|2", Range(0.0001, 1))	= 0.0001



		[Space(25)]
		[Header(Shadow and AO control)]
		_Set_1st_ShadePosition 		("1st AO shade Position", 2D)					= "white" {}
		_Set_2nd_ShadePosition 		("2nd AO shade Position", 2D)					= "white" {}
		_shadowCastMin_black 		("Shadow minimal dark", Range(0.0,1.0))			= 0
		[Toggle(_)]_Set_SystemShadowsToBase	("Shadow affects shading", Float )		= 1
		_Tweak_SystemShadowsLevel	("Tweak shade from shadow", Range(-0.5, 0.5))	= 0
		_shaSatRatio				("Shadow saturate ratio", Range(0, 2))			= 0.125



		[Space(25)]
		[Header(High Color. Specular)]
		_HighColor_Tex				("HighColor Tex albedo", 2D)				= "white" {}
		_Set_HighColorMask			("HighColor Tex Mask", 2D)					= "white" {}
		[Enum(Self,0,BaseTex,1)]_highColTexSource	("HighColor source", float)	= 0
		_Tweak_HighColorMaskLevel	("Tweak highColor Mask", Range(-1, 1))		= 0
		[HDR]_HighColor				("Color", Color)							= (0,0,0,1)
		_HighColor_Power			("Power", Range(0, 1))						= 0
		[Enum(Replace,0,Add,1)]_Is_BlendAddToHiColor	("Blend mode", Float )	= 1
		[Toggle(_)]_Is_SpecularToHighColor	("Is highColor soft", Float )						= 0
		[Toggle(_)]_Is_UseTweakHighColorOnShadow	("Mask highColor in shadow", Float )		= 0
		_TweakHighColorOnShadow						("Tweak highColor in shadow", Range(0, 1))	= 0



		[Space(25)]
		[Header(Rimlights)]
		_Set_RimLightMask			("RimLight Tex mask", 2D)			= "white" {}
		_Tweak_RimLightMaskLevel	("Tweak: mask", Range(-1, 1))		= 0
		[Enum(Off,0,Add,1,Replace,2)]_RimLight		("Mix: RimLight", Float )					= 0
		[Enum(Off,0,Add,1,Replace,2)]_Add_Antipodean_RimLight	("Mix: Ap RimLight", Float )	= 0
		[Enum(None,0,BaseTex,1,HighColor,2,Shade1,3,Shade2,4)]_RimLightSource	("Source albedo", Float)	= 0
		[HDR]_RimLightColor			("Color: RimLight", Color)						= (1,1,1,1)
		[HDR]_Ap_RimLightColor		("Color: Ap RimLight", Color)					= (1,1,1,1)
		[Toggle(_)]_LightDirection_MaskOn	("Use light direction", Float )			= 0
		[Toggle(_)]_RimLight_FeatherOff		("Off rimLight feather", Float )		= 0
		[Toggle(_)]_Ap_RimLight_FeatherOff	("Off Ap rimLight feather", Float )		= 0
		_RimLight_Power			("Power: RimLight", Range(0, 1))					= 0.1
		_Ap_RimLight_Power		("Power: Ap RimLight", Range(0, 1))					= 0.1
		_RimLightAreaOffset		("Offset: RimLight", Range(-1, 1))					= 0
		_RimLight_InsideMask	("Mask: Inside rimLight", Range(0.00001, 1))		= 0.0001
		_Tweak_LightDirection_MaskLevel	("Mask: Light direction", Range(0, 1))		= 0



		[Space(25)]
		[Header(World reflection)]
		_envRoughness	("Reflection roughness", Range(0, 1))	= 0.34
		_envOnRim		("Reflection on rimLights", Range(0,1))	= 0.5



		[Space(25)]
		[Header(Matcap)]
		_NormalMapForMatCap					("MatCap normalMap", 2D)					= "bump" {}
		[Toggle(_)]_Is_NormalMapForMatCap	("Use matcap normalMap ", Float )			= 0
		_MatCap_Sampler						("MatCap Tex albedo", 2D)					= "black" {}
		_Set_MatcapMask						("Matcap mask", 2D)							= "white" {}
		_Tweak_MatcapMaskLevel				("Tweak: Matcap mask", Range(-1, 1))		= 0
		[Toggle(_)]_MatCap					("Use MatCap", Float )						= 0
		[HDR]_MatCapColor					("MatCap Color", Color)						= (1,1,1,1)
		[Enum(Multiply,0,Add,1)]_Is_BlendAddToMatCap	("Matcap Blend Mode", Float)	= 1
		_Tweak_MatCapUV						("Zoom matCap", Range(-0.5, 0.5))			= 0
		_Rotate_MatCapUV					("Rotate matCap", Range(-1, 1))				= 0
		_Rotate_NormalMapForMatCapUV		("Rotate normalMap matCap", Range(-1, 1))	= 0
		[Toggle(_)]_Is_UseTweakMatCapOnShadow	("Mask matCap in shadow", Float )		= 0
		_TweakMatCapOnShadow				("Tweak matCap in shadow", Range(0, 1))		= 0



		[Space(25)]
		[Header(Emission)]
		_Emissive_Tex			("Emissive mask tex", 2D) 	= "white" {}
		_EmissionColorTex		("Emissive color tex", 2D) 	= "white" {}
		[HDR]_Emissive_Color	("Emissive color", Color)	= (0,0,0,1)



		[Space(25)]
		[Header(Use world color settings)]
		[Toggle(_)]_Is_LightColor_Base			("Use LightColor in Base", Float )			= 1
		[Toggle(_)]_Is_LightColor_1st_Shade		("Use LightColor in 1st_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_2nd_Shade		("Use LightColor in 2nd_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_HighColor		("Use LightColor in HighColor", Float )		= 1
		[Toggle(_)]_Is_LightColor_RimLight		("Use LightColor in RimLight", Float )		= 1
		[Toggle(_)]_Is_LightColor_Ap_RimLight	("Use LightColor in Ap RimLight", Float )	= 1
		[Toggle(_)]_Is_LightColor_MatCap		("Use LightColor in MatCap", Float )		= 1



		[Space(25)]
		[Header(Outline)]
		[Enum(NML,0,POS,1)] _outline_mode	("OUTLINE MODE", Int)		= 0
		_OutlineTex						("Outline tex", 2D) 			= "white" {}
		_Outline_Sampler				("Outline sampler", 2D)			= "white" {}
		_Outline_Color					("Outline color", Color)		= (0.5,0.5,0.5,1)
		[Toggle(_)]_Is_BlendBaseColor	("Is Blend base color", Float )	= 0
		[Toggle(_)]_Is_OutlineTex	("Is outline Tex", Float )			= 0
		_Outline_Width				("Outline width", Float )			= 1
		_Nearest_Distance			("Nearest distance", Float )		= 0.5
		_Farthest_Distance			("Farthest distance", Float )		= 10
		_Offset_Z					("Offset Camera Z depth", Float) 	= 0
		_OutlineshadowCastMin_black	("outline Shadow minimal dark", Range(0.0,1.0))	= 0.0



		[Space(25)]
		[Header(Stencil)]
		_Offset					("Offset", float)						= 0
		[Toggle(_)] _Stencil	("Stencil ID [0;255]", Range(0,255))	= 0
		_ReadMask				("ReadMask [0;255]", Int)				= 255
		_WriteMask				("WriteMask [0;255]", Int)				= 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp	("Stencil Comparison", Int)	= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp			("Stencil Operation", Int)	= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail		("Stencil Fail", Int)		= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail		("Stencil ZFail", Int)		= 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest					("ZTest", Int)	= 4
		[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _colormask	("Color Mask", Int)	= 15
	}
	// Properties {
	// 	[Enum(OFF,0,FRONT,1,BACK,2)] _CullMode	("Cull Mode", int)	= 2  //OFF/FRONT/BACK



	// 	[Space(25)]
	// 	[Header(Alpha mask. Set z write off)]
	// 	_ClippingMask		("ClippingMask", 2D)					= "white" {}
	// 	_Clipping_Level		("Clipping_Level", Range(0, 1))			= 0
	// 	_Tweak_transparency	("Tweak_transparency", Range(-1, 1))	= 0
	// 	[Toggle(_)]_IsBaseMapAlphaAsClippingMask	("IsBaseMapAlphaAsClippingMask", Float )	= 0
	// 	[Toggle(_)]_Inverse_Clipping				("Inverse_Clipping", Float )				= 0
	// 	[Enum(Off,0,On,1)] _ZWrite	("ZWrite", Int)												= 1



	// 	[Space(25)]
	// 	[Header(Normal map)]
	// 	_NormalMap							("NormalMap", 2D) = "bump" {}
	// 	[Toggle(_)]_Is_NormalMapToBase		("Is_NormalMapToBase", Float )		= 0
	// 	[Toggle(_)]_Is_NormalMapToHighColor	("Is_NormalMapToHighColor", Float )	= 0
	// 	[Toggle(_)]_Is_NormalMapToRimLight	("Is_NormalMapToRimLight", Float )	= 0
	// 	[Toggle(_)]_Is_NormaMapToEnv		("Is normalMap on reflection", Float)	= 0



	// 	[Space(25)]
	// 	[Header(Toon ramp)]
	// 	_MainTex				("BaseMap", 2D)									= "white" {}
	// 	_1st_ShadeMap			("1st_ShadeMap", 2D)							= "white" {}
	// 	_2nd_ShadeMap			("2nd_ShadeMap", 2D)							= "white" {}
	// 	[HDR]_Color				("BaseColor", Color)							= (1,1,1,1)
	// 	[HDR]_1st_ShadeColor	("1st_ShadeColor", Color)						= (1,1,1,1)
	// 	[HDR]_2nd_ShadeColor	("2nd_ShadeColor", Color)						= (1,1,1,1)
	// 	_BaseColor_Step			("BaseColor_Step", Range(0, 1))					= 0.6
	// 	_ShadeColor_Step		("ShadeColor_Step", Range(0, 1))				= 0.4
	// 	_BaseShade_Feather		("Base/Shade_Feather", Range(0.0001, 1))		= 0.0001
	// 	_1st2nd_Shades_Feather	("1st/2nd_Shades_Feather", Range(0.0001, 1))	= 0.0001



	// 	[Space(25)]
	// 	[Header(Shadow and AO control)]
	// 	_Set_1st_ShadePosition 		("Set_1st_ShadePosition", 2D)							= "white" {}
	// 	_Set_2nd_ShadePosition 		("Set_2nd_ShadePosition", 2D)							= "white" {}
	// 	_shadowCastMin_black 		("shadow dark min, def=0", Range(0.0,1.0))				= 0
	// 	[Toggle(_)]_Set_SystemShadowsToBase	("Shadow affects Shading", Float )				= 1
	// 	_Tweak_SystemShadowsLevel	("Tweak_SystemShadowsLevel", Range(-0.5, 0.5))			= 0
	// 	_shaSatRatio				("shadow saturate ratio", Range(0, 2))					= 0.125



	// 	[Space(25)]
	// 	[Header(HighColor. Shine)]
	// 	_HighColor_Tex				("HighColor_Tex", 2D)						= "white" {}
	// 	_Set_HighColorMask			("Set_HighColorMask", 2D)					= "white" {}
	// 	_Tweak_HighColorMaskLevel	("Tweak_HighColorMaskLevel", Range(-1, 1))	= 0
	// 	[HDR]_HighColor				("HighColor", Color)						= (0,0,0,1)
	// 	_HighColor_Power			("HighColor_Power", Range(0, 1))			= 0
	// 	[Toggle(_)]_Is_BlendAddToHiColor	("Is_BlendAddToHiColor", Float )	= 1
	// 	[Toggle(_)]_Is_SpecularToHighColor	("Is_SpecularToHighColor", Float )	= 0
	// 	[Toggle(_)]_Is_UseTweakHighColorOnShadow	("Is_UseTweakHighColorOnShadow", Float )	= 0
	// 	_TweakHighColorOnShadow						("TweakHighColorOnShadow", Range(0, 1))		= 0



	// 	[Space(25)]
	// 	[Header(Rimlights)]
	// 	_Set_RimLightMask			("Set_RimLightMask", 2D)					= "white" {}
	// 	_Tweak_RimLightMaskLevel	("Tweak_RimLightMaskLevel", Range(-1, 1))	= 0
	// 	[Toggle(_)]_RimLight		("RimLight", Float )						= 0
	// 	[Toggle(_)]_Add_Antipodean_RimLight	("Add_Antipodean_RimLight", Float )	= 0
	// 	[HDR]_RimLightColor			("RimLightColor", Color)					= (1,1,1,1)
	// 	[HDR]_Ap_RimLightColor		("Ap_RimLightColor", Color)					= (1,1,1,1)
	// 	[Toggle(_)]_LightDirection_MaskOn	("LightDirection_MaskOn", Float )	= 0
	// 	[Toggle(_)]_RimLight_FeatherOff		("RimLight_FeatherOff", Float )		= 0
	// 	[Toggle(_)]_Ap_RimLight_FeatherOff	("Ap_RimLight_FeatherOff", Float )	= 0
	// 	_RimLight_Power			("RimLight_Power", Range(0, 0.9999))			= 0.1
	// 	_Ap_RimLight_Power		("Ap_RimLight_Power", Range(0, 0.9999))			= 0.1
	// 	_RimLight_InsideMask	("RimLight_InsideMask", Range(0.0001, 1))		= 0.0001
	// 	_Tweak_LightDirection_MaskLevel	("Tweak_LightDirection_MaskLevel", Range(0, 0.5))	= 0



	// 	[Space(25)]
	// 	[Header(World reflection)]
	// 	_envRoughness	("Reflection roughness", Range(0, 1))	= 0.34
	// 	_envOnRim		("Reflection on rim lights", Range(0,1))	= 0.5



	// 	[Space(25)]
	// 	[Header(Matcap)]
	// 	_NormalMapForMatCap					("MatCap NormalMap", 2D)				= "bump" {}
	// 	[Toggle(_)]_Is_NormalMapForMatCap	("Is_NormalMapForMatCap", Float )		= 0
	// 	_MatCap_Sampler						("MatCap_Sampler", 2D)					= "black" {}
	// 	_Set_MatcapMask						("Set_MatcapMask", 2D)					= "white" {}
	// 	_Tweak_MatcapMaskLevel				("Tweak_MatcapMaskLevel", Range(-1, 1))	= 0
	// 	[Toggle(_)]_MatCap					("Use MatCap", Float )					= 0
	// 	[HDR]_MatCapColor					("MatCapColor", Color)					= (1,1,1,1)
	// 	[Toggle(_)]_Is_BlendAddToMatCap		("Is_BlendAddToMatCap", Float ) 		= 1
	// 	_Tweak_MatCapUV						("Tweak_MatCapUV", Range(-0.5, 0.5))	= 0
	// 	_Rotate_MatCapUV					("Rotate_MatCapUV", Range(-1, 1))		= 0
	// 	_Rotate_NormalMapForMatCapUV		("Rotate_NormalMapForMatCapUV", Range(-1, 1))	= 0
	// 	[Toggle(_)]_Is_UseTweakMatCapOnShadow	("Is_UseTweakMatCapOnShadow", Float )		= 0
	// 	_TweakMatCapOnShadow				("TweakMatCapOnShadow", Range(0, 1))			= 0



	// 	[Space(25)]
	// 	[Header(Emission)]
	// 	_Emissive_Tex			("Emissive_Tex", 2D) 		= "white" {}
	// 	_EmissionColorTex		("Emissive Color Texture", 2D) 	= "white" {}
	// 	[HDR]_Emissive_Color	("Emissive_Color", Color)	= (0,0,0,1)



	// 	[Space(25)]
	// 	[Header(Is world color switches)]
	// 	[Toggle(_)]_Is_LightColor_Base			("Is_LightColor_Base", Float )			= 1
	// 	[Toggle(_)]_Is_LightColor_1st_Shade		("Is_LightColor_1st_Shade", Float )		= 1
	// 	[Toggle(_)]_Is_LightColor_2nd_Shade		("Is_LightColor_2nd_Shade", Float )		= 1
	// 	[Toggle(_)]_Is_LightColor_HighColor		("Is_LightColor_HighColor", Float )		= 1
	// 	[Toggle(_)]_Is_LightColor_RimLight		("Is_LightColor_RimLight", Float )		= 1
	// 	[Toggle(_)]_Is_LightColor_Ap_RimLight	("Is_LightColor_Ap_RimLight", Float )	= 1
	// 	[Toggle(_)]_Is_LightColor_MatCap		("Is_LightColor_MatCap", Float )		= 1



	// 	[Space(25)]
	// 	[Header(Outline)]
	// 	[Enum(NML,0,POS,1)] _outline_mode	("OUTLINE MODE", Int)		= 0
	// 	_OutlineTex						("OutlineTex", 2D) 			= "white" {}
	// 	_Outline_Sampler				("Outline_Sampler", 2D)		= "white" {}
	// 	_Outline_Color					("Outline_Color", Color)	= (0.5,0.5,0.5,1)
	// 	[Toggle(_)]_Is_BlendBaseColor	("Is_BlendBaseColor", Float )	= 0
	// 	[Toggle(_)]_Is_OutlineTex	("Is_OutlineTex", Float )			= 0
	// 	_Outline_Width				("Outline_Width", Float )			= 1
	// 	_Nearest_Distance			("Nearest_Distance", Float )		= 0.5
	// 	_Farthest_Distance			("Farthest_Distance", Float )		= 10
	// 	_Offset_Z					("Offset_Camera_Z", Float) 			= 0
	// 	_OutlineshadowCastMin_black	("outline shadow dark min, def=0", Range(0.0,1.0))	= 0.0



	// 	[Space(25)]
	// 	[Header(Stencil)]
	// 	_Offset					("Offset", float)						= 0
	// 	[Toggle(_)] _Stencil	("Stencil ID [0;255]", Range(0,255))	= 0
	// 	_ReadMask				("ReadMask [0;255]", Int)				= 255
	// 	_WriteMask				("WriteMask [0;255]", Int)				= 255
	// 	[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp	("Stencil Comparison", Int)	= 0
	// 	[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp			("Stencil Operation", Int)	= 0
	// 	[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail		("Stencil Fail", Int)		= 0
	// 	[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail		("Stencil ZFail", Int)		= 0
	// 	//[Enum(Off,0,On,1)] _ZWrite	("ZWrite", Int)												= 1
	// 	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest					("ZTest", Int)		= 4
	// 	[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _colormask	("Color Mask", Int)	= 15 
	// }






	SubShader {
		Tags {
			"Queue"="AlphaTest+50"
			"RenderType"="TransparentCutout"
		}



		Pass {
			Name "Outline"
			Tags {
				"LightMode" = "ForwardBase" 
			}
			Cull front 
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTest]
			ZWrite [_ZWrite]

			Stencil
			{
				Ref [_Stencil]
				ReadMask [_ReadMask]
				WriteMask [_WriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile _IS_OUTLINE_CLIPPING_YES 
			#pragma multi_compile UNITY_PASS_FORWARDBASE
			#include "UCTS_Outline.cginc"
			ENDCG
		}



		Pass {
			Name "Outline_Delta"
			Tags {
				"LightMode" = "ForwardAdd" 
			}
			Cull front
			Blend One One
			ZTest [_ZTest]
			ZWrite [_ZWrite]

			Stencil
			{
				Ref [_Stencil]
				ReadMask [_ReadMask]
				WriteMask [_WriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile _IS_OUTLINE_CLIPPING_YES
			#pragma multi_compile UNITY_PASS_FORWARDADD
			#include "UCTS_Outline.cginc"
			ENDCG
		}



		Pass {
			Name "FORWARD"
			Tags {
				"LightMode"="ForwardBase"
			}
			Cull[_CullMode]
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTest]
			ZWrite [_ZWrite]

			Stencil
			{
				Ref [_Stencil]
				ReadMask [_ReadMask]
				WriteMask [_WriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile UNITY_PASS_FORWARDBASE
			#include "UCTS_DoubleShadeWithFeather.cginc"
			ENDCG
		}



		Pass {
			Name "FORWARD_DELTA"
			Tags {
				"LightMode"="ForwardAdd"
			}
			Cull[_CullMode]
			Blend One One
			ZTest [_ZTest]
			ZWrite [_ZWrite]

			Stencil
			{
				Ref [_Stencil]
				ReadMask [_ReadMask]
				WriteMask [_WriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile UNITY_PASS_FORWARDADD
			#include "UCTS_DoubleShadeWithFeather.cginc"
			ENDCG
		}



		Pass {
			Name "ShadowCaster"
			Tags {
				"LightMode"="ShadowCaster"
			}
			Offset 1, 1
			Cull Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcaster
			#include "UCTS_ShadowCaster.cginc"
			ENDCG
		}
	}
	FallBack "Legacy Shaders/VertexLit"
}

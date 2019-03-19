Shader "UnityChanToonShader/ACiiL/NoOutline/ToonColor_DoubleShadeWithFeather" {
	Properties {
		[Enum(OFF,0,FRONT,1,BACK,2)] _CullMode	("Cull Mode", int)	= 2  //OFF/FRONT/BACK

		// _testMix	("test mix", Range(0, 1))	= 1


		[Space(25)]
		[Header(Normal map)]
		_NormalMap							("NormalMap", 2D) = "bump" {}
		[Toggle(_)]_Is_NormalMapToBase		("Is_NormalMapToBase", Float )		= 0
		[Toggle(_)]_Is_NormalMapToHighColor	("Is_NormalMapToHighColor", Float )	= 0
		[Toggle(_)]_Is_NormalMapToRimLight	("Is_NormalMapToRimLight", Float )	= 0



		[Space(25)]
		[Header(Toon ramp)]
		_MainTex				("BaseMap", 2D)									= "white" {}
		_1st_ShadeMap			("1st_ShadeMap", 2D)							= "white" {}
		_2nd_ShadeMap			("2nd_ShadeMap", 2D)							= "white" {}
		[HDR]_Color				("BaseColor", Color)							= (1,1,1,1)
		[HDR]_1st_ShadeColor	("1st_ShadeColor", Color)						= (1,1,1,1)
		[HDR]_2nd_ShadeColor	("2nd_ShadeColor", Color)						= (1,1,1,1)
		_BaseColor_Step			("BaseColor_Step", Range(0, 1))					= 0.6
		_ShadeColor_Step		("ShadeColor_Step", Range(0, 1))				= 0.4
		_BaseShade_Feather		("Base/Shade_Feather", Range(0.0001, 1))		= 0.0001
		_1st2nd_Shades_Feather	("1st/2nd_Shades_Feather", Range(0.0001, 1))	= 0.0001



		[Space(25)]
		[Header(Shadow and AO control)]
		_Set_1st_ShadePosition 		("Set_1st_ShadePosition", 2D)							= "white" {}
		_Set_2nd_ShadePosition 		("Set_2nd_ShadePosition", 2D)							= "white" {}
		_shadowCastMin_black 		("shadow dark min, def=0", Range(0.0,1.0))				= 0
		[Toggle(_)]_Set_SystemShadowsToBase	("Shadow affects Shading", Float )				= 1
		_Tweak_SystemShadowsLevel	("Tweak_SystemShadowsLevel", Range(-0.5, 0.5))			= 0
		_shaSatRatio				("shadow saturate ratio", Range(0, 2))					= 0.5



		[Space(25)]
		[Header(HighColor. Shine)]
		_HighColor_Tex				("HighColor_Tex", 2D)						= "white" {}
		_Set_HighColorMask			("Set_HighColorMask", 2D)					= "white" {}
		_Tweak_HighColorMaskLevel	("Tweak_HighColorMaskLevel", Range(-1, 1))	= 0
		[HDR]_HighColor				("HighColor", Color)						= (0,0,0,1)
		_HighColor_Power			("HighColor_Power", Range(0, 1))			= 0
		[Toggle(_)]_Is_BlendAddToHiColor	("Is_BlendAddToHiColor", Float )	= 1
		[Toggle(_)]_Is_SpecularToHighColor	("Is_SpecularToHighColor", Float )	= 0
		[Toggle(_)]_Is_UseTweakHighColorOnShadow	("Is_UseTweakHighColorOnShadow", Float )	= 0
		_TweakHighColorOnShadow						("TweakHighColorOnShadow", Range(0, 1))		= 0



		[Space(25)]
		[Header(Rimlights)]
		_Set_RimLightMask			("Set_RimLightMask", 2D)					= "white" {}
		_Tweak_RimLightMaskLevel	("Tweak_RimLightMaskLevel", Range(-1, 1))	= 0
		[Toggle(_)]_RimLight		("RimLight", Float )						= 0
		[Toggle(_)]_Add_Antipodean_RimLight	("Add_Antipodean_RimLight", Float )	= 0
		[HDR]_RimLightColor			("RimLightColor", Color)					= (1,1,1,1)
		[HDR]_Ap_RimLightColor		("Ap_RimLightColor", Color)					= (1,1,1,1)
		[Toggle(_)]_LightDirection_MaskOn	("LightDirection_MaskOn", Float )	= 0
		[Toggle(_)]_RimLight_FeatherOff		("RimLight_FeatherOff", Float )		= 0
		[Toggle(_)]_Ap_RimLight_FeatherOff	("Ap_RimLight_FeatherOff", Float )	= 0
		_RimLight_Power			("RimLight_Power", Range(0, 0.9999))			= 0.1
		_Ap_RimLight_Power		("Ap_RimLight_Power", Range(0, 0.9999))			= 0.1
		_RimLight_InsideMask	("RimLight_InsideMask", Range(0.0001, 1))		= 0.0001
		_Tweak_LightDirection_MaskLevel	("Tweak_LightDirection_MaskLevel", Range(0, 0.5))	= 0



		[Space(25)]
		[Header(Matcap)]
		_NormalMapForMatCap					("MatCap NormalMap", 2D)				= "bump" {}
		[Toggle(_)]_Is_NormalMapForMatCap	("Is_NormalMapForMatCap", Float )		= 0
		_MatCap_Sampler						("MatCap_Sampler", 2D)					= "black" {}
		_Set_MatcapMask						("Set_MatcapMask", 2D)					= "white" {}
		_Tweak_MatcapMaskLevel				("Tweak_MatcapMaskLevel", Range(-1, 1))	= 0
		[Toggle(_)]_MatCap					("Use MatCap", Float )					= 0
		[HDR]_MatCapColor					("MatCapColor", Color)					= (1,1,1,1)
		[Toggle(_)]_Is_BlendAddToMatCap		("Is_BlendAddToMatCap", Float ) 		= 1
		_Tweak_MatCapUV						("Tweak_MatCapUV", Range(-0.5, 0.5))	= 0
		_Rotate_MatCapUV					("Rotate_MatCapUV", Range(-1, 1))		= 0
		_Rotate_NormalMapForMatCapUV		("Rotate_NormalMapForMatCapUV", Range(-1, 1))	= 0
		[Toggle(_)]_Is_UseTweakMatCapOnShadow	("Is_UseTweakMatCapOnShadow", Float )		= 0
		_TweakMatCapOnShadow				("TweakMatCapOnShadow", Range(0, 1))			= 0



		[Space(25)]
		[Header(Emission)]
		_Emissive_Tex			("Emissive_Tex", 2D) 		= "white" {}
		[HDR]_Emissive_Color	("Emissive_Color", Color)	= (0,0,0,1)



		[Space(25)]
		[Header(Is world color switches)]
		[Toggle(_)]_Is_LightColor_Base			("Is_LightColor_Base", Float )			= 1
		[Toggle(_)]_Is_LightColor_1st_Shade		("Is_LightColor_1st_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_2nd_Shade		("Is_LightColor_2nd_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_HighColor		("Is_LightColor_HighColor", Float )		= 1
		[Toggle(_)]_Is_LightColor_RimLight		("Is_LightColor_RimLight", Float )		= 1
		[Toggle(_)]_Is_LightColor_Ap_RimLight	("Is_LightColor_Ap_RimLight", Float )	= 1
		[Toggle(_)]_Is_LightColor_MatCap		("Is_LightColor_MatCap", Float )		= 1



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
		[Enum(Off,0,On,1)] _ZWrite	("ZWrite", Int)												= 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest					("ZTest", Int)		= 4
		[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _colormask	("Color Mask", Int)	= 15 
	}






	SubShader {
		Tags {
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/FORWARD"
		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/FORWARD_DELTA"
		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/SHADOWCASTER"
	}
	FallBack "Legacy Shaders/VertexLit"
}

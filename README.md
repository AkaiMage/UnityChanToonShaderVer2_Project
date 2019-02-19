README.md



# Intro:
UTS-ac shader, a git fork of UnityChanToonShaderVer2_Project with lighting improvements and bug fixes based on the v2.0.4+ versions.
Tweaks by ACiiL.

https://github.com/ACIIL/UnityChanToonShaderVer2_Project

Credits to the original author(s) unity3d-jp for humbly providing UTS2 open source to everyone and those that helped me develop the improvements.

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project






# Forward plan and history:
This has a been about a year long on-and-off study project since middle of January 2018. Back then no one knew UnityChanToonShaderVer2_Project (UTS or UTS2) and it didnt work in vrchat, I was interested in making it not be broken in vrchat. Some on and off weeks heavy studying unity's hlsl i learned nearly every aspect of unity's lighting and how to correctly manipulate them for this shader. This fork is now known as UTS-ac.

After some lucky back and forth on twitter with the main author of this shader i gave him my code fork and thus the main branch of UTS became functional in vrchat and i now see that shader branch used among the Japanese community and paired alongside commercial avatar models. Its kinda nice knowing i helped everyone...

My UTS branch is its own separate fork. I have my own methods to approach UNITY engine's lighting system for different light types, as implementing the light types of direct (and shadows), indirect (all ambient light), reflection probes, and more requires a considerable amount of UNITY file includes study and not "node based" creation from shader forge or Amplify. To transform the the "realism" of PBR in to the "stylised" cartoon look i go for that makes my code fork different. I want to give artists the power to select UTS shader effects without disobeying unity's light system and will fight unity's include file's hell to achieve that.

To those in the vrchat shader community, Thank you all. After all my study and dumb questions towards acquaintances and friends i got UTS to look right in vrchat! I hope to author my own original toon shader someday, but because how much i like UTS approch i'll likely see myself  improving aspects of UTS until its barely recognisable. 
 

In regards to improvements i will accept code contribution as pull requests! If you see something to improve pass me the bug fix for my fork (please use git so your work is recorded in the system!).  I will stick to github and git methodology so everything is recorded and easy to manage as shader community that wants to contribute to my project.

I believe UTS is one of the best approaches to toon shading with its effects, it takes the artists' toon ramps and painting, shines, rims, and macaps and does the least random realistic and color tinting so what the artists wants they get, as well as options to disobey unity's light model if they feel evil!  

Today mainline UTS has moved forward to v2.0.5+ and this little side branch of mine was for v2.0.4+. It should be possible to swap other version of UTS2 with mine for a while. 

I will continue to use UTS as a playground to test out unique toon shading effects and improve the lighting model as i dig deeper into unity's includes and subsystems. I will likely keep my work to the hlsl frag/vert level and avoid GUI scripts, which means no fancy extra properties or unity GUI tabs. I will likely not overhaul unity's lighting system or parts that need C# or scripts because i tend to work in the confines of Vrchat.






# Install: 
Fresh user:
In github download the zip in the latest releases tab or from the branch you selected. In the archive file you will find the asset/ folder and Manual/ documentation, Copy the Toon/  folder into your unity assets project folder.  You should now have the UnityChainToonShader/ACiiL sub menu and my fork installed for use. I do not provide support of shaders outside the UnityChainToonShader/ACiiL shader submenu folder.

Past users of UTS-ac:
DO NOT override other UTS version or toon/ folder installs, purge them all if you do not use those. My folder is structured as Assets/Toon/Shader/ACiiL and the shader submenu is under UnityChainToonShader/ACiiL.
You may have to set the new stencil options to correct defaults. Set the zwrite on for solids.






# Features and some forks differences.
To help reduce confusion understanding UTS for beginners I will do my best to explain common confusion in this readme. The Entirety is documented in the manual which is linked and provided. This  exists to help paraphrase the massive details in the official UTS2 manual and what i know people have struggled with.



UTS has a number of effects, in some order:



* Face _CullMode, if faces render both/back/forward.



* Effects are prefaced with "LightColor" switches, this switches the light model from world color following on or presudo unlit light & shadow attenuate as color off.



* For alpha shaders, The alpha texture mask and settings
  * Set the albedo texture if it has the alpha channel and checkmark to use the albedo alpha. Otherwise use a custom grayscale texture that represents the alpha.



* The dynamic toon ramp system
  * Basic Shade assignment is done in two ways, you MUST assign your base textures in the 2-3 texture slots else you get solid color, define the albedo textures at: [_BaseMap,   1st_ShadeMap,   2nd_ShadeMap].
  * What makes UTS2 unique is the 3 layer toon ramp system based on: math ramps, painted albedo textures, and ambient occlusion textures.
  * UTS runs mix as:  (LightSide | (Tone1 | Tone3)), because of this you have many ways to set the 3 shades or abandon some.  Unlit setup is all white colors and same texture (uncheck receive shadows in mesh renderer too...). Easy toon setup is only LightSide & Tone1, were Tone2 is off with its step = 0. The advanced toon setup treats LightSide as a brighter "sunny side" color, Tone1 as a dimmer base color, and Tone2 as shadow color, to do that, match the steps at 0.5 and test you toon ramp as it receives shadow casts and look how it casts the toon.
  * UTS promotes manual albedo texture usage in shades to give you best creative control of shading, as to manually paint in the shadow tones as an artist. If you do not want to manual paint shades you will simply use the same albedo among the shadeColor slots and pick the shadow colors to mix.
  * The transition from light to the darker colors comes from the light direction on surfaces as dot() angles and when shadows are casting. Users manually adjust the "_step" to mark when surface angle shade begins. Blur the step with the "_feather".
  * The "ambient occlusion" slots, "Set_N_shadePosition", are used to empower the shade transition, the blackness multiplies the lambet of light to surface as set in the _step and _feature: Where white (1) does nothing, the blacker the faster the shade transitions to shade 1 or shade 2. These two textures guide how quickly and strongly the lerped tones translate. In effect enable dynamic toon ramp shifting by light sources and allows an artist to control areas where you do not want toon shading, such as painting the face area white and the body a gray area.  You will have to paint or bake the "ambient occlusion" textures yourself; I use Blender's AO bake system to do this. If your skin texture has gradients you can grayscale it and level it to white max.
  * For artistic and natural looking toon shading tones give it saturation and avoid gray tones. Tint the shadows in blue or red or a mix, and for light receiving side tint the effects towards yellow. When setting up UTS's shadow  albedo textures, instead of using a dark gray multiplier compliment it with a custom shadow albedo texture: copy and save your texture in photoshop or GIMP and increase the saturate about 5-15% and then set that onto the shade N textures. Its like a lazy and fast way to make shadows look more vibrant and in these ways you fake light "bouncing" and its good for skin shading.
  * There is a minimal shadow blackness setting to reduce shadow casts on the model. I recommend using this as a toggle if you find yourself incorrectly lit in some vrchat maps. You will disobey UNITYs light model with this slider and become partly unlit as sacrifice. Its better to go to a correctly lit map.

* My custom shadow cast and falloff system.
  * I have customized unity's shadow casts system to behave uniquely in this UTS2 fork. I have separated the "light attenuation" from the "shadow attenuation" and can mix and override dynamic lights with separate light falloff values and shadow darkness values. 
  * My goal is balances unity's shadow casts to they integrate into UTS's ramps and give the control to the artist; Well also allowing functional direct shadows casts, to make an avatar black when the world intends such black shadows such as a "space" setting.
    * Use the "Tweak_SystemShadowsLevel" slider to adjust shadow cast sensitivity to toon change. Hopefully one direction is sharper and other is softer. 
	  * New is this now smoothly remaps only shadow casts of any strength into using the dark toon ramp tones before true black shadows reach complete blackness.
  * Light falloff dimming is minimized to the limit of the light sphere, as to minimize toning toon colors. This is possible with my light attenuation refractor.
  * Shadow fridge falloff is remapped, as to "push" back the blackness and let the toon shading happen before the shadow casts goes completely black, and also minimizing toning toon colors.
  * Observe that add-pass shadows falloff in distance to light sources. Unfortunately this does for directional lights (infinite distance). This effect is possible with the light attenuation refractor.
  * If you are using my fork you are likely here for how i rebalance the direct and indirect lighting with these light attenuation overrides.
  * Expect improvements as i dig deeper into unity's light cast system and attempt to modernize shadow casting for toon effects.


*  highColor. The Toon shine effect.
  * This effect is how you enable light direction shine, to enable it, pick a color instead of black and raise the _HighColor_Power slider.
  * Mixing has two modes: replace or add. Either case you should assign your albedo texture and color, or a custom painted albedo that looks what you want the shine to be, eg) sharp shiny corners of robots, a custom color for shiny velvet cloths that tints in many ways.
  * I personally like to use highColor on the eyes to make them fake reflection of light. 
  * Can be use to counter black shadow casts on the model around the eyes (if in the eye whites are holes). Use a very "rough" highColor setup to counter shadows with shadow dimming off. 
  * HighColor has a setting to dim in shadow cast as well as the strength. This allows an ambient reflection or light penetration effect.
  * Use highColor for where you want to express shininess or metallic surfaces.
  * There is a mask texture for highColor.

* The RimLight. 
  * UTS rim setup is extensive and maybe overboard but unique to UTS2. When enabled you gain settings of strength, cutoff, intensity, if it's hard or soft, or the directionality to light sources. 
  * There is a anti rim light, Antipodean_RimLight, that works in opposite direction to rim. Use it to emulate light penetrating and moving under a surface or as artistic counter color to the main rim color. 
  * Use rims to make skin look alive or mask glossy ambient surfaces, or for a nice "inner outline" style. In vrchat odds are you will be noticed by your rims using this shader. Which is kinda silly.
  * There is a mask texture for rims.
  * There is my bugfix to limit backface rimlights from stacking both rim directions and glowing.



* Matcap. Assign the matcap and enable. Settings allow extensive control of light mixing and texture scale. 
  * Use matcap to fake effects like glossiness, metallics, refraction, etc.
  * If your are seeking effects for rimlight or shininess please use the above effects first for dynamic light reaction.
  * My fork adopts v2.0.5+ matcap with the camera pan correction.
  * Matcap is additive or multiply on source.
  * There is mask texture support.



* Emission.  Fairly standard, a mask and color pick.



* Outlines. In concept, outlines change thickness by distance to camera. You adjust the near and far range in object space (so it scales to the object size regardless of world space rescale)
  * to set static outline size, set min and max distance equal.
  * There are settings to manually give outlines custom albedo or rescale the thickness of outlines with a mask texture.
  * Outlines match the alpha of the albedo texture when shader is alpha type.
  * Z offset: offsets outliens by camera position, which outlines are pushed more back or forwards to counter outlines clipping with spikey geometry.
    * The bugfix in mirrors was found by me.
  * There is a minimal shadow blackness setting to remove shadow casts on the outlines.



* Stencil are all combine into a list. 
  * Default stencils in listing order: 0, 0, 255, 255; 0, 0 , 0 ,0; 1, 4, 15. In respective properties.
  * Zwrite off may give strange invisible appearance. Default on unless you want pass threw alphas.
  * These properties came from my shader friends samples and dramatically shrunk the shader files count!
  * To setup eyes passing over hair:
	Mark you eyes with:
			Stencil {
			Ref[_StencilNo]
			Comp Always
			Pass Replace
			Fail Replace
		}
	Mark your hair with:
			Stencil {
			Ref[_StencilNo]
			Comp NotEqual
			Pass Keep
			Fail Keep
		}







# Shader setup: 
UTS is a very technical and manual shader compared to other toon shaders. The freedom comes with the risk of needing to manually balance every color aspect in the settings and how easy to do it wrong by color balance.


Always read and follow the documentation for UTS found in this zip and read updated files and videos found at:

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project 


The latest mainline UTS2 release manual:

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project/blob/master/Manual/

Note my fork is different from the mainline readme version but the great effort of unity3d-jp is admirable and helps everyone.



# Shader file usage and render error avoidances.
Start by using the no-outlines version for best performance (outlines are extra passes. So i typically use it for non alpha or skin effects).
Your default shader is: ToonColor_DoubleShadeWithFeather.
Your clipping shader is: ToonColor_DoubleShadeWithFeather_ClippingCutout.
Your transparency goto is ToonColor_DoubleShadeWithFeather_TransClippingFade.shader
Real transparency with no shadows is ToonColor_DoubleShadeWithFeather_Transparent.shader
It should be obvious which is Clipping, Fade, and Transparency.

To setup alpha and clipping together, use TransClippingFade for transparency that needs shadows (Transparent never receives shadow casts). See the features guide above for settings.

Limitations of alpha. 
Note the recommended alpha shader ToonColor_DoubleShadeWithFeather_TransClippingFade.shader has its own issues by how its implemented and how limited unity is rendering transparency. In reality its alphaTest (clip) mode and misusing the alpha channel. You will have z sorting issues when this shader overlays other alphaTest shaders. The sorting issue cannot be differed by changing the render queue as that creates a inner-shader conflict when overlaying the same alphaTest shader many times, or depend on exclusive queue ordering with your friends alpha shaders. 

The true transparency shader will not have z sorting issues, but true transparency mode makes unity never pass receive shadow casts, thus UTS attempts to respect the unity lighting model for direct lights (shadow casting) is disobeyed. The compromise will make you want to set the shaders to unlit to be consistent.

I plan to implement dithered transparency which is a compromise between receiving shadows, alpha, and z sorting.


Color balances and bloom problems.
I recommend installing the unity post processing stack in your avatar scene with bloom on and track when bloom is too strong with a default directional light and with some extra default dynamic lights and/or baked lighting. Bloom happen when HRD color values goes higher than 1.1, and you should know many maps like to push lights above this value in vrchat!

UTS is sensitive to white albeto textures and maps that have strong direct and indirect colors. Counter the quick bloom out by using a gray base color, about 80% and lower the other color effects too. Anticipate whites in albedo will bloom before blacks, you may counter this with a inverted color gray mask that dim effects on the whites.

To control HDR and bloom, when picking each effects color in UTS, balance color illumination (V) when combining albedo, highColor, outlines, anti-outline, and additive matcap. Note that these effects stack and mix with: replace, add, or multiply and may push the final color into emission range. The future way to fix these effects and albeto sensitivity is rebuilding the effects with constrictive PBR math rules.


Outlines issues. Please default your outline color to mid gray and balance from there for contrast. Please Use outlines with Opaque mode only, outline ztest does not look right with transparent models.

If you come across very badly lit vrchat maps there are ways to adjest UTS-ac to compensate. Increase the min shadow caster blackness from 0 (which is natural) and maybe uncheck all the "lightColor" options which will make you unlit. Use this as a temperately fix so you can handle being in such bad lit map.




# Bugs:
Please send issue reports to my github page. I prefer to not get discord messages.

Some vrchat maps are setup incorrectly, in a perfect world they obey unity's light models, where direct lights (dynamics and shadows) are counter balanced by indirect lights (ambient) and reflection sources, and balance correct post processing of eye adaptation and bloom effects for HDR practices.

If you come across a map too bright or shadows too black, please contact the author and promptly yell until they fix it towards standard shader. Or if the author fails to learn, go the UTS-AC properties and use all the settings that make you unlit and reduce the blackness of shadows. The responsibly of map light balancing is not on me or other shader authors that know what they are doing.

Vrchat map authors must balance maps with the standard shader: Begin by using two standard shader objects and move them around the scene, inspect their direct and indirect lighting and shadow cast/receive onto each other and judge good ambience and reflections and if the post processing is causing bloom.

For maps where standard shader avatars looks fine and UTS does not i will be interested in debugging. Provide me with the map name and author to visit. Odds are the map is using: An unlit shader with a default directional light and shadow and an ambient blue, a point/spot light far in the distance as a sun cast, or setup eye-adaptation for common toon  shaders that clamp light intensity to (0,1) instead of full range (0, infinity).

Outlines have an outstanding shadow cast bug from the base-pass directional light which all shadows bleed behind the outlines, and correct for add-pass lights (spot/point/etc). Fixing this may require an entire rewrite of the pass-based outlines into geometry and i need to study geometry shaders for that. Basically special shadow caster depth data is needed for outlines which are further out than the base passes of the body, which seems direction lights fail to capture.






# Support credits to:
Noe, TCL, June, Cubed, Silent, RetroGeo, Xiexe, Mel0n, Cibbi, Hakanai, Neitri, 1001, Kaj, Error.mdl, more; and many misc shader posts among google/blogs/stack exchange/twitter/discords i cannot remember them all.






# Hosting site:

https://github.com/ACIIL/UnityChanToonShaderVer2_Project

A fork of:

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project






# License:
I inherent the Unity-Chan Toon Shader license. In addition if you use my fork, methods, or tips please credit towards my github and name; I really appreciate citation and i will do the same. Contact me by github or twitter if you want to sort out what of this branch is fully my work.

Unity-Chan Toon Shader 2.0 is provided under the Unity-Chan License 2.0 terms.  
Please refer to the following link for information regarding the Unity-Chan License.  
http://unity-chan.com/contents/guideline_en/


---------------------------------------------------------------

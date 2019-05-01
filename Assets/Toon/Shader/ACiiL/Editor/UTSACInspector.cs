using UnityEditor;
using UnityEngine;
using System;
using System.Reflection;
using System.Collections.Generic;


public class UTSACInspector : ShaderGUI {
	
	private static ulong headerExpansionStates;

	public override void OnGUI(MaterialEditor me, MaterialProperty[] props) {
		Type propHandlerType = Type.GetType(typeof(MaterialPropertyDrawer).AssemblyQualifiedName.Replace("Drawer", "Handler"));
		MethodInfo handlerGetter = propHandlerType.GetMethod("GetHandler", BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Static);
		FieldInfo decoratorsField = propHandlerType.GetField("m_DecoratorDrawers", BindingFlags.GetField | BindingFlags.Instance | BindingFlags.NonPublic);
		
		GUIStyle defaultStyle = EditorStyles.foldout;
		
		bool collapse = false;
		ulong rollingIn = headerExpansionStates;
		ulong rollingOut = 0;
		int categoryNumber = 0;
		
		foreach (MaterialProperty prop in props) {
			object handler = handlerGetter.Invoke(null, 0, null, new object[] {((Material)me.target).shader, prop.name}, null);
			if (handler != null) {
				List<MaterialPropertyDrawer> decoratorDrawers = (List<MaterialPropertyDrawer>) decoratorsField.GetValue(handler);
				if (decoratorDrawers != null) {
					foreach (MaterialPropertyDrawer d in decoratorDrawers) {
						if (d is MaterialCategoryDecorator) {
							string headerName = (d as MaterialCategoryDecorator).header;
							collapse = !EditorGUILayout.Foldout((rollingIn & 1) != 0, headerName, true, defaultStyle);
							rollingOut |= (collapse ? 0UL : 1UL) << categoryNumber;
							++categoryNumber;
							rollingIn >>= 1;
							Debug.Log(headerName);
						}
					}
					
				}
			}
			
			if (!collapse) me.ShaderProperty(prop, prop.displayName);
		}
		headerExpansionStates = rollingOut;
	}
	
	class MaterialCategoryDecorator : MaterialPropertyDrawer {
		public string header;
		
		public MaterialCategoryDecorator(string header) {
			this.header = header;
		}
		
		public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) { return 0; }
		public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor) {}
	}
}


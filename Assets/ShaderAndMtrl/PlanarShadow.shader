Shader "Custom/PlanarShadow" 
{

	Properties {
		_ShadowColor ("Shadow Color", Color) = (0,0,0,1)
		_PlaneHeight ("planeHeight", Float) = 0
	}

	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		// shadow color
		Pass {   
			
			ZWrite On
			ZTest LEqual 
			Blend SrcAlpha OneMinusSrcAlpha
			
			Stencil {
				Ref 0
				Comp Equal
				Pass IncrWrap
				ZFail Keep
			}

			CGPROGRAM
			#include "PlanarShadowBase.cginc"
			#pragma vertex vert
			#pragma fragment frag

			v2f vert( data v)
			{
				return vertPlanarShadow(v);
			}


			fixed4 frag( v2f i) : COLOR
			{
				return fragPlanarShadow(i);
			}

			ENDCG

		}
	}
}

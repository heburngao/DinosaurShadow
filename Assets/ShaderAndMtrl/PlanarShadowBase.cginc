// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#include "UnityCG.cginc"

// User-specified uniforms
uniform fixed4 _ShadowColor;
uniform fixed _PlaneHeight = 0;
struct data{
	fixed4 vertex : POSITION;

};
struct v2f
{
	fixed4 pos	: SV_POSITION;
};

v2f vertPlanarShadow( data v)
{
	v2f o;
         	            
	fixed4 wpos = mul( unity_ObjectToWorld, v.vertex);
	fixed4 L = -normalize(_WorldSpaceLightPos0); 

	fixed offsett = wpos.y - _PlaneHeight;
	fixed cosTheta = -L.y;	// = L dot (0,-1,0)
	fixed hypotenuse = offsett / cosTheta;
	fixed4 vPos = wpos.xyzw + (L *  hypotenuse );

	o.pos = mul (UNITY_MATRIX_VP, vPos);//fixed4(vPos.x,_PlaneHeight, vPos.z ,1));  
	// o.pos = mul (UNITY_MATRIX_VP,  fixed4(vPos.x,_PlaneHeight, vPos.z ,1));  
	return o;
}

fixed4 fragPlanarShadow( v2f i)
{
	return _ShadowColor;
}
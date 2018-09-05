// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SC/Character/GHB/BlinnPhong"
{
	Properties
	{
		_MTX("Main Tex",2D) = "white"{}
		_MaskTX("Mask Tex",2D) = "white"{}
		_TexFace("Tex Face",2D) = "white"{}
		_SpecularTX("Specular Tex",2D) = "white"{}
		_Bump("Bump",2D) = "bump"{}
		_Color("Color",Color)= (1,1,1,1)
		_SpecularPower("SpecularPower",range(0,1)) = .2
		_MaskPower("MaskPower",range(0,1)) = .1
		_RimPower("RimPower",range(0,1)) = .1
		_DiffPower("DiffPower",range(.8,1.2)) = 1
		_RimLightSampler("RimLightSampler",2D) = "white"{}
		_ColorfulPower("ColorfulPower",range(0,1)) = .1
		_FreArea("FreArea",range(0,3)) = 2
		_FreColor("FreColor",Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		cull back
		Pass
		{
		Tags{ "LightMode" = "ForwardBase" }
			zwrite on
			ztest lequal
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "GHB.cginc"
			#include "Lighting.cginc"
			#pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
			#pragma target 3.0

			sampler2D _MTX;  uniform fixed4 _MTX_ST;
			sampler2D _MaskTX;
			sampler2D _RimLightSampler;
			fixed4 _Color;
			sampler2D _TexFace;
			fixed4 _TexFace_ST;
			sampler2D _SpecularTX;
			fixed _SpecularPower;
			fixed _MaskPower;
			fixed _RimPower;
			fixed _DiffPower;
			fixed _ColorfulPower;
			//sampler2D _Bump;
			sampler2D _Bump;  uniform float4 _Bump_ST;

			fixed _FreArea;
			fixed4 _FreColor;
			struct data
			{
				fixed4 vertex : POSITION;
				fixed3 normal : NORMAL;
				fixed2 texcoord : TEXCOORD0;
				fixed2 texindex : TEXCOORD1;

				 fixed4 tangent : TANGENT;  
			};

			struct v2f
			{
				fixed4 vertex0 : SV_POSITION;
				fixed2 uv0 : TEXCOORD0;
				fixed3 worldpos0 : TEXCOORD1;
				fixed3 normal0 : TEXCOORD2;
				fixed texindex :TEXCOORD3;

				fixed3 tangent0  : TEXCOORD4;
				fixed3 binormal0 : TEXCOORD5; 
			};


			inline fixed3 GetNormalFromMap( v2f v )
			{
			 	
			 	 //or
			 	

				//fixed3 tangentNormal = normalize( tex2D( _Bump, v.uv0 ).xyz * 2.0 - 1.0 );
				//tangentNormal = v.tangent0 * tangentNormal.x + v.binormal0 * tangentNormal.y + v.normal0 * tangentNormal.z;//TBN

				fixed3 tangentNormal = (fixed3)0; 
				fixed4 nn = tex2D( _Bump, v.uv0.xy );
				//method 1: 可用
				//tangentNormal = UnpackNormalD(nn); 或//UnpackNormal(nn);
				//or
				//method 2: 可用
				 
				tangentNormal.xy =  nn.wy * 2 - 1;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				//method 1: 可用
				 fixed4 mtrx1 = fixed4(v.tangent0.x, v.binormal0.x, v.normal0.x, v.worldpos0.x) ;
			 	 fixed4 mtrx2 = fixed4(v.tangent0.y, v.binormal0.y, v.normal0.y, v.worldpos0.y);
			 	 fixed4 mtrx3 = fixed4(v.tangent0.z, v.binormal0.z, v.normal0.z, v.worldpos0.z) ;
				//tangentNormal = normalize(half3(dot(mtrx1.rgb , tangentNormal),dot(mtrx2.rgb , tangentNormal),dot(mtrx3.rgb , tangentNormal))); 
				//or 
				//method 2: 可用
				 fixed3x3 norMtx = fixed3x3 (v.tangent0.xyz,v.binormal0.xyz,v.normal0.xyz);//,v.worldpos0.xyz);
				//tangentNormal = mul(tangentNormal, norMtx); // 矩阵norMtx 在后
				//or
				//method 3: 可用
				tangentNormal = v.tangent0 * tangentNormal.x + v.binormal0 * tangentNormal.y + v.normal0 * tangentNormal.z;
				return tangentNormal;
			}

			v2f vert (data v)
			{
				v2f o;
				o.uv0 = v.texcoord.xy; 
				o.normal0 = mul((fixed3x3)unity_ObjectToWorld, v.normal);  
				o.worldpos0 = mul(unity_ObjectToWorld, v.vertex);
				o.vertex0 = UnityObjectToClipPos(v.vertex);
				o.texindex = v.texindex.x;

				o.tangent0 = UnityObjectToWorldDir(v.tangent.xyz);
				o.binormal0 = cross(v.normal , o.tangent0.xyz) * v.tangent.w;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed2 offsett = getBlink();
				fixed4 texColor =  tex2D(_MTX, TRANSFORM_TEX(i.uv0,_MTX)) ;//i.uv0); 

				if(i.texindex > 1.99 && i.texindex < 2.01)
				{
					texColor = tex2D(_TexFace, TRANSFORM_TEX(i.uv0.xy,_TexFace)+ offsett);
				}

				fixed4 maskColor = tex2D(_MaskTX,i.uv0.xy);
				fixed4 specularColor = tex2D( _SpecularTX,i.uv0.xy);
				fixed3 L =   _WorldSpaceLightPos0.xyz ; 
				fixed3 N =   normalize(GetNormalFromMap(i));//normalize(i.normal0) ;//
				fixed3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldpos0);
				fixed3 H = normalize(L + V);
				fixed NL = max(dot(N, L), 0); 
				fixed NV = saturate(dot(N,V)); 
				fixed NH = max(dot(N, H), 0); 
				fixed3 ambi = lerp(UNITY_LIGHTMODEL_AMBIENT.xyz , NL , 1);
				fixed falloffU = clamp( 1.0 - abs( NH ), 0.02, 0.98 );// NV　两边　 NH　侧边
				falloffU = tex2D( _RimLightSampler, fixed2( falloffU*1, 0.25f ) ).r;
				texColor.rgb += falloffU * texColor.rgb *.2 ;//
				fixed3 spec = specularColor.rgb   * pow( NH, 300 ) * _SpecularPower* saturate( maskColor.r*_MaskPower );
				fixed3 rim = (texColor.rgb * saturate(1-NH * _RimPower) * saturate(1- maskColor.r * _MaskPower) )* _Color.rgb;
				fixed3 diff = texColor.rgb*_DiffPower * NL * _LightColor0.rgb;// * pow(texColor.rgb,_ColorfulPower)  ;
				fixed3 fresnel = pow(1-NL,_FreArea)* _FreColor.rgb ;
				fixed3 Lo = (diff + rim + spec + ambi * diff )  + fresnel ;//diff  + rim + specular
				return fixed4(Lo , _Color.a); 
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}






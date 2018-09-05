// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SC/Character/GHB/BlinnPhong_Nor"
{
	Properties
	{
		_MTX("Main Tex",2D) = "white"{}
		_MaskTX("Mask Tex",2D) = "white"{}
		_Color("Color",Color)= (1,1,1,1)
		_Bump ("Bump", 2D) = "bump" {}
	 
		_SpecularPower("SpecularPower",range(0,1)) = .2
		_MaskPower("MaskPower",range(0,1)) = .1
		_RimPower("RimPower",range(0,1)) = .1
		_DiffPower("DiffPower",range(1,1.2)) = 1
		 _colorfulPower("colorfulPower",range(0,1)) = .1
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
		 	#include "Lighting.cginc"
			#pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
			#pragma target 3.0

			sampler2D _MTX;  uniform float4 _MTX_ST;
			sampler2D _MaskTX;
			float4 _Color;
			float _SpecularPower;
			float _MaskPower;
			float _RimPower;
			float _DiffPower;
			sampler2D _Bump;  uniform float4 _Bump_ST;
			float _colorfulPower;
			struct data
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				 fixed4 tangent : TANGENT;  
			};

			struct v2f
			{
				float4 vertex0 : SV_POSITION;
				fixed4 uv0 : TEXCOORD0;
				fixed3 normal0 : TEXCOORD1;
				fixed3 worldpos0 : TEXCOORD2;

				fixed3 tangent0  : TEXCOORD3;
				fixed3 binormal0 : TEXCOORD4; 
				 
			};

			//fixed3 _Light_Direction;
		 
			v2f vert (data v)
			{
				v2f o;
				//o.uv0.rg = v.texcoord.xy * _MTX_ST.xy + _MTX_ST.zw; 
				//o.uv0.ba = v.texcoord.xy * _Bump_ST.xy + _Bump_ST.zw; 

				o.uv0.rg = v.texcoord.xy;
				o.normal0 = UnityObjectToWorldNormal(v.normal); 
				fixed3 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.worldpos0 = wpos;
				o.vertex0 = UnityObjectToClipPos(v.vertex);

				o.tangent0 = UnityObjectToWorldDir(v.tangent.xyz);
				o.binormal0 = cross(v.normal , o.tangent0.xyz) * v.tangent.w;
				return o;
			}
			inline fixed3 UnpackNormalD (fixed4 packednormal)
			{
			    //fixed3 nor;
			    //nor.xy = packednormal.wy * 2 - 1;
			    //nor.z = sqrt(1 - saturate(dot(nor.xy, nor.xy)));
			    //return nor;
			    fixed3 aa ;
				aa.xy =  packednormal.wy * 2 - 1;
				aa.z = sqrt(1 - saturate(dot(aa.xy, aa.xy)));
				return aa;
			}
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
			fixed4 frag (v2f i) :  SV_Target
			{
				fixed4 texColor = tex2D(_MTX, TRANSFORM_TEX(i.uv0,_MTX)) ; 
				fixed4 maskColor = tex2D(_MaskTX,i.uv0.xy);
				fixed3 L =   _WorldSpaceLightPos0.xyz ; 
				fixed3 N =  normalize( GetNormalFromMap(i));
				fixed3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldpos0);
				fixed3 H = normalize(L + V);
				float NL = max(dot(N, L), 0); 

				float NH = max(dot(N, H), 0); 
				fixed3 ambi = lerp(UNITY_LIGHTMODEL_AMBIENT.xyz , texColor.rgb , .5);

				fixed3 diff = texColor.rgb*_DiffPower * NL * _LightColor0.rgb;//((NL * .5)+ .5) //lambert; //* pow(texColor.rgb,_colorfulPower)  ;
				fixed3 spec = _LightColor0.rgb * texColor.rgb  * pow( NH, 300 ) * _SpecularPower * saturate( maskColor.r*_MaskPower );
				fixed3 rim =  (texColor.rgb * saturate(1-NH * _RimPower) *  saturate(1- maskColor.r * _MaskPower) ) *_Color.rgb;
				fixed3 Lo = ambi*diff + diff * 2 + spec  + rim  ; 
				return float4(Lo , _Color.a); 
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}






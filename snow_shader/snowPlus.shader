Shader "Custom/test" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

		 _Bump ("Bump", 2D) = "bump" {}

		 //积雪相关
		 _Snow ("Snow Level",Range(0,1) ) = 0 //积雪的范围

		 //积雪的颜色
		 _SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)

		 //积雪的方向
		 _SnowDirection ("Snow Direction",Vector) = (0,1,0)

		 _SnowDepth ("Snow Depth",Range(0,0.3)) = 0.1

		 _Wetness ("Wetness",Range(0,0.5)) = 0.3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		sampler2D _Bump;

		float _Snow;
		float4 _SnowColor;
		float4 _SnowDirection;
		float _SnowDepth;
		float _Wetness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 worldNormal;
			INTERNAL_DATA

		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal (tex2D(_Bump, IN.uv_Bump));
			float difference = dot(WorldNormalVector(IN,o.Normal),_SnowDirection.xyz) - lerp(1,-1,_Snow);
			difference = saturate(difference / _Wetness);
			o.Albedo = difference * _SnowColor.rgb + (1 - difference) * c;
			o.Alpha = c.a;

		}

		void vert (inout appdata_full v) {
         //将_SnowDirection转化到模型的局部坐标系下
	      float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);
	 
	      if(dot(v.normal, sn.xyz) >= lerp(1,-1, (_Snow*2)/3))
	      {
	            v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
	      }
       }
		ENDCG
	}
	FallBack "Diffuse"
}

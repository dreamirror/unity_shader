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

		 _Outline ("Outline",Range(0,1)) = 0.4

		 _FogColor("Fog Color", Color) = (0.3, 0.4, 0.7, 1.0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert  finalcolor:mycolor vertex:vert 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		sampler2D _Bump;

		float _Snow;
		float4 _SnowColor;
		float4 _SnowDirection;
		float _SnowDepth;
		float _Wetness;
		float _Outline;
		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 worldNormal;
			float3 viewDir;
			half fog;
			INTERNAL_DATA

		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal (tex2D(_Bump, IN.uv_Bump));
			float difference = dot(WorldNormalVector(IN,o.Normal),_SnowDirection.xyz) - lerp(1,-1,_Snow);
			difference = saturate(difference / _Wetness);
			o.Albedo = difference * _SnowColor.rgb + (1 - difference) * c;

			half edge = saturate(dot(o.Normal,normalize(IN.viewDir)));
			edge = edge < _Outline ? edge/4 : 1;
			o.Albedo = o.Albedo * edge;
			o.Alpha = c.a;

		}

		void vert (inout appdata_full v, out Input data) {
         //将_SnowDirection转化到模型的局部坐标系下
	      float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);
	 
	      if(dot(v.normal, sn.xyz) >= lerp(1,-1, (_Snow*2)/3))
	      {
	            v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
	      }

		  UNITY_INITIALIZE_OUTPUT(Input, data);
		  float4 hpos = UnityObjectToClipPos(v.vertex);
		  hpos.xy /= hpos.w;
		  data.fog = min(1, dot(hpos.xy, hpos.xy)*0.5);//这个地方的点乘是为了将雾的浓度与模型到摄像机位置的x,y距离关联起来，乘以0.5是对这个浓度做的参数修正

       }
		fixed4 _FogColor;
		void mycolor(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			fixed3 fogColor = _FogColor.rgb;
			#ifdef UNITY_PASS_FORWARDADD
		    fogColor = 0;
			#endif
			color.rgb = lerp(color.rgb, fogColor, IN.fog);
		}

		ENDCG
	}
	FallBack "Diffuse"
}

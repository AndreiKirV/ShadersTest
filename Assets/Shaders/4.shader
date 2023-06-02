Shader "Temp/4"
{
   Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _WindStrength ("Wind Strength", Range(0, 1)) = 0.5
        _BendFactor ("Bend Factor", Range(0, 1)) = 0.5
    }
 
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Lambert
 
        sampler2D _MainTex;
        fixed4 _Color;
        float _WindStrength;
        float _BendFactor;
 
        struct Input {
            float2 uv_MainTex;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = float3(0, 1, 0);
            o.Specular = 0;
            o.Smoothness = 1;
            o.Emission = 0;
 
            // Имитация покачивания травы
            float bendAmount = sin(_BendFactor * IN.uv_MainTex.x + _WindStrength * _Time.y);
            o.Position += o.Normal * bendAmount;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

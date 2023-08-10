Shader "Custom/Water1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity ("Opacity", Range(0,1)) = 0.5
        _AnimSpeedX ("Anim Speed (X)", Range(0,4)) = 1.3
        _AnimSpeedY ("Anim Speed (Y)", Range(0,4)) = 2.7
        _AnimScale ("Anim Scale", Range(0,1)) = 0.03
        _AnimTiling ("Anim Tiling", Range(0,20)) = 8
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Space(25)]
        _MainTex2 ("Texture2", 2D) = "white" {}

        [Space(25)]

        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0 // Режим отсечения граней
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z-Test", Int) = 4 // Режим теста глубины
        [Enum(Off, 0, On, 1)] _ZWrite ("Z-Write", Int) = 0 // Запись глубины в буфер
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Cull [_Cull]
        ZTest [_ZTest]
        ZWrite[_ZWrite]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MainTex2;
            float4 _MainTex2_ST;
            float _Opacity;
            float _AnimSpeedX;
            float _AnimSpeedY;
            float _AnimScale;
            float _AnimTiling;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _MainTex2);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x += sin((i.uv.x + i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedX) * _AnimScale;
                i.uv.y += cos((i.uv.x - i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedY) * _AnimScale;
                i.uv2.x -= sin((i.uv.x + i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedX) * _AnimScale;
                i.uv2.y -= cos((i.uv.x - i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedY) * _AnimScale;
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_MainTex2, i.uv2);
                //col *= col2 *= _Color;
                col = lerp(col, col2, 0.5);
                col *= float4(_Color.rgb,1);
                col.a = _Opacity;
                return col;
            }
            ENDCG
        }
    }
}

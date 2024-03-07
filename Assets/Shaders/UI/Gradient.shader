Shader "Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "red" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Speed ("Speed",float) = 0
        _NoiseWidth ("Noise width delta", float) = 0
        _Pos ("Noise position", float) = 0
        [KeywordEnum(Vertical, Horizontal)] _Direction ("Direction", int) = 0
    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _DIRECTION_VERTICAL _DIRECTION_HORIZONTAL

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            float _NoiseWidth;
            float _Pos;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 tanCol = (0,0,0,0);
                #if _DIRECTION_VERTICAL
                tanCol = clamp(0, abs(tan(i.uv.y - (_Time.x * _Speed) + _Pos) + _NoiseWidth), 1);
                #elif _DIRECTION_HORIZONTAL
                tanCol = clamp(0, abs(tan(i.uv.x - (_Time.x * _Speed) + _Pos) + _NoiseWidth), 1);
                #endif

                tanCol *= _Color;
                
                fixed4 col = tex2D(_MainTex, i.uv) * tanCol;
                return col;
            }
            ENDCG
        }
    }
}
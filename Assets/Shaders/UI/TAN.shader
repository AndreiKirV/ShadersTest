Shader "Bible/TAN"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "red" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Sections ("Sections", Range(2, 99)) = 10
        _Speed ("Speed",float) = 0
        [KeywordEnum(Up, Down)] _Direction ("Direction", int) = 0
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
            #pragma multi_compile _DIRECTION_UP _DIRECTION_DOWN

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Sections;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float direction = 0;
                #if _DIRECTION_UP
                direction = 1;
                #elif _DIRECTION_DOWN
                direction = -1;
                #endif

                float4 tanCol = clamp(0, abs(tan((i.uv.y - tan(_Time.x * _Speed * direction)) * _Sections)), 1) ;
                tanCol *= _Color;

                fixed4 col = tex2D(_MainTex, i.uv) * tanCol;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
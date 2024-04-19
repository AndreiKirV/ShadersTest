Shader "BlurUiMoveThinWeight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset ("Offset", float) = 1.0
        _Limit("Limit", float) = 0.5
        _Speed("Speed", float) = 0.1
        _Weight("WeightNewTexture", float) = 1
        _DescendingScale("DescendingScale", float) = 1.08
        _Color ("Color", Color) = (0.16, 0.16, 0.16, 1)
        _GeneralColor ("GeneralColor", Color) = (0.16, 0.16, 0.16, 1)
        _PassCount("PassCount", int) = 1
        [KeywordEnum(Left, Right, Top, Bottom)] _Direction ("Direction", int) = 0

        //[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
        //[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

        /* [Space(50)]
        [Header(Standart)] */
        
        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask ("Color Mask", Float) = 15

        //[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnorePro_Offsetector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        LOD 100

        Cull Off
        Lighting Off
        ZWrite Off
        //ZTest [unity_GUIZTestMode]
        ZTest on
        Blend SrcAlpha OneMinusSrcAlpha//[_BlendSrc] [_BlendDst]
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _DIRECTION_LEFT _DIRECTION_RIGHT _DIRECTION_TOP _DIRECTION_BOTTOM

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            
            float _Offset;
            float _Limit;
            float _Speed;
            float _Weight;
            float4 _Color;
            float4 _GeneralColor;
            int _PassCount;
            float _DescendingScale;

                float _Pi;
                float _Directions;
                float _Size;

            float2 toCartesian(float2 polar)
            {
                float2 cartesian;
                sincos(polar.x * UNITY_TWO_PI, cartesian.y, cartesian.x);
                return cartesian * polar.y;
            }

            float2 toPolar(float2 cartesian)
            {
                float distance = length(cartesian);
                float angle = atan2(cartesian.y, cartesian.x);
                return float2(angle / UNITY_TWO_PI, distance);
            }

            float2 toMoveForAxis(float2 target)
            {
                target = target - 0.5;
                target = toPolar(target);
                target.x += _Time.y * _Speed; //движение по кругу
                target = toCartesian(target);
                target += 0.5;
                return target;
            }

            float2 WeightChange(float descendingScale, float x)
            {
                float targetWeight = exp(-(x * x) / (2 * descendingScale * descendingScale));
                float coefficient = 1 - (_PassCount - x) / _PassCount;
                targetWeight *= coefficient;
                return targetWeight;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                
                float limitOffset;

                float2 uv = input.uv;
                input.uv = toMoveForAxis(input.uv);
                float2 res = _MainTex_TexelSize.xy;
                
                float4 col = tex2D( _MainTex, input.uv);

                #if _DIRECTION_LEFT
                limitOffset = uv.x;
                #elif _DIRECTION_BOTTOM
                limitOffset = uv.y;
                #elif _DIRECTION_RIGHT
                limitOffset = 1.0 - uv.x;
                #elif _DIRECTION_TOP
                limitOffset = 1.0 - uv.y;
                #endif

                for (int i = 1; i <= _PassCount; i++)
                {
                    if(limitOffset < _Limit)
                    {
                        _Weight = _Weight * WeightChange(_DescendingScale, i);
                        col += tex2D(_MainTex, input.uv + float2(_Offset * i, _Offset * i) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(_Offset * i, -_Offset * i) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(-_Offset * i, _Offset * i) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(-_Offset * i, -_Offset * i) * res) * _Weight * i;
                        
                        col += tex2D(_MainTex, input.uv + float2(input.uv.x, _Offset * i) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(_Offset * i, input.uv.y) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(-_Offset * i, input.uv.y) * res) * _Weight * i;
                        col += tex2D(_MainTex, input.uv + float2(input.uv.x, -_Offset * i) * res) * _Weight * i;
                    }
                }

                if(limitOffset < _Limit)
                    col *= _Color;
                
                return col * _GeneralColor;
            }
            ENDCG
        }
    }
}
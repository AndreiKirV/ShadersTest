Shader "Bible/USB_simple_color"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

        [KeywordEnum(Off, Red, Blue)]
        _Options ("Color Options", Float) = 0

        [Enum(Off, 0, Front, 1, Back, 2)]
        _Face ("Face Culling", Float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("SrcFactor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("DstFactor", Float) = 1

        [Space(25)]
        [Header(No using)]
        [Space(25)]

        [Toggle] _Enable ("Enable ?", Float) = 0 // 0 и 1
        
        [PowerSlider(3.0)] _PowerSlider ("PowerSlider", Range (0.01, 1)) = 0.08
        [IntRange] _IntRange ("IntRange", Range (0, 255)) = 100
        
        _Reflection ("Reflection", Cube) = "black" {}
        _3DTexture ("3D Texture", 3D) = "white" {}

        _Specular ("Specular", Range(0.0, 1.1)) = 0.3
        _Factor ("Color Factor", float) = 0.3
        _Cid ("Color id", int) = 2

        _VPos ("Vertex Position", Vector) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        //AlphaToMask On
        //ColorMask RGB
        Blend [_SrcBlend] [_DstBlend] // для прозрачных объектов SrcAlpha OneMinusSrcAlpha
        
        //Tags {"RenderType"="Opaque"}
        /* • Opaque. Default.
        • Transparent.
        • TransparentCutout.
        • Background.
        • Overlay.
        • TreeOpaque.
        • TreeTransparentCutout.
        • TreeBillboard.
        • Grass.
        • GrassBillboard. */
        
        //Tags { "Queue"="Geometry" }
        LOD 100
        Cull [_Face]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog

            //#pragma shader_feature _ENABLE_ON //[Toggle] _Enable ("Enable ?", Float) = 0 не меняет состояния после компиляции
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE // несколько состояний [KeywordEnum(Off, Red, Blue)] _Options ("Color Options", Float) = 0 и сохраняет после компеляции варианты щейдера

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
            float _PowerSlider;
            int _IntRange;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //почему использует float4 _MainTex_ST?
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);

                #if _OPTIONS_OFF
                return col * _Color;
                #elif _OPTIONS_RED
                return col * float4(1, 0, 0, 1);
                #elif _OPTIONS_BLUE
                return col * float4(0, 0, 1, 1);
                #endif

                /* #if _ENABLE_ON
                #else
                return col;
                #endif */
            }

            ENDCG
        }
        /* Pass
        {
        } */
    }

    Fallback "Difuse"
}
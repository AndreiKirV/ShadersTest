Shader "Unlit/1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Top ("Top", float) = 0.5
        _Bottom ("Bottom", float) = -0.5

        _PlaneTex ("Plane Texture", 2D) = "white" {}
        _CircleCol ("Circle Color", Color) = (1, 1, 1, 1)
        _CircleRad ("Circle Radius", Range(0.0, 0.5)) = 0.45

        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0

        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float3 hitPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _PlaneTex;
            float4 _MainTex_ST;
            float _Top;
            float _Bottom;
            float4 _Color;
            float4 _CircleCol;
            float _CircleRad;

            float planeSDF(float3 ray_position)
            {
                float plane = ray_position.y - _Top;
                return plane;
            }

            #define MAX_MARCHIG_STEPS 50
            #define MAX_DISTANCE 10.0
            #define SURFACE_DISTANCE 0.001

            float sphereCasting(float3 ray_origin, float3 ray_direction)
            {
                float distance_origin = 0;

                for(int i = 0; i < MAX_MARCHIG_STEPS; i++)
                {
                    float3 ray_position = ray_origin + ray_direction * distance_origin;
                    float distance_scene = planeSDF(ray_position); 
                    distance_origin += distance_scene;

                    if(distance_scene < SURFACE_DISTANCE || distance_origin > MAX_MARCHIG_STEPS)
                    break;
                }

                return distance_origin;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hitPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i, bool face : SV_isFrontFace) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 ray_direction = normalize(i.hitPos - ray_origin);
                float t = sphereCasting(ray_origin, ray_direction);
                float4 planeCol = 0;
                float4 circleCol = 0;

                float3 p = ray_origin + ray_direction * t;
                float2 uv_p = p.xz;
                float l = pow(-abs(_Top), 2) + pow(-abs(_Top) - 1, 2);
                float c = length(uv_p);
                circleCol = (smoothstep(c - 0.01, c + 0.01, _CircleRad - abs(pow(_Top * 0.5, 2))));
                planeCol = tex2D(_PlaneTex, (uv_p * (1 - abs(pow(_Top * l, 2)))) - 0.5);
                planeCol *= circleCol;
                planeCol += (1 - circleCol) * _CircleCol;

                if(col.r == _Color.r && col.g == _Color.g && col.b == _Color.b)
                discard;

                if (i.hitPos.y < _Bottom)
                discard;
                else if (i.hitPos.y > _Top)
                discard;

                return face ? col : planeCol;
            }
            
            ENDCG
        }
    }
}
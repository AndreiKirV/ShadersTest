Shader "Custom/Water 2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex2 ("Texture2", 2D) = "white" {}
        _Speed ("SpeedTime", float) = 1
        DRAG_MULT ("DRAG_MULT", float) = 0.28
        ITERATIONS_RAYMARCH ("ITERATIONS_RAYMARCH", float) = 12
        ITERATIONS_NORMAL("ITERATIONS_NORMAL", float) = 40
        _AnimScale ("Anim Scale", Range(0,1)) = 0.03
        _AnimTiling ("Anim Tiling", Range(0,20)) = 8
        _Opacity ("Opacity", Range(0,1)) = 0.5
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define vec2 float2
            #define vec3 float3

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
            float DRAG_MULT;
            float ITERATIONS_RAYMARCH;
            float ITERATIONS_NORMAL;
            float _Speed;
            float _AnimScale;
            float _AnimTiling;
            float _Opacity;
            float4 _Color;

            vec2 wavedx(vec2 position, vec2 direction, float frequency, float timeshift) 
            {
                float x = dot(direction, position) * frequency + timeshift;
                float wave = exp(sin(x) - 1.0);
                float dx = wave * cos(x);
                return vec2(wave, -dx);
            }

            float getwaves(vec2 position, int iterations) 
            {
                float iter = 0.0; // this will help generating well distributed wave directions
                float frequency = 1.0; // frequency of the wave, this will change every iteration
                float timeMultiplier = 2.0; // time multiplier for the wave, this will change every iteration
                float weight = 1.0;// weight in final sum for the wave, this will change every iteration
                float sumOfValues = 0.0; // will store final sum of values
                float sumOfWeights = 0.0; // will store final sum of weights

                for(int i=0; i < iterations; i++) 
                {
                    // generate some wave direction that looks kind of random
                    vec2 p = vec2(sin(iter), cos(iter));
                    // calculate wave data
                    vec2 res = wavedx(position, p, frequency, _Time.y * _Speed * timeMultiplier);

                    // shift position around according to wave drag and derivative of the wave
                    position += p * res.y * weight * DRAG_MULT;

                    // add the results to sums
                    sumOfValues += res.x * weight;
                    sumOfWeights += weight;

                    // modify next octave parameters
                    weight *= 0.82;
                    frequency *= 1.18;
                    timeMultiplier *= 1.07;

                    // add some kind of random value to make next wave look random too
                    iter += 1232.399963;
                }

                return sumOfValues / sumOfWeights;
            }

            vec3 normal(vec2 pos, float e, float depth) 
            {
                vec2 ex = vec2(e, 0);
                float H = getwaves(pos.xy, ITERATIONS_NORMAL) * depth;
                vec3 a = vec3(pos.x, H, pos.y);

                return normalize(
                    cross(
                    a - vec3(pos.x - e, getwaves(pos.xy - ex.xy, ITERATIONS_NORMAL) * depth, pos.y), 
                    a - vec3(pos.x, getwaves(pos.xy + ex.yx, ITERATIONS_NORMAL) * depth, pos.y + e)
                    )
                );
            }

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
                //i.uv.x += float4(normal(vec2(1,1), 1, 1), 1).x;
                //i.uv.y += float4(normal(vec2(1,1), 1, 1), 1).z;

                i.uv.x += sin((float4(normal(i.uv, 1, 1), 1).x + i.uv.y) * _AnimTiling + _Time.y * 1.3) * _AnimScale;
                i.uv.y += cos((float4(normal(i.uv, 1, 1), 1).y - i.uv.y) * _AnimTiling + _Time.y * 2.7) * _AnimScale;
                
                i.uv2.x -= cos((float4(normal(i.uv, 1, 1), 1).x + i.uv.y) * _AnimTiling + _Time.y * 2.7) * _AnimScale;
                i.uv2.y -= sin((float4(normal(i.uv, 1, 1), 1).z - i.uv.y) * _AnimTiling + _Time.y * 1.3) * _AnimScale;

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_MainTex2, i.uv2);
                col = lerp(col, col2, 0.5);
                col *= float4(_Color.rgb,1);
                col.a = _Opacity;
                return col;
            }
            ENDCG
        }
    }
}

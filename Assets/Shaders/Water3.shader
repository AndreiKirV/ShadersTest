Shader "Custom/GreatWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _FoamColor("Foam Color", Color) = (1,1,1,1)
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        _FoamMaxDistance("Foam Maximum Distance", Float) = 0.4
        _FoamMinDistance("Foam Minimum Distance", Float) = 0.04

        [Space(15)]
        [Header(Contrast noise)]
        [Space(15)]
        [KeywordEnum(Off, On)] _Contrast ("Contrast", Float) = 0
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.5
        _FoamSmoothing ("FoamSmoothing", Range(0, 0.5)) = 0.05

        [Space(15)]
        [Header(Animation)]
        [Space(15)]

        _Speed ("SpeedTime", float) = 1
        _DragMult ("DragMult", float) = 0.28
        _IterationsNormal("IterationsNormal", float) = 40
        _AnimTiling ("Anim Tiling", Range(0,20)) = 8
        _AnimScale ("Anim Scale", Range(0,1)) = 0.03
        _AnimSpeedX ("Anim Wave Speed (X)", Range(0,4)) = 1.3
        _AnimSpeedY ("Anim Wave Speed (Y)", Range(0,4)) = 2.7

        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
        

        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _CONTRAST_OFF _CONTRAST_ON

            #include "UnityCG.cginc"

            float4 alphaBlend(float4 top, float4 bottom)
            {
                float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
                float alpha = top.a + bottom.a * (1 - top.a);

                return float4(color, alpha);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
                float2 noiseUV : TEXCOORD3;
                float3 viewNormal : NORMAL;
                float2 distortUV : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;

            float4 _FoamColor;
            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;

            float _SurfaceNoiseCutoff;
            float _FoamMaxDistance;
            float _FoamMinDistance;

            float _FoamSmoothing;

            float _Speed;
            float _DragMult;
            float _IterationsNormal;
            float _AnimTiling;
            float _AnimScale;
            float _AnimSpeedX;
            float _AnimSpeedY;
            float2 _SurfaceNoiseScroll;

            sampler2D _CameraDepthTexture;
            sampler2D _CameraNormalsTexture;

            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            float _SurfaceDistortionAmount;

            float2 wavedx(float2 position, float2 direction, float frequency, float timeshift) 
            {
                float x = dot(direction, position) * frequency + timeshift;
                float wave = exp(sin(x) - 1.0);
                float dx = wave * cos(x);
                return float2(wave, -dx);
            }

            float getwaves(float2 position, int iterations) 
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
                    float2 p = float2(sin(iter), cos(iter));
                    // calculate wave data
                    float2 res = wavedx(position, p, frequency, _Time.y * _Speed * timeMultiplier);

                    // shift position around according to wave drag and derivative of the wave
                    position += p * res.y * weight * _DragMult;

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

            float3 normal(float2 pos, float e, float depth) 
            {
                float2 ex = float2(e, 0);
                float H = getwaves(pos.xy, _IterationsNormal) * depth;
                float3 a = float3(pos.x, H, pos.y);

                return normalize(
                    cross(
                    a - float3(pos.x - e, getwaves(pos.xy - ex.xy, _IterationsNormal) * depth, pos.y), 
                    a - float3(pos.x, getwaves(pos.xy + ex.yx, _IterationsNormal) * depth, pos.y + e)
                    )
                );
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.viewNormal = COMPUTE_VIEW_NORMAL;
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x += sin((float4(normal(i.uv, 1, 1), 1).x + i.uv.y) * _AnimTiling + _Time.y) * _AnimScale * _AnimSpeedX;
                i.uv.y += cos((float4(normal(i.uv, 1, 1), 1).y - i.uv.y) * _AnimTiling + _Time.y) * _AnimScale * _AnimSpeedY;

                i.noiseUV.x += sin((float4(normal(i.uv, 1, 1), 1).x + i.uv.y) * _AnimTiling + _Time.y) * _AnimScale * _AnimSpeedX;
                i.noiseUV.y += cos((float4(normal(i.uv, 1, 1), 1).y - i.uv.y) * _AnimTiling + _Time.y) * _AnimScale * _AnimSpeedY;

                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;

                float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
                float2 waterUV = float2(i.uv.x + _Time.y * _SurfaceNoiseScroll.x, i.uv.y + _Time.y * _SurfaceNoiseScroll.y);

                fixed4 col = tex2D(_MainTex, waterUV);
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPosition.w;
                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;

                float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
                float3 normalDot = saturate(dot(existingNormal, i.viewNormal));

                float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
                float foamDepthDifference01 = saturate(depthDifference / foamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

                
                #if _CONTRAST_ON
                float surfaceNoise = smoothstep(surfaceNoiseCutoff - _FoamSmoothing, surfaceNoiseCutoff + _FoamSmoothing, surfaceNoiseSample);
                #else 
                float surfaceNoise = -surfaceNoiseCutoff * surfaceNoiseSample;
                #endif
                
                float4 surfaceNoiseColor = _FoamColor;
                surfaceNoiseColor.a *= surfaceNoise;

                return  alphaBlend(surfaceNoiseColor, col * waterColor);
            }

            ENDCG
        }
    }
}
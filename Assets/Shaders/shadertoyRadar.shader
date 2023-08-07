Shader "shadertoy/shadertoyRadar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _Length ("Length", float) = 0
        _ITime ("ITime", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define vec2 float2
            #define vec3 float3
            #define mod fmod
            #define SMOOTH(r,R) (1.0-smoothstep(R-1.0,R+1.0, r))
            #define RANGE(a,b,x) ( step(a,x)*(1.0-step(b,x)) )
            #define RS(a,b,x) ( smoothstep(a-1.0,a+1.0,x)*(1.0-smoothstep(b-1.0,b+1.0,x)) )
            #define M_PI 3.1415926535897932384626433832795

            #define blue1 vec3(0.78,0.95,1.00)
            #define blue2 vec3(0.87,0.98,1.00)
            #define blue3 vec3(0.35,0.76,0.83)
            #define blue4 vec3(0.953,0.969,0.89)
            #define red   vec3(1.00,0.38,0.227)

            #define MOV(a,b,c,d,t) (vec2(a*cos(t)+b*cos(0.1*(t)), c*sin(t)+d*cos(0.1*(t))))
            
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
            float _Length;
            float _ITime;

            float movingLine(vec2 uv, vec2 center, float radius)
            {
                //angle of the line
                float theta0 = _ITime;
                vec2 d = uv - center;
                float r = sqrt( dot( d, d ) );
                if(r < radius)
                {
                    //compute the distance to the line theta=theta0
                    vec2 p = radius*vec2(cos(theta0*M_PI/180.0),
                                        -sin(theta0*M_PI/180.0));
                    float l = length( d - p * clamp( dot(d,p)/dot(p,p), 0.0, 1.0) );
                    d = normalize(d);
                    //compute gradient based on angle difference to theta0
                    float theta = mod(180.0 * atan2(d.y,d.x) / M_PI + theta0,360.0);
                    float gradient = clamp(1.0-theta/90.0,0.0,1.0);
                    return SMOOTH(l,1.0) + 0.5 * gradient;
                }
                else return tex2D(_MainTex, uv);
            }



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                col *= float4(movingLine(i.uv, 0.5, _Length).xxx /* blue3*/, 0);
                return col;
            }
            ENDCG
        }
    }
}

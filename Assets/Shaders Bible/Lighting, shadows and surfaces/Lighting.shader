Shader "Bible/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "red" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            void unity_light (in float3 normals, out float3 Out)
            {
                Out = /* [Op] */ (normals);
            }

            half3 normalWorld (half3 normal)
            {
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = normalWorld(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                /* fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col; */
                half3 normals = i.normal;
                half3 light = 0;
                unity_light(normals, light);
                return float4(light.rgb, 1);
            }
            ENDCG
        }
    }
}

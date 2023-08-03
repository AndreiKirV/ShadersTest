Shader "Bible/normal_map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "red" {}
        _Ambient ("Ambient Color", Range(0, 1)) = 1
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv_normal : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_INITIALIZE_OUTPUT (v2f, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject));
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);

                return o;
            }

            float3 DXTCompression (float4 normalMap)
            {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalCol;
                    normalCol = float3 (normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0);
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2)));
                    return normalCol;
                #endif
            }

            fixed4 frag (v2f i) : SV_Target
            {
                /* fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                fixed3 normal_compressed = DXTCompression(normal_map); //UnpackNormal()
                
                float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world.xyz,
                    i.binormal_world,
                    i.normal_world
                );

                fixed3 normal_color = normalize(mul(normal_compressed, TBN_matrix)); */

                fixed4 col = tex2D(_MainTex, i.uv);
                float3 ambient_color = UNITY_LIGHTMODEL_AMBIENT * _Ambient;
                col.rgb += ambient_color;
                
                return col;//fixed4 (normal_color, 1);
            }
            ENDCG
        }
    }
}

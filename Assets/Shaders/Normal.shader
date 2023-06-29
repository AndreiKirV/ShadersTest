Shader "RotateNormalMap" {
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RotationSpeed ("Rotation Speed", Range(0, 10)) = 1
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
        Cull Back
        Lighting On
        ZWrite On
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            sampler2D _NormalMap;
            float _RotationSpeed;
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldNormal : TEXCOORD1;
            };
            
            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = normalize(float3(v.vertex.xyz));
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal).xyz);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                float2 rotatedUV = i.uv;
                float angle = _Time.y * _RotationSpeed;
                float sinAngle = sin(angle);
                float cosAngle = cos(angle);
                float2x2 rotationMatrix = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                rotatedUV = mul(rotationMatrix, rotatedUV);
                
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, rotatedUV)) * 2.0 - 1.0;
                normal = normalize(normal);
                
                fixed3 worldNormal = normalize(i.worldNormal);
                float2 rotatedWorldNormal = mul(rotationMatrix, worldNormal.xy);
                
                fixed3 finalNormal = normalize(normal + float3(rotatedWorldNormal, 0));
                fixed3 finalColor = tex2D(_MainTex, i.uv).rgb;
                
                fixed3 lightDir = normalize(float3(0, 0.5, -1));
                fixed3 diffuse = max(dot(finalNormal, lightDir), 0) * finalColor;
                fixed3 ambient = 0.2 * finalColor;
                fixed3 result = diffuse + ambient;
                
                return fixed4(result, 1);
            }
            
            ENDCG
        }
    }
}
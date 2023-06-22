Shader "TestTes"
{
     Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert

        // Включение поддержки теселяции
        #pragma target 4.6
        #pragma require tessellation

        sampler2D _MainTex;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv_MainTex : TEXCOORD0;
        };

        struct Output
        {
            float3 Albedo : COLOR0;
            float3 Normal : NORMAL;
            float2 uv_MainTex : TEXCOORD0;
        };

        // Расчет вершин тесселяции
        [OutputTopology("triangle_cw")]
        [PatchConstantFunc("CalcTessellationFactors")]
        Output tessFunc(InputPatch<appdata, 3> patch, uint pointId : SV_OutputControlPointID)
        {
            Output output;

            // Получение исходных вершин треугольника
            float3 v0 = patch[0].vertex.xyz;
            float3 v1 = patch[1].vertex.xyz;
            float3 v2 = patch[2].vertex.xyz;

            // Расчет новых вершин тесселяции
            float3 center = (v0 + v1 + v2) / 3.0f;
            float3 normal = normalize(cross(v1 - v0, v2 - v0));

            // Задание позиций и нормалей новых вершин
            output.vertex.xyz = center + normal;
            output.Albedo = patch[pointId].uv_MainTex;
            output.Normal = float3(0, 0, 1); // Нормальная к поверхности

            // Задание текстурных координат новых вершин (может потребоваться дополнительная логика для правильного сопоставления текстурных координат)
            output.uv_MainTex = patch[pointId].uv_MainTex;

            return output;
        }

        // Расчет коэффициентов тесселяции
        void CalcTessellationFactors(InputPatch<appdata, 3> patch, uint pointId : SV_OutputControlPointID, out float edges[3] : SV_TessFactor, out float inside : SV_InsideTessFactor)
        {
            edges[0] = 1.0;
            edges[1] = 1.0;
            edges[2] = 1.0;
            inside = 1.0;
        }

        // Код для определения цвета и освещения поверхности
        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            o.Normal = float3(0, 0, 1); // Нормальная к поверхности
        }

        ENDCG
    }
    FallBack "Diffuse"
}

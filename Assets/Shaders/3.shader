Shader "Temp/3"
{
   Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.1
        _DistortionSpeed ("Distortion Speed", Range(0, 1)) = 0.5
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.02
        _WaveSpeed ("Wave Speed", Range(0, 10)) = 1.0
        _WaveFrequency ("Wave Frequency", Range(0, 10)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        #pragma surface surf Lambert alpha

        // Properties
        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        float _DistortionStrength;
        float _DistortionSpeed;
        fixed4 _OutlineColor;
        float _OutlineWidth;
        float _WaveSpeed;
        float _WaveFrequency;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Получаем искажение для текстуры воды
            float2 distortion = tex2D(_NormalMap, IN.uv_NormalMap + _Time.xy * _DistortionSpeed).rg * 2.0f - 1.0f;
            distortion *= _DistortionStrength;

            // Устанавливаем цвет
            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;

            // Применяем искажение к текстурным координатам
            IN.uv_MainTex += distortion;

            // Определяем расстояние от текущей позиции до центра
            float distance = length(IN.uv_MainTex - 0.5f);

            // Если расстояние меньше ширины обводки, устанавливаем alpha-канал в 0 для создания обводки
            if (distance < _OutlineWidth)
            {
                o.Alpha = 0.0;
                o.Specular = _OutlineColor.rgb;
                o.Emission = _OutlineColor.rgb;
            }

            // Применяем волновой эффект
            float waveFactor = sin(_Time.y * _WaveSpeed + distance * _WaveFrequency);
            IN.uv_MainTex.y += waveFactor * 0.1;

            // Повышаем яркость вершин, чтобы создать эффект блеска на волнующейся воде
            o.Specular += waveFactor * 0.2;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

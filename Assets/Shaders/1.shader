Shader "Temp/1"
{
     Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _GrassDensity ("Grass Density", Range(1, 10)) = 5
        _GrassHeight ("Grass Height", float) = 0.5
        _BendFactor ("Bend Factor", Range(0, 1)) = 0.5
        _WindSpeed ("Wind Speed", Range(0, 1)) = 0.5
        _WaveFrequency ("Wave Frequency", Range(0, 10)) = 2
        _WaveAmplitude ("Wave Amplitude", Range(0, 1)) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert fullforwardshadows

        // Свойства шейдера
        fixed4 _Color;
        float _GrassDensity;
        float _GrassHeight;
        float _BendFactor;
        float _WindSpeed;
        float _WaveFrequency;
        float _WaveAmplitude;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // Вычисляем высоту травинок на основе настроек
            float grassHeight = _GrassHeight * _GrassDensity;

            // Проверяем, что вершина находится в верхней части объекта
            if (v.vertex.y > grassHeight)
            {
                // Вычисляем смещение для изгибания травы
                float bendOffset = sin(v.vertex.y * _GrassDensity) * _BendFactor;

                // Изгибаем верхнюю часть объекта
                v.vertex.y += grassHeight * bendOffset;

                // Вычисляем покачивание травы на основе времени и позиции
                float waveOffset = sin(_WaveFrequency * _Time.y + v.vertex.x * _WaveFrequency) * _WaveAmplitude;

                // Добавляем покачивание к верхним вершинам
                v.vertex.y += grassHeight * waveOffset;
            }

            // Передаем мировые координаты для использования в шейдере поверхности
            o.worldPos = v.vertex.xyz;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Устанавливаем цвет
            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

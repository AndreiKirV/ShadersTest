Shader "Temp/2"
{
   Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _FurLength ("Fur Length", Range(0, 1)) = 0.5
        _FurDensity ("Fur Density", Range(0, 1)) = 0.5
        _FurNoiseScale ("Fur Noise Scale", Range(0, 1)) = 0.1
        _FurWaveSpeed ("Fur Wave Speed", Range(0, 1)) = 0.5
        _FurWaveStrength ("Fur Wave Strength", Range(0, 1)) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert fullforwardshadows

        // Свойства шейдера
        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        float _FurLength;
        float _FurDensity;
        float _FurNoiseScale;
        float _FurWaveSpeed;
        float _FurWaveStrength;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // Передаем текстурные координаты для использования в шейдере поверхности
            o.uv_MainTex = v.texcoord;
            o.uv_NormalMap = v.texcoord;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Вычисляем шумовое значение для создания текстуры шерсти
            float furNoise = tex2D(_MainTex, IN.uv_MainTex * _FurNoiseScale).r;

            // Вычисляем смещение для создания покачивания шерсти
            float furWaveOffset = sin(_Time.y * _FurWaveSpeed) * _FurWaveStrength;

            // Вычисляем длину шерсти
            float furLength = _FurLength * furNoise;

            // Вычисляем плотность шерсти
            float furDensity = _FurDensity * furNoise;

            // Устанавливаем цвет
            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;

            // Применяем текстуру нормалей для создания рельефности шерсти
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));

            // Применяем смещение для покачивания шерсти
            o.Normal.xy += furWaveOffset;

            // Применяем длину и плотность шерсти к alpha-каналу
            o.Alpha *= furLength * furDensity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

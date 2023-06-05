Shader "Temp/4"
{
   Properties 
   {
        _Color ("Color", Color) = (1, 1, 1, 1)  // Параметр для цвета
        _MainTex ("Texture", 2D) = "white" {}   // Параметр для текстуры
    }

    SubShader 
    {
        
        Tags { "RenderType"="Transporent" }  // Тэги для отображения шейдера
        LOD 3  // Уровень детализации
        
        CGPROGRAM  // Начало кода HLSL

        #pragma surface surf Lambert  // Используем модель освещения Lambert
        
        struct Input 
        {
            float2 uv_MainTex;  // Входные данные для текстурных координат
        };
        
        sampler2D _MainTex;  // Текстурный сэмплер
        fixed4 _Color;       // Цветовая переменная для передачи из материала
        
        void surf (Input IN, inout SurfaceOutput o) 
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;  // Получаем цвет из текстуры и умножаем на цвет из параметра
            o.Albedo = c.rgb;  // Задаем цвет поверхности
            o.Alpha = c.a;     // Задаем альфа-канал поверхности
        }

        ENDCG  // Конец кода HLSL
    }

    FallBack "Diffuse"  // Запасной вариант, если шейдер не поддерживается
}

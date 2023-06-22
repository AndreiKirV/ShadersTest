Shader "Tutorial" //путь и имя для инспектора
{
    // Определение свойств шейдера
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1) //цвет
        _MainTex ("Texture", 2D) = "white" // Основная текстура
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5 // Режим смешивания исходного цвета
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10 // Режим смешивания целевого цвета
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0 // Режим отсечения граней
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z-Test", Int) = 4 // Режим теста глубины
        [Enum(Off, 0, On, 1)] _ZWrite ("Z-Write", Int) = 0 // Запись глубины в буфер
        _ColorMask ("out Color Mask", Int) = 15 // Маска цветового канала
    }
    // Подшейдер
    SubShader
    {
        // Тэги шейдера
        Tags { "Queue"="Transparent" "RenderType"="Fade" "LightMode"="ForwardBase" }// Теги субшейдера

        LOD 100 // Уровень детализации

        // Настройки рендеринга
        Blend [_BlendSrc] [_BlendDst] // Установка режима смешивания цветов
        Cull [_Cull] // Установка режима отсечения граней
        ZTest [_ZTest] // Установка режима теста глубины
        ZWrite[_ZWrite] // Установка режима записи глубины
        ColorMask [_ColorMask] // Установка маски цветового канала

        LOD 100 // Уровень детализации
        lighting on // Отключение освещения

        // Проход
        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Задание функции вершинного шейдера
            #pragma fragment frag // Задание функции фрагментного шейдера
            #pragma multi_compile_fog // Включение поддержки тумана
            #pragma multi_compile_shadowcaster//директива препроцессора в шейдерах Unity, которая указывает компилятору шейдера на необходимость генерации вариантов шейдера для прохождения теней.

            #include "UnityCG.cginc" // Включение стандартных функций и структур для работы с Unity

            // Структура для вершинного шейдера
            struct appdata
            {
                float4 vertex : POSITION; // Позиция вершины
                float2 uv : TEXCOORD0; // Координаты текстуры
            };

            // Структура для передачи данных во фрагментный шейдер
            struct v2f
            {
                float2 uv : TEXCOORD0; // Координаты текстуры для передачи во фрагментный шейдер
                UNITY_FOG_COORDS(1) // Координаты для работы с туманом
                float4 vertex : SV_POSITION; // Позиция вершины для вывода
            };

            sampler2D _MainTex; // Сэмплер для основной текстуры
            float4 _MainTex_ST; // Матрица трансформации текстуры
            float4 _Color; //объявление цвета из свойств

            //теселяционный - изменение, добавление вершин и всякой срани
            
            // Функция вершинного шейдера
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Преобразование позиции вершины в пространство отсечения
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Преобразование координат текстуры
                UNITY_TRANSFER_FOG(o, o.vertex); // Передача координат тумана
                return o;
            }

            // Функция фрагментного шейдера
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color; // Получение цвета из основной текстуры и его изменение с помощью _Color
                UNITY_APPLY_FOG(i.fogCoord, col); // Применение тумана
                return col;
            }
            
            ENDCG // Конец CGPROGRAM
        }
    }
    
    FallBack "Diffuse" //запасный шейдер
}
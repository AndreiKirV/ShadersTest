Shader "Tutorial" //путь и имя для инспектора
{
    // Определение свойств шейдера
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1) //цвет
        _MainTex ("Texture", 2D) = "white" {}// Основная текстура
        _FrontTexture ("FrontTexture", 2D) = "black" {}
        _BackTexture ("BackTexture", 2D) = "red" {}

        [KeywordEnum(Off, Red, Blue, On)]
        _Options ("Color Options", Float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5 // Режим смешивания исходного цвета
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10 // Режим смешивания целевого цвета
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0 // Режим отсечения граней
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z-Test", Int) = 4 // Режим теста глубины
        [Enum(Off, 0, On, 1)] _ZWrite ("Z-Write", Int) = 0 // Запись глубины в буфер
        _ColorMask ("out Color Mask", Int) = 15 // Маска цветового канала
        //[Int] _LOD ("Lod", Int) = 100

        [Space(25)]
        [Header(No using)]
        [Space(25)]

        [Toggle] _Enable ("Enable ?", Float) = 0 // 0 и 1

        [PowerSlider(3.0)] _PowerSlider ("PowerSlider", Range (0.01, 1)) = 0.08
        [IntRange] _IntRange ("IntRange", Range (0, 255)) = 100
        
        _Reflection ("Reflection", Cube) = "black" {}
        _3DTexture ("3D Texture", 3D) = "white" {}

        _Specular ("Specular", Range(0.0, 1.1)) = 0.3
        _Factor ("Color Factor", Float) = 0.3
        _Cid ("Color id", Int) = 2

        _VPos ("Vertex Position", Vector) = (0, 0, 0, 1)
    }
    // Подшейдер
    SubShader
    {
        // Тэги шейдера
        //Tags { "Queue"="Transparent" "RenderType"="Fade" "LightMode"="ForwardBase" }// Теги субшейдера // для поддержки urp - "RenderPipeline"="UniversalRenderPipeline" надо приводить к HLSLPROGRAM ENDHLSL

        Tags {"RenderType"="Opaque"}
        /* 
        • Opaque. Default.
        • Transparent.
        • TransparentCutout.
        • Background.
        • Overlay.
        • TreeOpaque.
        • TreeTransparentCutout.
        • TreeBillboard.
        • Grass.
        • GrassBillboard. */

        LOD 100 // Уровень детализации

        // Настройки рендеринга
        Blend [_BlendSrc] [_BlendDst] // Установка режима смешивания цветов 
        /*
        B = SrcFactor * SrcValue [OP] DstFactor * DstValue
        «SrcValue» (исходное значение), обработанное на этапе фрагментного шейдера, соответствует цветовому выходу пикселя в формате RGB.
        "DstValue" (целевое значение) соответствует цвету RGB, который был записан в "целевой буфер", более известный как "мишень рендеринга" (SV_Target). Когда параметры смешивания не активны в нашем шейдере, SrcValue перезаписывает DstValue. Однако , если мы активируем это оба цвета смешиваются, чтобы получить новый цвет, который перезаписывает предыдущее значение DstValue.
        «SrcFactor» (исходный фактор) и «DstFactor» (целевой фактор) — это векторы трех измерений, которые различаются в зависимости от их конфигурации. Их основная функция — изменять значения SrcValue и DstValue для достижения интересных эффектов.
        
        • Off, disables Blending options.
        • One, (1, 1, 1).
        • Zero, (0, 0, 0).
        • SrcColor is equal to the RGB values of the SrcValue.
        • SrcAlpha is equal to the Alpha value of the SrcValue.
        • OneMinusSrcColor, 1 minus the RGB values of the SrcValue (1 - R, 1 - G, 1 - B).
        • OneMinusSrcAlpha, 1 minus the Alpha of SrcValue (1 - A, 1 - A, 1- A).
        • DstColor is equal to the RGB values of the DstValue.
        • DstAlpha is equal to the Alpha value of the DstValue.
        • OneMinusDstColor, 1 minus the RGB values of the DstValue (1 - R, 1 - G, 1 - B).
        • OneMinusDstAlpha, 1 minus the Alpha of the DstValue (1 - A, 1 - A, 1- A). 

        The most common types of blending are the following:
        • Blend SrcAlpha OneMinusSrcAlpha Обычное прозрачное смешивание
        • Blend One One Аддитивный смешанный цвет
        • Blend OneMinusDstColor One Мягкая добавка для смешивания цветов
        • Blend DstColor Zero Мультипликативное смешивание цветов
        • Blend DstColor SrcColor Мультипликативное смешивание x2
        • Blend SrcColor One Наложение наложения
        • Blend OneMinusSrcColor One Смешение мягкого света
        • Blend Zero OneMinusSrcColor Негативное смешение цветов
        */

        Cull [_Cull] // Установка режима отсечения граней

        ZTest [_ZTest] // Установка режима теста глубины
        /*
        • Less. Рисует объекты впереди, игнорируя объекты, которые находятся на том же расстоянии или позади объекта шейдера.
        • Greater. Отрисовывает объекты сзади.Не отрисовывает объекты, находящиеся на том же расстоянии или перед объектом шейдер.
        • LEqual. Значение по умолчанию Рисует объекты, находящиеся впереди или на одинаковом расстоянии.
        • GEqual. Отрисовывает объекты позади или на том же расстоянии.Не рисует объекты перед объектом шейдера
        • Equal. Отрисовывает объекты, находящиеся на одинаковом расстоянии.Не отрисовывает объекты перед или позади объекта шейдер.
        • NotEqual.  Отрисовывает объекты, находящиеся на разном расстоянии.Не рисует объекты, находящиеся на одинаковом расстоянии от объекта шейдера.
        • Always. Отрисовывает все пиксели, независимо от расстояния объектов относительно камеры.
        */

        ZWrite[_ZWrite] // Установка режима записи глубины
        ColorMask [_ColorMask] // Установка маски цветового канала

        lighting on // Отключение освещения

        //AlphaToMask On
        //ColorMask RGB

        // Проход
        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Задание функции вершинного шейдера
            #pragma fragment frag // Задание функции фрагментного шейдера
            #pragma multi_compile_fog // Включение поддержки тумана
            //#pragma multi_compile_shadowcaster//директива препроцессора в шейдерах Unity, которая указывает компилятору шейдера на необходимость генерации вариантов шейдера для прохождения теней.
            //#pragma shader_feature _ENABLE_ON //[Toggle] _Enable ("Enable ?", Float) = 0 не меняет состояния после компиляции
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE _OPTIONS_ON // несколько состояний [KeywordEnum(Off, Red, Blue)] _Options ("Color Options", Float) = 0 и сохраняет после компеляции варианты щейдера


            #include "UnityCG.cginc" // Включение стандартных функций и структур для работы с Unity

            //#include "HLSLSupport.cginc"библиотека с макросами для автоматического определения типов fixed
            //#include “Package/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl” //библиотека из urp - не совместима с UnityCG.cginc

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
            sampler2D _FrontTexture;
            sampler2D _BackTexture;
            float4 _MainTex_ST; // Матрица трансформации текстуры
            float4 _Color; //объявление цвета из свойств
            float _PowerSlider;
            int _IntRange;

            //теселяционный - изменение, добавление вершин и всякой срани
            
            // Функция вершинного шейдера
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Преобразование позиции вершины в пространство отсечения
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Преобразование координат текстуры, почему использует float4 _MainTex_ST?
                UNITY_TRANSFER_FOG(o, o.vertex); // Передача координат тумана

                /* 
                float4 vertPos : POSITION; будет содержать позицию примитивных вершин
                float2 texCoord : TEXCOORD0; позволяет получить доступ к UV-координатам нашего примитива и имеет до четырех измерений
                float3 normal : NORMAL0; мы можем получить доступ к нормалям нашего примитива, и он имеет до четырех измерений.Мы должны использовать эту семантику, если хотим работать с освещением в нашем шейдере
                float3 tangent : TANGENT0; дает доступ к касательным нашего примитива. Если мы хотим создать карты нормалей, необходимо будет работать с семантикой, которая также имеет до четырех измерений.
                float3 vertColor: COLOR0; позволяет нам получить доступ к цвету вершин нашего примитива и имеет до четырех измерений, как и остальные.
                */

                return o;
            }

            // Функция фрагментного шейдера
            fixed4 frag (v2f i, bool face : SV_IsFrontFace) : SV_Target // не для urp и hdrp, они не видят fixed, нужно привести к «half4 или float4»
            {
                fixed4 col = tex2D(_MainTex, i.uv); // Получение цвета из основной текстуры и его изменение с помощью _Color
                fixed4 colFront = tex2D(_FrontTexture, i.uv);
                fixed4 colBack = tex2D(_BackTexture, i.uv);
                
                UNITY_APPLY_FOG(i.fogCoord, col); // Применение тумана

                #if _OPTIONS_ON
                return col * _Color;
                #elif _OPTIONS_RED
                return col * float4(1, 0, 0, 1);
                #elif _OPTIONS_BLUE
                return col * float4(0, 0, 1, 1);
                #elif _OPTIONS_OFF
                return face ? colFront : colBack;
                #endif

                /* #if _ENABLE_ON
                #else
                return col;
                #endif */
            }
            
            ENDCG // Конец CGPROGRAM
        }
        /* Pass
        {
        } */
    }
    
    FallBack "Diffuse" //запасный шейдер
}
/* 
Встроенные функции в sg и hlsl (математические)
• Abs.
• Ceil.
• Clamp.
• Cos.
• Sin.
• Tan.
• Exp.
• Exp2.
• Floor.
• Step.
• Smoothstep.
• Frac.
• Length.
• Lerp.
• Min.
• Max.
• Pow. 
*/

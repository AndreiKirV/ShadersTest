Shader "Test"
{
    // Определение свойств шейдера
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1) // Параметр для определения цвета объекта
    }

    // Определение субшейдера
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" } // Теги субшейдера
        LOD 200

        // Определение прохода
        Pass
        {
            
            CGPROGRAM
            #pragma multi_compile_shadowcaster
            
            #pragma vertex vert // Определение функции вершинного шейдера
            #pragma fragment frag // Определение функции фрагментного шейдера

            // Входные данные вершинного шейдера
            struct appdata
            {
                float4 vertex : POSITION; // Позиция вершины в локальном пространстве
            };

            // Входные данные фрагментного шейдера
            struct v2f
            {
                float4 vertex : SV_POSITION; // Позиция вершины в экранных координатах
                float4 color : COLOR; // Цвет вершины
            };

            // Параметр для определения цвета объекта
            float4 _Color;

            // Функция вершинного шейдера
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Преобразование позиции вершины в экранные координаты
                o.color = _Color; // Передача цвета во фрагментный шейдер
                return o;
            }

            // Функция фрагментного шейдера
            half4 frag(v2f i) : SV_Target
            {
                return half4(i.color.rgb, 1.0); // Возвращение цвета вершины в качестве итогового цвета фрагмента
            }

            ENDCG
        }
    }
}

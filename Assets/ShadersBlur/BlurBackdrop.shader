Shader "BlurBackdrop"
{
     Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Factor ("Texture Factor" , Float) = 1
        _Color ("Color" , Color) = (1,1,1,1)
        _EColor ("EColor" , Color) = (1,1,1,1)
        _Offset ("Offset" , Float) = 0
        _Weight("WeightNewPass", float) = 1
        _PassCount("PassCount", int) = 1
        _DeltaPass("DeltaPass", float) = 1
        [Toggle] _IfOne ("IfOne", int) = 0
        [Toggle] _IsMultipliedTexture ("IsMultipliedTexture", int) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass
        {
            "_GrabTexture"
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _MainTex; 
            sampler2D _GrabTexture; 
            float4 _Color;
            float4 _EColor;
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            float _Offset; 
            float _Weight;
            float _DeltaPass;
            float _Factor;
            int _IfOne;
            int _IsMultipliedTexture;
            int _PassCount;

            float WeightChange(float descendingScale, float x)
            {
                float targetWeight = exp(-(x * x) / (2 * descendingScale * descendingScale));
                return targetWeight;
            }         

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.color = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.grabPos /= o.grabPos.w;
                return o;
            }

            float changeFloat(float x)
            {
                return exp(x);
            }
            
            float4 frag (v2f input) : SV_Target
            {
                float2 res = 1 / _ScreenParams.xy;//float2(1080, 1920);//_MainTex_TexelSize.xy;
                float4 col = tex2D(_MainTex, input.uv);
                float4 grabColor = float4(1,1,1,1);// = tex2D(_GrabTexture, input.grabPos.xy);
                float4 tempColor = grabColor;
                
                //for (int i = _PassCount; i >= 1; i--)
                for (int i = 1; i <= _PassCount; i++)
                {
                    float targetI = sqrt(i);
                    float tempWeight = WeightChange(_PassCount, i);
                    grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(_Offset * targetI, _Offset * targetI) * res).rgb * tempWeight * (2 * i * i);//↙

                        if(_IfOne == 0)
                        {
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(_Offset * targetI, -_Offset * targetI) * res).rgb * tempWeight * (2 * i * i);//↖
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(-_Offset * targetI, _Offset * targetI) * res).rgb * tempWeight * (2 * i * i);//↘
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(-_Offset * targetI, -_Offset * targetI) * res).rgb * tempWeight * (2 * i * i);//↗
                            
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(0, _Offset * targetI) * res).rgb * tempWeight * (2 * i * i);
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(_Offset * targetI, 0) * res).rgb * tempWeight * (2 * i * i);
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(-_Offset * targetI, 0) * res).rgb * tempWeight * (2 * i * i);
                            grabColor.rgb += tex2D(_GrabTexture, input.grabPos.xy + float2(0, -_Offset * targetI) * res).rgb * tempWeight  * (2 * i * i);
                        }

                    grabColor.rgb /= i / _Weight;
                }

                if(col.a > 0)
                {      
                    col.rgb = grabColor.rgb / _PassCount / _DeltaPass;// / 3;//(_PassCount * _PassCount);
                    col.rgb *= _Color.rgb;

                    if(_IsMultipliedTexture)
                    {
                        float4 tempCol = tex2D(_MainTex, input.uv);
                        tempCol.rgb *= _EColor.rgb;
                        col.rgb += tempCol.rgb;
                    }
                }

                //if()

	            return col;
            }
            ENDCG
        }
    }
}
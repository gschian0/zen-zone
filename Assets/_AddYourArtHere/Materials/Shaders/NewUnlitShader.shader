Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
    

            #include "UnityCG.cginc"

            #define PI 3.1415926535897932384626433832795
            #define TWOPI 6.283185307179586

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float rand(float2 n) { 
                return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
                }

            float noise(float2 p){
                float2 ip = floor(p);
                float2 u = frac(p);
                u = u*u*(3.0-2.0*u);
    
                float res = lerp(
                lerp(rand(ip),rand(ip+float2(1.0,0.0)),u.x),
                    lerp(rand(ip+float2(0.0,1.0)),rand(ip+float2(1.0,1.0)),u.x),u.y);
                    return res*res;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 uv = i.uv*2.-1;
                uv *= noise(uv*10);
                uv.x += sin(uv.y-_Time.y);
                uv.y += sin(uv.x - _Time.x);
                float circle = step(0.5, length(sin(10.*uv)));
                float4 col = float4(circle, circle, circle, 1.0);
                col.r -= rand(uv+_Time.xy);
                col.g *= rand(uv+_Time.xyz);
                col.b *= rand(uv-_Time.xy);
                return col;
                
            }
            ENDCG
        }
    }
}

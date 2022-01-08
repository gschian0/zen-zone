Shader "Legacy Shaders/Reflective/Bumped Diffuse" {
Properties {
    _ColorA ("Color A", Color) = (0.149,0.141,0.912)
    _ColorB ("Color B", Color) = (1.000,0.833,0.224)
    _Color ("Main Color", Color) = (1,1,1,1)
    _ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
    _MainTex ("Base (RGB) RefStrength (A)", 2D) = "white" {}
    _Cube ("Reflection Cubemap", Cube) = "_Skybox" { }
    _BumpMap ("Normalmap", 2D) = "bump" {}
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300

CGPROGRAM
#pragma surface surf Lambert
#define PI 3.1415926535897932384626433832795

sampler2D _MainTex;
sampler2D _BumpMap;
samplerCUBE _Cube;

fixed4 _Color;
fixed4 _ColorA;
fixed4 _ColorB;
fixed4 _ReflectColor;

struct Input {
    float2 uv_MainTex;
    float2 uv_BumpMap;
    float3 worldRefl;
    INTERNAL_DATA
};

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
    fixed2 st = IN.uv_MainTex*2.-1;
    fixed4 c = tex * _Color;
    
    fixed3 pct = fixed3(st.x,st.x,st.x);
    pct.r = smoothstep(0.0,1.0, st.x);
    pct.g = sin(2.0*length(st)*PI)*0.5+0.5;
    pct.b = pow(st.x,0.5);

    c = lerp(_ColorA, _ColorB, sin(1./st.x*20.+_Time.z));
    o.Albedo = pct*tex;
    o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

    float3 worldRefl = WorldReflectionVector (IN, o.Normal*o.Normal);
    fixed4 reflcol = texCUBE (_Cube, worldRefl);
    reflcol *= tex.a;
    o.Emission = reflcol.rgb * _ReflectColor.rgb;
    o.Alpha = reflcol.a * _ReflectColor.a;
}
ENDCG
}

FallBack "Legacy Shaders/Reflective/VertexLit"
}
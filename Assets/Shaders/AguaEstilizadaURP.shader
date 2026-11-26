Shader "AguaEstilizadaURP"
{
    Properties
    {
        [Header(Cores e Transparencia)]
        _ShallowColor ("Cor da Agua Rasa", Color) = (0.18, 0.78, 0.88, 1)
        _DeepColor ("Cor da Agua Profunda", Color) = (0.04, 0.28, 0.56, 1)
        _FoamColor ("Cor da Espuma", Color) = (0.94, 0.99, 1.0, 1)
        _Opacity ("Opacidade", Range(0.1, 1.0)) = 0.78

        [Header(Texturas e Movimento de UV)]
        _MainTex ("Textura Principal (Causticas)", 2D) = "white" {}
        _FoamMask ("Segunda Textura (Mascara de Espuma)", 2D) = "gray" {}
        _UVSpeed1 ("Velocidade UV Camada 1 (X, Y)", Vector) = (0.08, 0.05, 0, 0)
        _UVSpeed2 ("Velocidade UV Camada 2 (X, Y)", Vector) = (-0.06, 0.04, 0, 0)
        _FoamUVSpeed ("Velocidade UV da Espuma (X, Y)", Vector) = (0.03, -0.04, 0, 0)
        _UVDistortion ("Distorcao de UV", Range(0.0, 0.15)) = 0.03

        [Header(Mascara de Espuma)]
        _FoamCutoff ("Limite da Espuma", Range(0.0, 1.0)) = 0.62
        _FoamSoftness ("Suavidade da Espuma", Range(0.01, 0.4)) = 0.08
        _WaveCrestFoam ("Espuma nas Cristas", Range(0.0, 0.6)) = 0.25

        [Header(Deslocamento de Vertices)]
        _WaveAmplitude ("Amplitude das Ondas", Range(0.0, 0.5)) = 0.12
        _WaveFrequency ("Frequencia das Ondas", Float) = 1.6
        _WaveSpeed ("Velocidade das Ondas", Float) = 2.0

        [Header(Fresnel e Iluminacao)]
        _FresnelColor ("Cor do Fresnel", Color) = (0.75, 0.95, 1.0, 1)
        _FresnelPower ("Forca do Fresnel", Range(1.0, 8.0)) = 3.0
        _SpecularStrength ("Intensidade do Brilho", Range(0.0, 2.0)) = 0.8
        _SpecularPower ("Tamanho do Brilho", Range(8.0, 128.0)) = 48.0

    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode" = "UniversalForward" }

            //Transparência
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_FoamMask);
            SAMPLER(sampler_FoamMask);

            //Variáveis do material 
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _FoamMask_ST;
                half4 _ShallowColor;
                half4 _DeepColor;
                half4 _FoamColor;
                half _Opacity;
                float4 _UVSpeed1;
                float4 _UVSpeed2;
                float4 _FoamUVSpeed;
                float _UVDistortion;
                half _FoamCutoff;
                half _FoamSoftness;
                half _WaveCrestFoam;
                float _WaveAmplitude;
                float _WaveFrequency;
                float _WaveSpeed;
                half4 _FresnelColor;
                half _FresnelPower;
                half _SpecularStrength;
                half _SpecularPower;

            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalOS   : NORMAL;

            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uvMain      : TEXCOORD0;
                float2 uvFoam      : TEXCOORD1;
                half   waveHeight  : TEXCOORD2;
                float3 normalWS    : TEXCOORD3;
                float3 posWS       : TEXCOORD4;

            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                //Posição na cena
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);

                //Ondas nos vértices
                float waveA = sin(_Time.y * _WaveSpeed + posWS.x * _WaveFrequency);
                float waveB = cos(_Time.y * _WaveSpeed * 0.8 + posWS.z * _WaveFrequency * 1.15);
                float waveCombined = (waveA + waveB) * 0.5;

                posWS.y += waveCombined * _WaveAmplitude;

                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.uvMain = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uvFoam = TRANSFORM_TEX(IN.uv, _FoamMask);

                //Altura da onda
                OUT.waveHeight = (half)(waveCombined * 0.5 + 0.5);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.posWS = posWS;


                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //Movimento e distorção da UV
                float2 uvDistort = float2(
                    sin(_Time.y * 1.3 + IN.uvMain.y * 8.0),
                    cos(_Time.y * 1.1 + IN.uvMain.x * 8.0)
                ) * _UVDistortion;

                float2 uvLayer1 = IN.uvMain + _Time.y * _UVSpeed1.xy + uvDistort;
                float2 uvLayer2 = IN.uvMain * 1.25 + _Time.y * _UVSpeed2.xy - uvDistort * 0.5;

                half caustic1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvLayer1).r;
                half caustic2 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvLayer2).r;
                half caustics = (caustic1 + caustic2) * 0.5h;

                //Cor da água
                half waterBlend = saturate(caustics * 0.7h + IN.waveHeight * 0.35h);
                half3 waterColor = lerp(_DeepColor.rgb, _ShallowColor.rgb, waterBlend);

                //Espuma da água
                float2 uvFoam = IN.uvFoam + _Time.y * _FoamUVSpeed.xy + uvDistort * 0.6;
                half maskSample = SAMPLE_TEXTURE2D(_FoamMask, sampler_FoamMask, uvFoam).r;

                half foamSignal = maskSample + IN.waveHeight * _WaveCrestFoam;
                half foamFactor = smoothstep(_FoamCutoff - _FoamSoftness, _FoamCutoff + _FoamSoftness, foamSignal);

                half3 finalColor = lerp(waterColor, _FoamColor.rgb, foamFactor);

                float3 normalWS = normalize(IN.normalWS);
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.posWS));

                //Fresnel
                half fresnel = pow(1.0h - saturate(dot(normalWS, viewDirWS)), _FresnelPower);
                finalColor = lerp(finalColor, _FresnelColor.rgb, fresnel * 0.6h);

                //Iluminacao
                Light mainLight = GetMainLight();
                float3 halfDir = normalize(mainLight.direction + viewDirWS);
                half spec = pow(saturate(dot(normalWS, halfDir)), _SpecularPower);
                finalColor += mainLight.color * spec * _SpecularStrength;


                //Espuma mais opaca
                half finalAlpha = saturate(_Opacity + foamFactor * 0.25h);

                return half4(finalColor, finalAlpha);
            }
            ENDHLSL
        }
    }

    Fallback Off
}

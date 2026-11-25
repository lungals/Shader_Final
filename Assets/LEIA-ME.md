# Trabalho Final Individual — Shader de Água Estilizada (URP)

- **Aluno:** [Preencha com seu nome completo]
- **Versão do Unity:** 6000.3.6f1
- **Pipeline de Renderização:** Universal Render Pipeline (URP)
- **Caminho da Cena Principal:** `Assets/Scenes/CenaAguaEstilizada.unity`
- **Shader Principal:** `Assets/Shaders/AguaEstilizadaURP.shader` (`Aluno/AguaEstilizadaURP`)

---

## 1. Descrição do Efeito

Este projeto apresenta um shader autoral de **água estilizada** escrito inteiramente em **ShaderLab e HLSL** para o **Universal Render Pipeline (URP)**, com vertex shader e fragment shader próprios, compatível com SRP Batcher (`CBUFFER_START(UnityPerMaterial)`).

O efeito combina ondulação geométrica suave, duas camadas de cáusticas animadas em direções diferentes, espuma estilizada controlada por uma máscara de ruído e transparência com alpha blending para permitir enxergar o fundo e objetos parcialmente submersos.

### Recursos Adicionais Implementados (4 recursos — mínimo exigido: 2)

1. **Deslocamento de vértices:** No vertex shader (`vert`), a coordenada Y de cada vértice em espaço de mundo é deslocada por duas ondas senoidais (`sin` e `cos`) animadas com `_Time.y`. A altura normalizada da onda é enviada ao fragment shader para realçar as cristas.
2. **Movimento e distorção de UV:** No fragment shader (`frag`), as UVs da textura principal são deslocadas em duas camadas com velocidades independentes (`_UVSpeed1` e `_UVSpeed2`) usando `_Time.y`, somadas a uma leve distorção senoidal (`_UVDistortion`).
3. **Segunda textura / máscara:** Uma segunda textura de ruído contínuo (`_FoamMask`) é amostrada com UVs animadas e combinada com a altura das ondas (`_WaveCrestFoam`) usando `smoothstep` para gerar manchas de espuma estilizada.
4. **Transparência:** Configurada com `"Queue" = "Transparent"`, `"RenderType" = "Transparent"`, `Blend SrcAlpha OneMinusSrcAlpha`, `ZWrite Off` e propriedade `_Opacity` exposta no Inspector.

---

## 2. Propriedades Expostas no Inspector

| Grupo | Propriedade | Função |
|---|---|---|
| Cores e Transparência | `Cor da Agua Rasa` (`_ShallowColor`) | Cor das áreas iluminadas, cáusticas e cristas. |
| Cores e Transparência | `Cor da Agua Profunda` (`_DeepColor`) | Cor base das áreas mais escuras e fundas. |
| Cores e Transparência | `Cor da Espuma` (`_FoamColor`) | Cor aplicada onde a máscara de espuma aparece. |
| Cores e Transparência | `Opacidade` (`_Opacity`) | Controla a transparência geral da água. |
| Texturas e Movimento de UV | `Textura Principal (Causticas)` (`_MainTex`) | Padrão celular de cáusticas (Tiling/Offset ativos). |
| Texturas e Movimento de UV | `Segunda Textura (Mascara de Espuma)` (`_FoamMask`) | Máscara de ruído para formação de espuma. |
| Texturas e Movimento de UV | `Velocidade UV Camada 1 / 2` | Direção e velocidade de rolagem das duas camadas de cáusticas. |
| Texturas e Movimento de UV | `Velocidade UV da Espuma` | Movimento da máscara de espuma. |
| Texturas e Movimento de UV | `Distorcao de UV` (`_UVDistortion`) | Intensidade da ondulação das UVs. |
| Máscara de Espuma | `Limite da Espuma` (`_FoamCutoff`) | Controla a quantidade de espuma visível. |
| Máscara de Espuma | `Suavidade da Espuma` (`_FoamSoftness`) | Controla se a borda da espuma é mais dura (estilo cartoon) ou suave. |
| Máscara de Espuma | `Espuma nas Cristas` (`_WaveCrestFoam`) | Reforça espuma no topo das ondas. |
| Deslocamento de Vértices | `Amplitude das Ondas` (`_WaveAmplitude`) | Altura máxima das ondas na malha. |
| Deslocamento de Vértices | `Frequencia das Ondas` (`_WaveFrequency`) | Quantidade de ondas ao longo da superfície. |
| Deslocamento de Vértices | `Velocidade das Ondas` (`_WaveSpeed`) | Rapidez do movimento vertical das ondas. |

---

## 3. Instruções para Abrir e Testar

1. Abra o projeto no **Unity 6000.3.6f1** com o template **Universal 3D (URP)**.
2. Abra a cena `Assets/Scenes/CenaAguaEstilizada.unity`.
3. Pressione **Play** (ou ative *Always Refresh* na aba Scene) para observar a animação contínua das ondas, das cáusticas e da espuma.
4. Selecione o material `Assets/Materials/M_AguaEstilizada.mat` para ajustar cores, velocidade, opacidade, espuma e amplitude das ondas em tempo real no Inspector.

---

## 4. Roteiro Rápido para a Apresentação Individual

- **Properties:** Controles expostos no Inspector para alterar cores, opacidade, velocidades de UV, espuma e amplitude/frequência das ondas sem mexer no código.
- **Vertex Shader (`vert`):** Converte os vértices para espaço de mundo, desloca o eixo Y com duas ondas senoidais baseadas em `_Time.y`, projeta para clip space e repassa as UVs e a altura da onda (`waveHeight`).
- **Interpolação (`Varyings`):** Os dados de `uvMain`, `uvFoam` e `waveHeight` são interpolados pela GPU entre os vértices para cada fragmento da superfície.
- **Fragment Shader (`frag`):** Distorce e move as UVs em duas camadas da textura de cáusticas, mistura as cores rasa e profunda, amostra a segunda textura como máscara de espuma com `smoothstep` e calcula a cor e o alpha finais.
- **Pass / Estados:** Usa `RenderPipeline = "UniversalPipeline"`, `Queue = "Transparent"`, `Blend SrcAlpha OneMinusSrcAlpha` e `ZWrite Off` para renderizar transparência corretamente na URP.

---

## 5. Créditos e Referências

- **Documentação oficial do Unity (URP / ShaderLab / HLSL):**
  - Unity Manual — ShaderLab syntax & structure
  - Unity Manual — Writing custom shaders in URP (`Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl`)
  - Unity Manual — Built-in shader variables (`_Time`)
- **Microsoft Learn:** HLSL Reference (`sin`, `cos`, `lerp`, `smoothstep`, `saturate`)
- **Texturas (`T_Agua_Causticas.png` e `T_Agua_MascaraEspuma.png`):** Geradas proceduralmente (padrão celular Voronoi contínuo e ruído multi-oitava contínuo) exclusivamente para este trabalho.
- **Script auxiliar (`GeradorPlanoAgua.cs`):** Criado para gerar um plano subdividido (50×50) dentro do próprio Unity, garantindo suavidade na deformação dos vértices.

[LEIAME.md](https://github.com/user-attachments/files/35439293/LEIAME.md)
# LEIA-ME — Trabalho Final: Água Estilizada (Shader no Unity)

**Aluno(a):** `[PREENCHER: seu nome completo]`

**Versão do Unity:** 6000.3.6f1 (Unity 6.3)

**Pipeline de renderização:** Universal Render Pipeline (URP) 17.3.0

---

## 1. Como abrir e executar

1. Abra o **Unity Hub** e adicione a pasta `Shader_Final` como projeto, usando o editor **6000.3.6f1** (instale-o pelo Hub se necessário).
2. Aguarde a importação dos assets e a compilação dos scripts.
3. Abra a cena `Assets/Scenes/ÁguaEstilizaada.unity` (ela já está cadastrada em *Build Profiles / Scene List*).
4. O efeito já é visível no **modo Scene/Game** sem apertar Play: a água se move com o tempo e o plano é gerado por script com `[ExecuteAlways]`. *(No Scene View, ative **Always Refresh** no menu de efeitos para ver a animação no editor.)*
5. Ao apertar **Play**, o script `SpawnRochasNoPlay` instancia o prefab de rochas (`Rochas.prefab`) na cena.
6. Para experimentar o visual: na Hierarchy selecione **AguaEstilizada**, abra o material `M_AguaEstilizada` no Inspector e altere os parâmetros (seção 4) — inclusive durante o Play.

> Observação: o shader usa o `LightMode = UniversalForward` e as bibliotecas da URP, portanto **só funciona em URP**. Em outro pipeline o material aparecerá rosa.

---

## 2. Descrição do efeito

O projeto apresenta uma **água estilizada** (visual “cartoon”) sobre um fundo de areia com rochas. O plano de água é translúcido, ondula, tem cáusticas animadas, espuma nas cristas das ondas e uma borda mais clara nos ângulos rasos de visão, além de um brilho especular da luz direcional.

O efeito é composto por camadas, todas calculadas no shader:

- **Ondas (vertex shader):** cada vértice é deslocado no eixo Y por uma soma de seno e cosseno dependentes do tempo e da posição no mundo.
- **Cor por profundidade aparente:** a cor é uma mistura entre água rasa e profunda, controlada pelas cáusticas e pela altura da onda.
- **Cáusticas (textura principal):** a textura é amostrada duas vezes, com escalas e velocidades diferentes, e as amostras são combinadas, gerando padrão de luz que parece se mover na água.
- **Espuma (segunda textura como máscara):** uma máscara de ruído, também animada, é somada à altura da onda e passa por `smoothstep` com limite e suavidade ajustáveis.
- **Fresnel:** reforça a cor nas bordas, onde o ângulo entre a normal e a direção da câmera é maior.
- **Iluminação:** brilho especular tipo Blinn-Phong com a luz principal da cena.
- **Transparência:** blending alfa; a espuma é mais opaca que a água.

---

## 3. Requisitos do trabalho × onde estão no projeto

| Requisito do guia | Como foi atendido |
|---|---|
| Shader próprio em ShaderLab + HLSL com vertex e fragment | `AguaEstilizadaURP.shader`: bloco `Properties`/`SubShader`/`Pass` (ShaderLab) e `HLSLPROGRAM` com funções `vert` e `frag` |
| Propriedades no Inspector | Bloco `Properties` com 20 parâmetros agrupados por `[Header]` |
| Pelo menos uma textura | Duas: `_MainTex` (cáusticas) e `_FoamMask` (máscara de espuma) |
| Variável baseada em tempo | `_Time.y` nas ondas, no movimento/distorção de UV e na animação da espuma |
| Parâmetros que alteram o visual sem editar o código | Todos expostos no material `M_AguaEstilizada` |
| Cena com objeto, câmera e iluminação | Plano de água, fundo de areia, rochas, `Main Camera` e `Directional Light` (intensidade 2) |

### Recursos adicionais escolhidos (mínimo exigido: 2) — foram implementados 6

1. **Transparência** — `Blend SrcAlpha OneMinusSrcAlpha`, `ZWrite Off`, `Queue = Transparent`.
2. **Deslocamento de vértices** — ondas senoidais em `vert`.
3. **Distorção e movimento de UV** — rolagem por `_UVSpeed1/2` e ondulação por `_UVDistortion`.
4. **Efeito dependente do ângulo de visão (Fresnel)** — `pow(1 - saturate(dot(N, V)), _FresnelPower)`.
5. **Cálculo de iluminação** — especular com `GetMainLight()`.
6. **Segunda textura / máscara** — `_FoamMask` define a espuma.

---

## 4. Propriedades do material (Inspector)

| Grupo | Propriedade | O que faz |
|---|---|---|
| Cores e transparência | `_ShallowColor` | Cor da água rasa (regiões claras) |
| | `_DeepColor` | Cor da água profunda (regiões escuras) |
| | `_FoamColor` | Cor da espuma |
| | `_Opacity` (0,1–1) | Opacidade base da água |
| Texturas e UV | `_MainTex` | Textura de cáusticas (Tiling/Offset editáveis) |
| | `_FoamMask` | Máscara de espuma (Tiling/Offset editáveis) |
| | `_UVSpeed1`, `_UVSpeed2` | Velocidade (X, Y) das duas camadas de cáustica |
| | `_FoamUVSpeed` | Velocidade (X, Y) da espuma |
| | `_UVDistortion` (0–0,15) | Intensidade da distorção ondulada das UVs |
| Máscara de espuma | `_FoamCutoff` | Limite a partir do qual aparece espuma |
| | `_FoamSoftness` | Suavidade da transição da espuma |
| | `_WaveCrestFoam` | Quanto as cristas das ondas aumentam a espuma |
| Deslocamento de vértices | `_WaveAmplitude` (0–0,5) | Altura das ondas |
| | `_WaveFrequency` | Frequência espacial das ondas |
| | `_WaveSpeed` | Velocidade das ondas |
| Fresnel e iluminação | `_FresnelColor` | Cor da borda |
| | `_FresnelPower` (1–8) | Quanto o efeito se concentra na borda |
| | `_SpecularStrength` | Intensidade do brilho |
| | `_SpecularPower` | Tamanho do brilho (maior = ponto menor) |

**Valores usados no material entregue (`M_AguaEstilizada`):**

![Inspector do material M_AguaEstilizada]([imagens/inspetor_material_agua.png](https://github.com/lungals/Shader_Final/blob/main/Inspetor%20de%20material%20M_AguaEstilizada.png?raw=true))

---

## 5. Como o shader funciona (resumo para a apresentação)

**Fluxo:** malha → `vert` → interpolação → `frag` → blending com a imagem.

**Vertex shader (`vert`)**
- Converte a posição do objeto para o mundo (`TransformObjectToWorld`).
- Calcula duas ondas: `sin(t·vel + x·freq)` e `cos(t·vel·0,8 + z·freq·1,15)`; a média delas é somada a `y`. Usar a posição **no mundo** faz as ondas independerem da escala do objeto.
- Converte para clip space (`TransformWorldToHClip`).
- Repassa UVs (com `TRANSFORM_TEX`), altura da onda normalizada para 0–1, normal e posição no mundo, que são interpoladas para os fragmentos.

**Fragment shader (`frag`)**
1. Calcula um deslocamento de UV com seno/cosseno do tempo (distorção).
2. Amostra as cáusticas em duas camadas e faz a média.
3. Mistura `_DeepColor` e `_ShallowColor` com as cáusticas e a altura da onda.
4. Amostra a máscara de espuma, soma a influência das cristas e aplica `smoothstep(cutoff − softness, cutoff + softness, …)`.
5. Aplica Fresnel e o especular da luz principal.
6. Retorna a cor com alpha = `_Opacity + espuma × 0,25`.

**Estados do Pass:** `Blend SrcAlpha OneMinusSrcAlpha`, `ZWrite Off`, `Cull Back` e fila `Transparent`.

**Detalhe técnico:** as variáveis do material estão dentro de `CBUFFER_START(UnityPerMaterial)`, o que mantém o shader compatível com o SRP Batcher da URP.

---

## 6. Estrutura do projeto

```
Assets/
├── Scenes/ÁguaEstilizaada.unity        ← cena principal
├── Shaders/AguaEstilizadaURP.shader    ← shader autoral (ShaderLab + HLSL)
├── Scripts/
│   ├── GeradorPlanoAgua.cs             ← gera o plano subdividido (50×50, 19×10 m)
│   └── SpawnRochasNoPlay.cs            ← instancia as rochas ao dar Play
└── Assets/
    ├── Materials/M_AguaEstilizada.mat  ← material da água
    ├── Materials/Sand.mat              ← material do fundo
    ├── Textures/
    │   ├── T_Agua_Causticas.png        ← textura principal (cáusticas)
    │   ├── T_Agua_MascaraEspuma.png    ← máscara de espuma
    │   ├── Sand_BaseColor.png / Sand_NormalMap.png
    └── Rochas/                         ← pacote “Rocks Stylized” (prefabs, modelos, textura)
```

**Cena:** `Main Camera` (posição 0,3 / 7 / −5,2), `Directional Light` (intensidade 2), `Global Volume`, `Fundo` (plano de areia, escala 2,4 × 1 × 1,2, y = 0,7) e `AguaEstilizada` (y = 2, com `GeradorPlanoAgua` e `MeshRenderer` usando `M_AguaEstilizada`).

**Configuração do fundo (material `Sand`, URP/Lit) e do script de rochas no Inspector:**

![Inspector do material Sand e do script SpawnRochasNoPlay](imagens/inspetor_areia_e_spawn_rochas.png)

**Scripts de apoio em C#:** `GeradorPlanoAgua` cria um plano com 50×50 subdivisões. Isso é necessário porque o deslocamento de vértices só aparece em malhas com vértices suficientes; um Plane padrão da Unity não teria resolução para ondas.

---

## 7. Créditos e referências

**Código:** o shader (`AguaEstilizadaURP.shader`) e os scripts C# foram escritos por mim para este trabalho, a partir da estrutura básica do guia da atividade. `[AJUSTE se usou apoio de tutoriais ou IA para o código e liste aqui — o guia pede que as fontes sejam indicadas.]`

**Texturas**
- `T_Agua_Causticas.png` e `T_Agua_MascaraEspuma.png` (texturas da água): geradas com a IA **Gemini** (Google), a partir de pedidos (prompts) feitos por mim.
- Material de areia (`Sand.mat`, `Sand_BaseColor.png` e `Sand_NormalMap.png`): material pronto “Rippled Wet Sand” baixado do site **Poliigon**: https://www.poliigon.com/texture/rippled-wet-sand-texture/6997

**Modelos 3D**
- Pacote “Rocks Stylized” (pasta `Assets/Assets/Rochas`): “Free Pack Rocks Stylized”, baixado da **Unity Asset Store**: https://assetstore.unity.com/packages/3d/environments/free-pack-rocks-stylized-316250

**Documentação consultada**
- Unity — ShaderLab: estrutura e comandos de shaders
- Unity — Built-in shader variables (`_Time`)
- Unity — URP: writing shaders
- Microsoft — HLSL reference
- Guia do Trabalho Final — Shaders no Unity (material da disciplina)
- `[ADICIONE tutoriais, vídeos ou fóruns usados]`

---

## 8. Observações e limitações conhecidas

- Funciona apenas em **URP** (`"RenderPipeline" = "UniversalPipeline"`); não há Pass para sombras ou depth, então a água não projeta sombra, o que é esperado para um material translúcido.
- Por ser transparente com `ZWrite Off`, a ordenação com outros objetos transparentes pode precisar de ajuste na fila de renderização.
- O shader usa a luz principal apenas (`GetMainLight()`); luzes adicionais não influenciam o brilho.
- As rochas só aparecem na cena depois de entrar em Play.

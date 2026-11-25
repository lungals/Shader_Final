using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class GeradorPlanoAgua : MonoBehaviour
{
    [Header("Dimensoes do Plano")]
    [Min(1f)] public float largura = 10f;
    [Min(1f)] public float comprimento = 10f;

    [Header("Subdivisoes da Malha")]
    [Range(10, 120)] public int subdivisoesX = 50;
    [Range(10, 120)] public int subdivisoesZ = 50;

    private Mesh _malha;

    private void OnEnable()
    {
        GerarMalha();
    }

    private void OnValidate()
    {
        GerarMalha();
    }

    public void GerarMalha()
    {
        MeshFilter mf = GetComponent<MeshFilter>();
        if (mf == null) return;

        if (_malha == null)
        {
            _malha = new Mesh { name = "PlanoAguaSubdividido" };
        }
        else
        {
            _malha.Clear();
        }

        int vertX = subdivisoesX + 1;
        int vertZ = subdivisoesZ + 1;

        Vector3[] vertices = new Vector3[vertX * vertZ];
        Vector2[] uvs = new Vector2[vertX * vertZ];
        int[] triangulos = new int[subdivisoesX * subdivisoesZ * 6];

        float metadeLargura = largura * 0.5f;
        float metadeComprimento = comprimento * 0.5f;

        for (int z = 0; z < vertZ; z++)
        {
            float tz = (float)z / subdivisoesZ;
            for (int x = 0; x < vertX; x++)
            {
                float tx = (float)x / subdivisoesX;
                int index = z * vertX + x;

                vertices[index] = new Vector3(
                    tx * largura - metadeLargura,
                    0f,
                    tz * comprimento - metadeComprimento
                );
                uvs[index] = new Vector2(tx, tz);
            }
        }

        int t = 0;
        for (int z = 0; z < subdivisoesZ; z++)
        {
            for (int x = 0; x < subdivisoesX; x++)
            {
                int i0 = z * vertX + x;
                int i1 = i0 + 1;
                int i2 = i0 + vertX;
                int i3 = i2 + 1;

                triangulos[t++] = i0;
                triangulos[t++] = i2;
                triangulos[t++] = i1;

                triangulos[t++] = i1;
                triangulos[t++] = i2;
                triangulos[t++] = i3;
            }
        }

        _malha.vertices = vertices;
        _malha.uv = uvs;
        _malha.triangles = triangulos;
        _malha.RecalculateNormals();
        _malha.RecalculateBounds();

        mf.sharedMesh = _malha;
    }
}

using UnityEngine;

public class SpawnRochasNoPlay : MonoBehaviour
{
    public GameObject prefabRochas;

    void Start()
    {
        if (prefabRochas != null)
        {
            Instantiate(prefabRochas);
        }
            
    }

}

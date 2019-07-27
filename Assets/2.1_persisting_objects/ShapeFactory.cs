using UnityEngine;

[CreateAssetMenu]
public class ShapeFactory : ScriptableObject
{
    [SerializeField]
    Shape[] prefabs;

    public Shape Get(int shapeId) {
        return Instantiate(prefabs[shapeId]);
    }
    public Shape GetRandom()
    {
        return Get(Random.Range(0, prefabs.Length));
    }
}
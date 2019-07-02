using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public delegate Vector3 MathSurfaceFunction(float u, float v, float t);

public enum MathSurfaceFunctionName
{
    Sine,
    Sine2D,
    MultiSine,
    MultiSine2D,
    Ripple,
    Cylinder
}

public class MathSurface : MonoBehaviour
{
    const float pi = Mathf.PI;

    public Transform pointPrefab;

    [Range(10, 100)]
    public int resolution = 10;

    public MathSurfaceFunctionName function;


    Transform[] points;

    static MathSurfaceFunction[] functions =
    {
        SineFunction, Sine2DFunction, MultiSineFunction, MultiSine2DFunction,
        Ripple, Cylinder
    };

    private void Awake()
    {
        points = new Transform[resolution * resolution];
        float step = 2f / resolution;
        Vector3 scale = Vector3.one * step;
        for (int i = 0; i < points.Length; i++)
        {
            Transform point = Instantiate(pointPrefab);
            points[i] = point;
            point.localScale = scale;
            point.SetParent(transform, false);

        }
    }

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        float t = Time.time;
        MathSurfaceFunction f = functions[(int)function];

        float step = 2f / resolution;
        for (int i = 0, z = 0; z < resolution; z++)
        {
            float v = (z + 0.5f) * step - 1f;
            for (int x = 0; x < resolution; x++, i++)
            {
                float u = (x + 0.5f) * step - 1f;
                points[i].localPosition = f(u, v, t);
            }
        }
    }

    static Vector3 SineFunction(float x, float z, float t)
    {
        Vector3 p;
        p.x = x;
        p.y = Mathf.Sin(pi * (x + t));
        p.z = z;
        return p;
    }

    static Vector3 MultiSineFunction(float x, float z, float t)
    {
        float y = Mathf.Sin(pi * (x + t));
        y += Mathf.Sin(2f * pi * (x + 2 * t)) / 2f;
        y *= 2f / 3f;
        Vector3 p;
        p.x = x;
        p.y = y;
        p.z = z;
        return p;
    }

    static Vector3 Sine2DFunction(float x, float z, float t)
    {
        float y = Mathf.Sin(pi * (x + t));
        y += Mathf.Sin(pi * (z + t));
        y *= 0.5f;
        Vector3 p;
        p.x = x;
        p.y = y;
        p.z = z;
        return p;
    }

    static Vector3 MultiSine2DFunction(float x, float z, float t)
    {
        float y = 4f * Mathf.Sin(pi * (x + z + t * 0.5f));
        y += Mathf.Sin(pi * (x + t));
        y += Mathf.Sin(2f * pi * (z + 2f * t)) * 0.5f;
        y *= 1f / 5.5f;
        Vector3 p;
        p.x = x;
        p.y = y;
        p.z = z;
        return p;
    }

    static Vector3 Ripple(float x, float z, float t)
    {
        float d = Mathf.Sqrt(x * x + z * z);
        float y = Mathf.Sin(pi * (4f * d - t));
        y /= 1f + 10f * d;
        Vector3 p;
        p.x = x;
        p.y = y;
        p.z = z;
        return p;
    }

    static Vector3 Cylinder(float x, float z, float t)
    {
        Vector3 p;
        p.x = 0f;
        p.y = 0f;
        p.z = 0f;
        return p;
    }
}

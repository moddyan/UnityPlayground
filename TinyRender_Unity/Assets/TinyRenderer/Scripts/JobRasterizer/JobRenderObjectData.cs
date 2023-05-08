using System;
using Unity.Collections;
using UnityEngine;

namespace TinyRenderer
{
    public class JobRenderObjectData : IRenderObjectData
    {
        public NativeArray<Vector3> positionData;
        public NativeArray<Vector3> normalData;
        public NativeArray<Vector2> uvData;
        public NativeArray<Vector3Int> trianglesData;

        public JobRenderObjectData(Mesh mesh)
        {
            positionData = new NativeArray<Vector3>(mesh.vertexCount, Allocator.Persistent);
            positionData.CopyFrom(mesh.vertices);

            normalData = new NativeArray<Vector3>(mesh.vertexCount, Allocator.Persistent);
            normalData.CopyFrom(mesh.normals);

            uvData = new NativeArray<Vector2>(mesh.vertexCount, Allocator.Persistent);
            uvData.CopyFrom(mesh.uv);

            var triangles = mesh.triangles;
            var triangleCnt = triangles.Length / 3;
            trianglesData = new NativeArray<Vector3Int>(triangleCnt, Allocator.Persistent);
            for (int i = 0; i < triangleCnt; ++i)
            {
                int j = i * 3;
                trianglesData[i] = new Vector3Int(triangles[j], triangles[j + 1], triangles[j + 2]);
            }
        }

        public void Release()
        {
            positionData.Dispose();
            normalData.Dispose();
            uvData.Dispose();
            trianglesData.Dispose();
        }
    }
}

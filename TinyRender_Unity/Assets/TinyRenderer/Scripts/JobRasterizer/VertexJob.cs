using System;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

namespace TinyRenderer
{
    [BurstCompile]
    public struct VertexJob : IJobParallelFor
    {
        [ReadOnly]
        public NativeArray<Vector3> positionData;
        [ReadOnly]
        public NativeArray<Vector3> normalData;

        public Matrix4x4 mvpMatrix;
        public Matrix4x4 modelMatrix;
        public Matrix4x4 normalMatrix;

        public NativeArray<VSOutBuf> result;

        public void Execute(int index)
        {
            var vert = positionData[index];
            var normal = normalData[index];
            var output = result[index];

            var objVert = new Vector4(vert.x, vert.y, vert.z, 1);
            output.clipPos = mvpMatrix * objVert;
            output.worldPos = normalMatrix * objVert;
            output.objectNormal = normal;
            output.worldNormal = normalMatrix * normal;

            result[index] = output;
        }
    }
}

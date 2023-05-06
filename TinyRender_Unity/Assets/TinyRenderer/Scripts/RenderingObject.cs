using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TinyRenderer
{
    public class RenderingObject : MonoBehaviour
    {
        [HideInInspector, NonSerialized]
        public Mesh mesh;

        [HideInInspector, NonSerialized]
        public Texture2D texture;

        public bool DoubleSideRendering;

        public CPURenderObjectData cpuData;

        void Start()
        {
            var meshFilter = GetComponent<MeshFilter>();
            if (meshFilter != null)
            {
                mesh = meshFilter.mesh;
            }

            var meshRenderer = GetComponent<MeshRenderer>();
            if (meshRenderer != null && meshRenderer.sharedMaterial != null)
            {
                texture = meshRenderer.sharedMaterial.mainTexture as Texture2D;
            }
            if (texture == null)
            {
                texture = Texture2D.whiteTexture;
            }

            // 为了能在运行时动态切换 Rasterizer, 这里同时把每个Rasterizer需要的数据创建出来
            // TODO, 这里有优化空间，lazy init
            if(mesh != null)
            {
                cpuData = new CPURenderObjectData(mesh);
            }

        }

        private void OnDestroy()
        {
            cpuData.Release();
        }

        // TRS
        public Matrix4x4 GetModelMatrix()
        {
            //if (transform == null)
            //{
            //    return TransformTool.GetRotZMatrix(0);
            //}

            //var matScale = TransformTool.GetScaleMatrix(transform.lossyScale);

            //var rotation = transform.rotation.eulerAngles;
            //var rotX = TransformTool.GetRotationMatrix(Vector3.right, -rotation.x);
            //var rotY = TransformTool.GetRotationMatrix(Vector3.up, -rotation.y);
            //var rotZ = TransformTool.GetRotationMatrix(Vector3.forward, rotation.z);
            //var matRot = rotY * rotX * rotZ; // rotation apply order: z(roll), x(pitch), y(yaw) 

            //var matTranslation = TransformTool.GetTranslationMatrix(transform.position);

            //return matTranslation * matRot * matScale;

            return transform.localToWorldMatrix;            
        }

    }
}

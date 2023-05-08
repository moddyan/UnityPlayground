using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;
using static UnityEngine.Rendering.HableCurve;

namespace TinyRenderer
{
    public class JobRasterizer : IRasterizer
    {
        int _width, _height;
        RenderingConfig _config;

        Matrix4x4 _modelMatrix;
        Matrix4x4 _viewMatrix;
        Matrix4x4 _projectionMatrix;

        NativeArray<Color> frameBuffer;
        NativeArray<float> depthBuffer;

        Color[] tempBuffer;
        float[] tempDepthBuffer;

        public Texture2D texture;
        ShaderUniforms uniforms;

        // Stats
        int _trianglesAll, _trianglesRendered;
        int _verticesAll;

        //优化GC
        Vector4[] _tmpVector4s = new Vector4[3];
        Vector3[] _tmpVector3s = new Vector3[3];

        public string Name => "CPU Jobs";

        public Texture ColorTexture => texture;

        public OnRasterizerStatUpdate onRasterizerStatUpdate;

        public float Aspect => (float)_width / _height;

        public JobRasterizer(int width, int height, RenderingConfig renderConfig)
        {
            _width = width;
            _height = height;
            _config = renderConfig;

            texture = new Texture2D(width, height);
            texture.filterMode = FilterMode.Point;

            int bufSize = width * height;

            frameBuffer = new NativeArray<Color>(bufSize, Allocator.Persistent);
            depthBuffer = new NativeArray<float>(bufSize, Allocator.Persistent);

            tempBuffer = new Color[bufSize];
            tempDepthBuffer = new float[bufSize];
            TinyRenderUtils.FillArray(tempDepthBuffer, 0);
        }

        public void Release()
        {
            texture = null;
            frameBuffer.Dispose();
            depthBuffer.Dispose();
            tempBuffer = null;
            tempDepthBuffer = null;
        }

        public void Clear(BufferMask mask)
        {
            ProfilerManager.BeginSample("JObRasterizer.Clear");
           
            // Color Buffer
            if ((mask & BufferMask.Color) == BufferMask.Color)
            {
                TinyRenderUtils.FillArray<Color>(tempBuffer, _config.ClearColor);
            }

            // Depth Buffer
            if ((mask & BufferMask.Depth) == BufferMask.Depth)
            {
                TinyRenderUtils.FillArray<float>(tempDepthBuffer, 0f);
            }

            _trianglesAll = _trianglesRendered = 0;
            _verticesAll = 0;

            ProfilerManager.EndSample();
        }

        public void SetupUniforms(Camera camera, Light mainLight)
        {
            ShaderContext.Config = _config;

            var camPos = camera.transform.position;
            uniforms.WorldSpaceCameraPos = camPos;

            var lightDir = -mainLight.transform.forward;
            uniforms.WorldSpaceLightDir = lightDir;
            uniforms.LightColor = mainLight.color * mainLight.intensity;
            uniforms.AmbientColor = _config.AmbientColor;

            //TransformTool.SetupViewProjectionMatrix(camera, Aspect, out _viewMatrix, out _projectionMatrix);
            _viewMatrix = camera.worldToCameraMatrix;
            _projectionMatrix = camera.projectionMatrix;
        }

        public void DrawObject(RenderingObject obj)
        {
            ProfilerManager.BeginSample("JObRasterizer.DrawObject");

            var mesh = obj.mesh;
            _modelMatrix = obj.GetModelMatrix();
            var mvp = _projectionMatrix * _viewMatrix * _modelMatrix;

            if (_config.FrustumCulling && TinyRenderUtils.FrustumCulling(mesh.bounds, mvp))
            {
                ProfilerManager.EndSample();
                return;
            }

            var normalMatrix = _modelMatrix.inverse.transpose;

            _verticesAll += mesh.vertexCount;
            _trianglesAll += obj.cpuData.MeshTriangles.Length / 3;

            // -------------- Vertex Shader --------------
            var vsOutput = new NativeArray<VSOutBuf>(mesh.vertexCount, Allocator.TempJob);
            VertexJob vsJob = new VertexJob();
            vsJob.positionData = obj.jobData.positionData;
            vsJob.normalData = obj.jobData.normalData;
            vsJob.mvpMatrix = mvp;
            vsJob.modelMatrix = _modelMatrix;
            vsJob.normalMatrix = normalMatrix;
            vsJob.result = vsOutput;
            var vsHandle = vsJob.Schedule(vsOutput.Length, 1);

            // -------------- Fragment Shader --------------
            TriangleJob triJob = new TriangleJob();
            triJob.trianglesData = obj.jobData.trianglesData;
            triJob.uvData = obj.jobData.uvData;
            triJob.vsOutput = vsOutput;
            triJob.frameBuffer = frameBuffer;
            triJob.depthBuffer = depthBuffer;
            triJob.screenWidth = _width;
            triJob.screenHeight = _height;
            triJob.textureData = obj.texture.GetPixelData<TRColor24>(0);
            triJob.textureWidth = obj.texture.width;
            triJob.textureHeight = obj.texture.height;
            triJob.useBilinear = _config.BilinearSample;
            triJob.fsType = _config.FragmentShaderType;
            triJob.Uniforms = uniforms;
            JobHandle triHandle = triJob.Schedule(obj.jobData.trianglesData.Length, 2, vsHandle);
            triHandle.Complete();

            vsOutput.Dispose();

            ProfilerManager.EndSample();
        }

        public void UpdateFrame()
        {
            ProfilerManager.BeginSample("JObRasterizer.UpdateFrame");
            switch (_config.DisplayBuffer)
            {
                case DisplayBufferType.Color:
                    frameBuffer.CopyTo(tempBuffer);
                    texture.SetPixels(tempBuffer);
                    break;
                case DisplayBufferType.DepthRed:
                case DisplayBufferType.DepthGray:
                    for (int i = 0; i < depthBuffer.Length; i++)
                    {
                        // depth_buf中的值范围是[0,1]，且最近处为1，最远处为0。因此可视化后背景是黑色
                        float d = depthBuffer[i];
                        if (_config.DisplayBuffer == DisplayBufferType.DepthRed)
                        {
                            tempBuffer[i] = new Color(d, 0, 0);
                        }
                        else
                        {
                            tempBuffer[i] = new Color(d, d, d);
                        }
                    }
                    texture.SetPixels(tempBuffer);
                    break;
                default:
                    break;
            }
            texture.Apply();
            if (onRasterizerStatUpdate != null)
            {
                onRasterizerStatUpdate(_verticesAll, _trianglesAll, _trianglesRendered);
            }

            ProfilerManager.EndSample();
        }
    }
}

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace TinyRenderer
{
    public class CameraRenderer : MonoBehaviour
    {
        Camera _camera;
        public RawImage rawImage;

        [SerializeField]
        private Light _mainLight;

        private List<RenderingObject> _renderObjects = new List<RenderingObject>();

        IRasterizer _rasterizer;
        IRasterizer _lastRasterizer;

        CPURasterizer _cpuRasterizer;

        public RenderingConfig renderConfig;
        StatsPanel _statsPanel;

        bool _lastUseUnityNativeRendering;

        private void Start()
        {
            Init();
            _lastUseUnityNativeRendering = renderConfig.UseUnityNativeRenderer;
            ToggleUnityRenderer();
        }


        private void OnEnable()
        {
            RenderPipelineManager.endCameraRendering += RenderPipelineManagerOnendCameraRendering;
        }

        private void OnDisable()
        {
            RenderPipelineManager.endCameraRendering -= RenderPipelineManagerOnendCameraRendering;
        }

        private void RenderPipelineManagerOnendCameraRendering(ScriptableRenderContext arg1, Camera arg2)
        {
            OnPostRender();
        }

        private void OnPostRender()
        {
            //Debug.Log("OnPostRender");
            if (!renderConfig.UseUnityNativeRenderer)
            {
                Render();
            }
            if (_lastUseUnityNativeRendering != renderConfig.UseUnityNativeRenderer)
            {
                ToggleUnityRenderer();
                _lastUseUnityNativeRendering = renderConfig.UseUnityNativeRenderer;
            }
        }

        void ToggleUnityRenderer()
        {
            if (renderConfig.UseUnityNativeRenderer)
            {
                rawImage.gameObject.SetActive(false);
                _camera.cullingMask = 0xfffffff;
                _statsPanel.SetRasterizerType("Unity Native");
            }
            else
            {
                rawImage.gameObject.SetActive(true);
                _camera.cullingMask = 0;
                if (_rasterizer != null)
                {
                    _statsPanel.SetRasterizerType(_rasterizer.Name);
                }
            }
        }

        void Init()
        {
            _camera = GetComponent<Camera>();

            var rootObjs = this.gameObject.scene.GetRootGameObjects();
            _renderObjects.Clear();
            foreach (var obj in rootObjs)
            {
                _renderObjects.AddRange(obj.GetComponentsInChildren<RenderingObject>());
            }

            Debug.Log($"Found rendering objects: {_renderObjects.Count}");

            RectTransform rect = rawImage.rectTransform;
            rect.sizeDelta = new Vector2(Screen.width, Screen.height);
            int w = Mathf.FloorToInt(rect.rect.width);
            int h = Mathf.FloorToInt(rect.rect.height);
            Debug.Log($"screen size: {w}x{h}");

            _cpuRasterizer = new CPURasterizer(w, h, renderConfig);
            _lastRasterizer = null;

            _statsPanel = this.GetComponent<StatsPanel>();
            if (_statsPanel != null)
            {
                _cpuRasterizer.onRasterizerStatUpdate += _statsPanel.StatDelegate;
            }

        }

        private void OnDestroy()
        {
            _cpuRasterizer.Release();
        }

        /// <summary>
        /// 渲染方法
        /// </summary>
        void Render()
        {
            ProfilerManager.BeginSample("CameraRenderer.Render");
            switch (renderConfig.RasterizerType)
            {
                case RasterizerType.CPU:
                    _rasterizer = _cpuRasterizer;
                    break;
                case RasterizerType.CPUJobs:
                    break;
                case RasterizerType.GPUDriven:
                    break;
            }

            if (_rasterizer != _lastRasterizer)
            {
                Debug.Log($"Change Rasterizer to {_rasterizer.Name}");
                _lastRasterizer = _rasterizer;

                rawImage.texture = _rasterizer.ColorTexture;
                _statsPanel.SetRasterizerType(_rasterizer.Name);
            }

            _rasterizer.Clear(BufferMask.Color | BufferMask.Depth);
            _rasterizer.SetupUniforms(_camera, _mainLight);

            for (int i = 0; i < _renderObjects.Count; i++)
            {
                if (_renderObjects[i].gameObject.activeInHierarchy)
                {
                    _rasterizer.DrawObject(_renderObjects[i]);
                }
            }

            _rasterizer.UpdateFrame();

            ProfilerManager.EndSample();
        }
    }
}

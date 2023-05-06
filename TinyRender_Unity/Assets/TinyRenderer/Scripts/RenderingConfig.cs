using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor.Rendering;
using UnityEngine;

namespace TinyRenderer
{
    [CreateAssetMenu(menuName = "TinyRenderer/RenderingConfig")]
    public class RenderingConfig : ScriptableObject
    {
        [Header("Common Setting")]
        public Color ClearColor = Color.black;
        public Color AmbientColor = Color.black;
        public RasterizerType RasterizerType;
        public bool UseUnityNativeRenderer;

        [Header("CPU Rasterizer ONLY Setting")]
        public bool WireframeMode = false;
        public bool FrustumCulling = true;
        public bool BackfaceCulling = true;
        public DisplayBufferType DisplayBuffer = DisplayBufferType.Color;

        public MSAALevel MSAA = MSAALevel.Disabled;
        public bool BilinearSample = true;
        public ShaderType FragmentShaderType = ShaderType.BlinnPhong;

        public Color[] VertexColors;

        [Header("GPU Driven Setting")]
        public ComputeShader ComputeShader;
    }

    public enum DisplayBufferType
    {
        Color,
        DepthRed,
        DepthGray
    }

    public enum MSAALevel
    {
        Disabled,
        X2 = 2,
        X4 = 4
    }

}

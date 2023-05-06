using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TinyRenderer
{
    public interface IRasterizer
    {
        string Name { get; }

        Texture ColorTexture { get; }

        void Clear(BufferMask mask);

        void SetupUniforms(Camera camera, Light mainLight);

        void DrawObject(RenderingObject obj);

        void UpdateFrame();

        void Release();

    }
}

using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace TinyRenderer
{
    public class StatsPanel : MonoBehaviour
    {
        public TMP_Text RasterizerType;

        public TMP_Text FpsText;
        public TMP_Text TrianglesStat;
        public TMP_Text VerticesStat;

        public FpsCounter fpsCounter;

        private void Update()
        {
            FpsText.text = $"FPS:{fpsCounter.FPS.ToString("F2")}";
        }

        public void StatDelegate(int vertices, int triangles, int trianglesRendered)
        {
            TrianglesStat.text = $"Triangles: {trianglesRendered} / {triangles}";
            VerticesStat.text = $"Vertices: {vertices}";
        }

        public void SetRasterizerType(string typeStr)
        {
            RasterizerType.text = typeStr;
        }
    }
}

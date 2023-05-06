using System.Collections;
using UnityEngine;
using static UnityEngine.UISystemProfilerApi;

namespace TinyRenderer
{
    public class FpsCounter : MonoBehaviour
    {
        public float SampleTime = 1f;

        private float _fps;
        public float FPS => _fps;

        int frameCount;
        float timeTotal;

        void Start()
        {
            frameCount = 0;
            timeTotal = 0;
        }

        void Update()
        {
            ++frameCount;
            timeTotal += Time.unscaledDeltaTime;
            if (timeTotal >= SampleTime)
            {
                _fps = frameCount / timeTotal;
                frameCount = 0;
                timeTotal = 0;
            }
        }
    }
}

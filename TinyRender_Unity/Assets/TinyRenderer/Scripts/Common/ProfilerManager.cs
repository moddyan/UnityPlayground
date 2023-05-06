using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TinyRenderer
{
    public sealed class ProfilerManager
    {
        public bool EnableProfile;

        public static void BeginSample(string name)
        {
#if ENABLE_PROFILE
        Profiler.BeginSample(name);
#endif
        }

        public static void EndSample()
        {
#if ENABLE_PROFILE
        Profiler.EndSample();
#endif
        }
    }
}

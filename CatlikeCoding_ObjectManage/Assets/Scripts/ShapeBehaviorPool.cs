using System.Collections.Generic;
using UnityEngine;

public static class ShapeBehaviorPool<T> where T : ShapeBehavior, new()
{
    static Stack<T> stack = new Stack<T>();

    public static T Get()
    {
        if (stack.Count > 0)
        {
            return stack.Pop();
        }
        return new T();
    }

    public static void Reclaim(T behavior)
    {
        stack.Push(behavior);
    }

}
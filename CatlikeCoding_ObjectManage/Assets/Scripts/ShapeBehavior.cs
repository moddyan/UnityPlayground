using UnityEngine;

public abstract class ShapeBehavior 
{
    public abstract void GameUpdate(Shape shape);

    public abstract void Save(GameDataWriter writer);

    public abstract void Load(GameDataReader reader);

    public abstract void Recycle ();

    public abstract ShapeBehaviorType BehaviorType { get; }

}

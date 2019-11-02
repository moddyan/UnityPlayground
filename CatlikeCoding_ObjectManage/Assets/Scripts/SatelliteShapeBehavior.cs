using UnityEngine;

public sealed class SatelliteShapeBehavior : ShapeBehavior
{

    public override ShapeBehaviorType BehaviorType
    {
        get
        {
            return ShapeBehaviorType.Satellite;
        }
    }

    public override void GameUpdate(Shape shape) { }

    public override void Save(GameDataWriter writer) { }

    public override void Load(GameDataReader reader) { }

    public override void Recycle()
    {
        ShapeBehaviorPool<SatelliteShapeBehavior>.Reclaim(this);
    }
}
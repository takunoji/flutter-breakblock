import 'package:flame/components.dart';
import 'package:flutter_breakout_game/ball.dart';
import 'package:flutter_breakout_game/game.dart';

class BreakableBlock extends RectangleComponent
    with Collidable, HasGameRef<GameLoop> {
  BreakableBlock(size, position) : super(size: size, position: position);

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is Ball) {
      gameRef.gameLoopState.incrementScore();
      gameRef.remove(this);
    }
  }
}

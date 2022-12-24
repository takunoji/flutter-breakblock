import 'package:flame/components.dart';
import 'package:flutter_breakout_game/block.dart';
import 'package:flutter_breakout_game/game.dart';
import 'package:flutter_breakout_game/paddle.dart';

class Ball extends CircleComponent with Collidable, HasGameRef<GameLoop> {
  var dx = 5;
  var dy = 5;
  static const radius = 20.0;

  Ball(radius, position) : super(radius: radius, position: position);

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is ScreenCollidable && x + dx + radius / 2 < 0) {
      // ウィンドウの左と衝突
      dx *= -1;
    } else if (x + dx + radius / 2 > gameRef.canvasSize.x) {
      // ウィンドウの右と衝突
      dx *= -1;
    } else if (other is ScreenCollidable && y + dy + radius / 2 < 0) {
      // ウィンドウの上底と衝突
      dy *= -1;
    } else if (y + dy + radius / 2 > gameRef.canvasSize.y) {
      // ウィンドウの下底と衝突
      gameRef.gameLoopState.gameOver();
    } else if (other is BreakableBlock) {
      dy *= -1;
    } else if (other is Paddle) {
      dy *= -1;
    }
  }

  @override
  void update(double dt) {
    position = Vector2(x + dx, y + dy);
  }
}

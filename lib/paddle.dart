import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breakout_game/game.dart';

class Paddle extends RectangleComponent
    with Collidable, KeyboardHandler, HasGameRef<GameLoop> {
  final _dx = 15;
  var _isRightPressed = false;
  var _isLeftPressed = false;
  var _isRightScreenCollided = false;
  var _isLeftScreenCollided = false;

  Paddle(size, position) : super(size: size, position: position);

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyUpEvent) {
      _isLeftPressed = false;
      _isRightPressed = false;
      return true;
    }
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        _isLeftPressed = true;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        _isRightPressed = true;
      }
    }
    return true;
  }

  @override
  void onGameResize(Vector2 gameSize) {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is ScreenCollidable && x < 0) {
      _isLeftScreenCollided = true;
    }
    if (other is ScreenCollidable && x + width > gameRef.canvasSize.x) {
      _isRightScreenCollided = true;
    }
  }

  @override
  void update(double dt) {
    if (_isRightPressed && !_isRightScreenCollided) {
      x += _dx;
      _isLeftScreenCollided = false;
    }
    if (_isLeftPressed && !_isLeftScreenCollided) {
      x -= _dx;
      _isRightScreenCollided = false;
    }
  }
}

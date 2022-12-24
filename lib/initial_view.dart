import 'package:flutter/material.dart';
import 'package:flutter_breakout_game/game.dart';

class InitialView extends StatelessWidget {
  const InitialView({Key? key, required this.gameLoop}) : super(key: key);

  final GameLoop gameLoop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () => gameLoop.overlays.remove('initial'),
          child: const Text('Start')),
    );
  }
}

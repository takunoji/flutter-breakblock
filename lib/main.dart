import 'package:flutter/material.dart';
import 'package:flutter_breakout_game/game.dart';

void main() {
  // ビルドメソッドでゲームをインスタンス化すると、Flutterツリーが再構築されるたびにゲームが再構築されます。
  // これは通常、必要以上に頻繁に行われます。これを回避するには、代わりに、最初にゲームのインスタンスを作成し、
  // 上記の例で行われているように、ウィジェット構造内でそれを参照することができます。
  runApp(
    MaterialApp(
      home: GameLoopWidget(),
    ),
  );
}

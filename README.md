# breakout-game

![output](https://user-images.githubusercontent.com/18514782/150683500-f9e8f4af-1601-4705-8c55-1b8fefa19961.gif)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



@kawamou
投稿日 2022年01月26日

更新日 2022年06月27日

# Flutterでゲーム作り入門
[はじめに](#はじめに)   
[サマリ](#サマリ)   
[対象読者]    
[環境]    
[Flame入門]   
[概要]    
[Flameの基本的な概念]   
[ブロック崩し実装編]    
[FlutterにFlameを組み込む方法]    
[ゲームのキャンバス上にウィジェットを重ねる方法]    
[スタート画面を実装する方法]    
[コンポーネントからゲームの状態を取得する方法]    
[衝突判定の方法]    
[状態管理の方法]    
[ユーザ入力の方法]    
[追加済みのコンポーネントをゲームループ内で参照する方法]    
[まとめ]    
[参考]    

## はじめに
## サマリ
Flutter × Flameで2Dゲームを作りました👶 題材はブロック崩しです。
Flameの簡単な入門や、ブロック崩しを実装する上でのTips等々を書いていこうと思います。
ソースコードはこちらです。

[GitHub - kawamou/breakout-game](https://github.com/)

## 対象読者
* Flutterで2Dゲームを作ってみたい方
* Flameを使う最低限の概念を把握したい方
## 環境
```
Flutter 2.8.0
Flame 1.0.0
```
* Flameは1.0.0になりAPIに結構な変更が入ったので、過去記事を読む際には注意が必要かもです。

## Flame入門
### 概要
FlameはFlutterで2Dゲームを作る際に便利なゲームエンジン（パッケージ）です。
ゲームループや様々なコンポーネント、衝突検出等々、ゲームを作る際に必要な諸々が準備されています。

インストール方法は公式サイトが詳しいです。

Getting Started! - Flame

### Flameの基本的な概念
Flameに限らず、ゲームプログラムは停止するまで周り続けるゲームループが基本的な構造です。
疑似コードで表すならこんな感じでしょうか。

```
pseudo_gameloop.dart
while {
    update();
    ...
    render();
    ...
  }
```
ビデオゲームの解剖学

キャラクターの位置等の「状態」を更新するupdate()、更新した「状態」をもとに画面を描画するrender()等がゲームループに用意されています。
これらが毎ループ呼び出され、更新、描画、更新、描画...が繰り返されゲームが進行します。

Flameでも同様にFlameGameというゲームループが準備されています1。

Flameの素朴な使い方は、

1. `FlameGame`を継承したゲームループを作成
2. `PositionComponent`等のコンポーネントをゲームループに追加
3. ゲームループが、追加された各コンポーネントの`update` `render`メソッド等をループ毎に自動でチェック
です。
ゲームループがコンポーネントのメソッドを自動でチェックするという考え方が非常に重要です。

例えばコンポーネント同士の衝突を検知したい場合、該当のコンポーネントにCollidableをwithすると、コンポーネントにonCollisionメソッドが生えます。
このonCollision内部に衝突時の処理を記述するわけです。
ただし、このままではゲームループはonCollisionメソッドをチェックしてくれません。
ゲームループ側にもHasCollidablesをwithすることで、ゲームループが各コンポーネントのonCollisionを毎ループチェックしてくれるようになります。

example.dart
class MyGameLoop extends FlameGame with HasCollidables {
  ...
}

class MyComponent extends PositionComponent with Collidable {
  ...
}
このように、コンポーネントに適用したMixinに対応するMixinをゲームループに適用して、毎ループチェックする必要があるメソッドを教えてあげることでゲームをどんどんリッチにしていくのがFlameの基本方針です。

ブロック崩し実装編
ディレクトリ構成はこんな感じです。
小さなアプリケーションなので、FlameのコンポーネントもFlutterのウィジェットも全てlib直下に置いてます。

dir.md
...
├── lib 
│   ├── ball.dart # ブロック崩しのボール
│   ├── block.dart # ボールをぶつけて破壊するブロック
│   ├── game.dart # FlameGameを継承したゲームループ
│   ├── gameover_view.dart # ゲームが終了した際に描画されるWidget
│   ├── initial_view.dart # ゲーム開始時に描画されるWidget
│   ├── paddle.dart # ボールを打ち返す棒
│   └── main.dart # main関数
...
以降、実装する上でのTipsを、ソースコードベースで振り返っていきます。

FlutterにFlameを組み込む方法
FlameGameを継承したゲームループをインスタンス化し、GameWidgetに渡すことでFlutterツリーに追加されます。

main.dart
class GameLoopWidget extends StatelessWidget {
  ...
  final gameLoop = GameLoop(GameLoopState(0, false));

  @override
  Widget build(BuildContext context) {
    ...
    return Center(
        ...
        child: GameWidget(
          game: gameLoop, // ココ
          ...
        ),
      ),
    );
  }
}
Note: If you instantiate your game in a build method your game will be rebuilt every time the Flutter tree gets rebuilt, which usually is more often than you’d like. To avoid this, you can instead create an instance of your game first and reference it within your widget structure, like it is done in the example above.

FlameGame

公式ドキュメントにもあるように、ビルドメソッド内でゲームをインスタンス化すると、Flutterツリーがリビルドされるたびにゲームが再構築されコストが高く、ビルドメソッド外でインスタンス化することが重要です。

ゲームのキャンバス上にウィジェットを重ねる方法
ブロック崩しのスタート画面やゲーム終了画面としてボタンやスコアを持ったウィジェットを表示しています。
こんな感じのやつです。

image
ゲームのキャンバスにFlutterのウィジェットを重ねて表示したい場合はoverlaysを利用します。
GameWidgetのoverlayBuilderMapに重ねて表示したいウィジェットを登録します。
今回の場合だとInitialViewとGameOverViewのふたつのウィジェットを登録しています。

main.dart
class GameLoopWidget extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    ...
    return Center(
        ...
        child: GameWidget(
          ...
          overlayBuilderMap: {
            'initial': (context, GameLoop gameLoop) => InitialView(
                  gameLoop: gameLoop,
                ),
            'gameover': (context, GameLoop gameLoop) =>
                GameOverView(gameLoop: gameLoop),
          },
          initialActiveOverlays: const ['initial'],
        ),
      ),
    );
  }
}
overlaysプロパティはゲームループ内から自由に参照できます。
overlays.add('initial')を呼べば、overlayBuilderMapで登録されたInitialViewがゲーム画面に重ねて表示されます。
反対に、overlays.remove('initial')で取り除くことができたりします。

スタート画面を実装する方法
スタート画面として、InitialViewウィジェットを作りました。
ボタンを押すとゲームが開始されるだけの簡単な画面です。

image.png

GameWidgetのinitialActiveOverlaysにゲームが開始した際に前面に来るウィジェットを登録できます。

main.dart
class GameLoopWidget extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    ...
    return Center(
        ...
        child: GameWidget(
          ...
          initialActiveOverlays: const ['initial'],
        ),
      ),
    );
  }
}
ただし、単に登録しただけでは、ウィジェットは重なるもののゲームも同時にスタートしてしまいます。
ゲームループのpausedプロパティをtrueにすることでゲームループの一時停止が可能です2。

game.dart
@override
  void onMount() {
  paused = true;
  ...
}
次に「Start」ボタンを押した際にゲームが開始されるようにしたいです。
まず、ボタンを押すとoverlays.remove(initial)が呼ばれるようにします。

initial_view.dart
class InitialView extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () => gameLoop.overlays.remove('initial'),
          child: const Text('Start')),
    );
  }
}
加えてoverlays.addListener()でoverlaysプロパティの変更を検知して呼び出されるコールバック関数を登録し、ゲームが開始されるようにしました。

game.dart
class GameLoop extends FlameGame
    with HasCollidables, HasKeyboardHandlerComponents {
  ...
  void onOverlayChanged() {
    if (overlays.isActive('initial')) {
      pauseEngine();
    } else {
      resumeEngine(); // ゲームを開始
    }
  }
  ...
  @override
  void onMount() {
    paused = true;
    overlays.addListener(onOverlayChanged);
    super.onMount();
  }
  ...
}
下記の実装を参考にさせていただきました。

moonlander/main.dart at 975da465aa217c5c8bbd37c1b8fe9a237ee0f4cc · wol...
https://github.com


コンポーネントからゲームの状態を取得する方法
ゲームループにコンポーネントを追加するというFlameの性質上、基本的な依存の向きは「ゲームループ → コンポーネント」になるかと思います。
ただし、時にコンポーネントからゲームループのプロパティやメソッドを参照したくなる場合があります。
例えば、ゲームのキャンバスサイズを取得したいときです。
この場合、コンポーネントにHasGameRefを適用します。

ball.dart
class Ball extends CircleComponent with Collidable, HasGameRef<GameLoop> {
  ...
}
HasGameRefを追加すれば、gameRef.canvasSize.xといったように、gamerefプロパティからゲームループのメソッドや要素にアクセスできるようになります。
多用すると処理が追いづらくなりそうですが、利用価値は高そうです。

衝突判定の方法
前述の通り、コンポーネントにCollidableを、ゲームループにHasCollidablesを適用することで衝突を判定できるようになります。
画面との衝突を検知する場合、ScreenCollidableをゲームループに追加してあげる必要があります。

game.dart
@override
Future<void>? onLoad() async {
  ...
  add(ScreenCollidable()); // 画面との衝突を検知
  ...
}
onCollisionの第二引数であるotherに衝突したコンポーネントの型が入っているので、other is FooでFoo型との衝突かどうかを判定できます。

ball.dart
void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
  if (other is ScreenCollidable && x + dx + radius / 2 < 0) {
  ...
  } else if (other is BreakableBlock) {
  ...
  } else if (other is Paddle) {
  ...
  }
}
状態管理の方法
スコア（ブロックを何個壊したか）やゲーム終了（ボールが画面の下に到達）等の状態をどこで管理するか悩みました。
現状はゲームループに自作のGameLoopStateのインスタンスを持たせて、各コンポーネントからgamerefプロパティ経由で参照するようにしています。

game.dart
class GameLoop extends FlameGame
    with HasCollidables, HasKeyboardHandlerComponents {
  ...
  final GameLoopState gameLoopState;
  ...
}

// ゲームの状態を管理
class GameLoopState {
  int score;
  bool isGameOver;

  GameLoopState(this.score, this.isGameOver);

  void reset() {
    score = 0;
    isGameOver = false;
  }

  void incrementScore() {
    score++;
  }

  void gameOver() {
    isGameOver = true;
  }
}

Flameのコンポーネントはウィジェットではないので、Flutterの様々な状態管理パッケージは使えません（flame_bloc等はあるっぽい）。
ブロック崩し程度ならちゃんと状態管理を設計しなくても大丈夫ですが、ある程度スケールするゲームの場合はちゃんと考えなければダメそうです（知見求む🙇‍♂️）。

ユーザ入力の方法
ボールを跳ね返す棒（Paddle）はキーボードの矢印キーで操作します。
モバイルを想定するとジョイスティック等で動かせるべきですが怠慢してます...。
衝突検知を行いたいときと考え方は同じで、ゲームループとコンポーネントそれぞれにHasKeyboardHandlerComponents KeyboardHandlerを適用します。

game.dart
class GameLoop extends FlameGame
    with HasCollidables, HasKeyboardHandlerComponents {
  ...
}
paddle.dart
class Paddle extends RectangleComponent
    with Collidable, KeyboardHandler, HasGameRef<GameLoop> {
  ...
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  ...
  }
}
追加済みのコンポーネントをゲームループ内で参照する方法
ゲームループに追加したコンポーネントはchildrenプロパティに入っています。
children.query<Foo>()を用いることでゲームループに追加されたFoo型のコンポーネントを取得することができます。
一点注意としては、queryを発行したい型は事前にchildren.register<Foo>()によって登録しておく必要があります。

game.dart
class GameLoop extends FlameGame
    with HasCollidables, HasKeyboardHandlerComponents {
  ...
  @override
  void update(double dt) {
    ...
    var allBlocks = children.query<BreakableBlock>();
    var ball = children.query<Ball>();
    ...
  }

  ...

  @override
  Future<void>? onLoad() async {
    ...
    children.register<BreakableBlock>();
    children.register<Ball>();
  }
}
まとめ
FlutterとFlameを使って、ブロック崩しゲームを作りました。
特に引っ掛かる部分はなく、簡単な2Dゲームなら素早く作れる気がしました。
ただし、やはりゲームなので手続き的に書く部分がかなり多くFlutterとは少し違う筋肉を使う感じがしました。
とはいえ、何よりWebでもモバイルでもどちらでも動くゲームがササっと作れるのはサイコーですね！
次はもう少し複雑なゲームを作成してみたいです。

参考
2D breakout game using pure JavaScript
正確にはFlameGameを使わなくてもゲームループは作れます ↩

こちらを参考にしました ↩


share


新規登録して、もっと便利にQiitaを使ってみよう

あなたにマッチした記事をお届けします
便利な情報をあとで効率的に読み返せます
ログインすると使える機能について
kawamou
@kawamou
Go, Google Cloud, AWS SAA, GCP PCA, Developer👶 @通信会社
rss_feed


関連記事 Recommended by 

[Flutter用ゲームエンジン] Flutter \u0026 Flame 試してみた
by LAGALIN


Android開発者のためのFlutter説明文がためになったので全訳\u0026要約
by coka__01

React NativeとFlutterのレンダリングアーキテクチャ
by sooch

Flutterの2DゲームエンジンFlameはドット絵ゲーム作成におすすめ👾
by keidroid

ご存じですか？月々500円で入院・手術・死亡を保障
PR 愛知県共済

これからのエンジニアが身につけたい「社会課題への解決力」をModisに聞いてみた
PR Modis株式会社
link
この記事は以下の記事からリンクされています
kawamou
ただ🐈が歩き回るだけのゲーム作った
からリンク
10 months ago
コメント

この記事にコメントはありません。
あなたもコメントしてみませんか :)
すでにアカウントを持っている方はログイン
How developers code is here.
© 2011-2022Qiita Inc.
ガイドとヘルプ
About
利用規約
プライバシーポリシー
ガイドライン
デザインガイドライン
ご意見
ヘルプ
広告掲載
コンテンツ
リリースノート
公式イベント
公式コラム
募集
アドベントカレンダー
Qiita 表彰プログラム
API
SNS

Qiita（キータ）公式

Qiita マイルストーン

Qiita 人気の投稿

Qiita（キータ）公式
Qiita 関連サービス
Qiita Team
Qiita Jobs
Qiita Zine
Qiita 公式ショップ
運営
運営会社
採用情報
Qiita Blog
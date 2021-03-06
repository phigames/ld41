library ld41;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'baselevel.dart';
part 'minilevel.dart';

Stage stage;
RenderLoop renderLoop;
ResourceManager resources;
Random random;

Game game;

Future<Null> main() async {
  stage = new Stage(
    html.querySelector('#stage'),
    width: Game.WIDTH, height: Game.HEIGHT,
    options: new StageOptions()
      ..backgroundColor = 0xFFCCCCCC
      ..renderEngine = RenderEngine.WebGL
      ..antialias = true);

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  
  resources = new ResourceManager();
  resources.addSound('song', 'music/song.ogg');
  resources.addSound('ticktack', 'music/ticktack.ogg');
  resources.addSound('checkpoint', 'music/checkpoint.ogg');

  await resources.load();

  random = new Random();

  game = new Game();
}

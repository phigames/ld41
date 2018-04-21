library ld41;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'baselevel.dart';

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
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL);

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  
  resources = new ResourceManager();
  //resources.addBitmapData('name', 'images/name.png');
  //resources.addSound('name', 'sounds/name.png');

  await resources.load();

  random = new Random();

  game = new Game();
}

part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

  BaseLevel baseLevel;

  Game() {
    baseLevel = new BaseLevel();
    stage.addChild(baseLevel.sprite);

    stage.onEnterFrame.listen(enterFrame);
    html.document.onKeyDown.listen(keyDown);
  }

  void enterFrame(EnterFrameEvent event) {
    baseLevel.update(event.passedTime);
  }

  void keyDown(html.KeyboardEvent event) {
    print('asdf');
    if (event.keyCode == html.KeyCode.UP) {
      baseLevel.upPressed();
    }
  }

}
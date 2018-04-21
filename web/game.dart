part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

  Level level;

  Game() {
    //baseLevel = new BaseLevel();
    //stage.addChild(baseLevel.sprite);
    level = new MiniLevel(MiniLevel.LEVEL_1);
    stage.addChild(level.sprite);

    stage.onEnterFrame.listen(enterFrame);
    html.document.onKeyDown.listen(keyDown);
  }

  void enterFrame(EnterFrameEvent event) {
    level.update(event.passedTime);
  }

  void keyDown(html.KeyboardEvent event) {
    switch (event.keyCode) {
      case html.KeyCode.LEFT:
        level.leftPressed();
        break;
      case html.KeyCode.UP:
        level.upPressed();
        break;
      case html.KeyCode.RIGHT:
        level.rightPressed();
        break;
      case html.KeyCode.DOWN:
        level.downPressed();
        break;
    }
  }

}

abstract class Level {

  Sprite sprite;

  void leftPressed();

  void upPressed();

  void rightPressed();

  void downPressed();

  void update(num time);

}
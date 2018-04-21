part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

  Level currentLevel;

  Game() {
    setLevel(new BaseLevel());
    //currentLevel = new MiniLevel(MiniLevel.LEVEL_1);
    //stage.addChild(currentLevel.sprite);

    stage.onEnterFrame.listen(enterFrame);
    html.document.onKeyDown.listen(keyDown);
  }

  void setLevel(Level level) {
    if (currentLevel != null) {
      stage.removeChild(currentLevel.sprite);
    }
    currentLevel = level;
    stage.addChild(level.sprite);
  }

  void enterFrame(EnterFrameEvent event) {
    currentLevel.update(event.passedTime);
  }

  void keyDown(html.KeyboardEvent event) {
    switch (event.keyCode) {
      case html.KeyCode.LEFT:
        currentLevel.leftPressed();
        break;
      case html.KeyCode.UP:
        currentLevel.upPressed();
        break;
      case html.KeyCode.RIGHT:
        currentLevel.rightPressed();
        break;
      case html.KeyCode.DOWN:
        currentLevel.downPressed();
        break;
      case html.KeyCode.R:
        currentLevel.rPressed();
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

  void rPressed();

  void update(num time);

}
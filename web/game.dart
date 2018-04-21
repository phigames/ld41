part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

  Level currentLevel;
  bool upPressed;

  Game() {
    setLevel(new BaseLevel());
    upPressed = false;
    stage.onEnterFrame.listen(enterFrame);
    html.document.onKeyDown.listen(keyDown);
    html.document.onKeyUp.listen(keyUp);
  }

  void setLevel(Level level) {
    stage.removeChildren();
    currentLevel = level;
    stage.addChild(level.sprite);
  }

  void enterFrame(EnterFrameEvent event) {
    //if (event.passedTime < 0.1) { // skip lagging frames
      currentLevel.update(event.passedTime);
    //}
  }

  void keyDown(html.KeyboardEvent event) {
    switch (event.keyCode) {
      case html.KeyCode.LEFT:
        currentLevel.leftPressed();
        break;
      case html.KeyCode.UP:
        upPressed = true;
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

  void keyUp(html.KeyboardEvent event) {
    switch (event.keyCode) {
      case html.KeyCode.UP:
        upPressed = false;
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
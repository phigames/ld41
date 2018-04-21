part of ld41;

class Game {

  static const num WIDTH = 800, HEIGHT = 450;
  static const num TILE_SIZE = 30;

  BaseLevel baseLevel;

  Game() {
    baseLevel = new BaseLevel();
    stage.addChild(baseLevel.sprite);

    stage.onEnterFrame.listen(enterFrame);
    stage.onKeyDown.listen(keyDown);
  }

  void enterFrame(EnterFrameEvent event) {
    baseLevel.update(event.passedTime);
  }

  void keyDown(KeyboardEvent event) {
    
  }

}
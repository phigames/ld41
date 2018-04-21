part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

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
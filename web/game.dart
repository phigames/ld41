part of ld41;

class Game {

  //static const num TILE_SIZE = 30;
  static const int WIDTH = 32, HEIGHT = 18;

  Sprite startMenu;
  Level currentLevel;
  bool upPressed;
  SoundChannel fadingOutSoundChannel;
  SoundChannel fadingInSoundChannel;
  num fadingProgress;
  Function onFadeComplete = null;

  Game() {
    startMenu = new Sprite();
    makeStartMenu();
    stage.addChild(startMenu);
    //setLevel(new BaseLevel());
    upPressed = false;
    stage.onEnterFrame.listen(enterFrame);
    html.document.onKeyDown.listen(keyDown);
    html.document.onKeyUp.listen(keyUp);
  }

  void makeStartMenu() {
    Sprite startButton = new Sprite();
    num buttonWidth = 10, buttonHeight = 5;
    startButton.graphics.rect((Game.WIDTH - buttonWidth) / 2, (Game.HEIGHT - buttonHeight) / 2, buttonWidth, buttonHeight);
    startButton.graphics.fillColor(0xFFFF0000);
    startButton.onMouseClick.listen((_) {
      stage.removeChild(startMenu);
      setLevel(new BaseLevel());
    });
    startMenu.addChild(startButton);
  }

  void setLevel(Level level) {
    stage.removeChildren();
    currentLevel = level;
    stage.addChild(level.sprite);
  }

  void fadeSound(SoundChannel channelOut, SoundChannel channelIn, {void onComplete() = null}) {
    fadingOutSoundChannel = channelOut;
    fadingInSoundChannel = channelIn;
    fadingProgress = 0;
    onFadeComplete = onComplete;
  }

  void enterFrame(EnterFrameEvent event) {
    if (currentLevel != null) {
    //if (event.passedTime < 0.1) { // skip lagging frames
      currentLevel.update(event.passedTime);
    //}
    }
    if (fadingProgress != null) {
      if (fadingOutSoundChannel != null) {
        fadingOutSoundChannel.soundTransform = new SoundTransform(1 - fadingProgress);
      }
      if (fadingInSoundChannel != null) {
        fadingInSoundChannel.soundTransform = new SoundTransform(fadingProgress);
      }
      fadingProgress += event.passedTime;
      if (fadingProgress > 1) {
        fadingOutSoundChannel.pause();
        fadingProgress = fadingOutSoundChannel = fadingInSoundChannel = null;
        if (onFadeComplete != null) {
          onFadeComplete();
        }
      }
    }
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
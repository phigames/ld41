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
    num buttonWidth = 8, buttonHeight = 3;
    int buttonColor = 0xFF3984C6;
    int buttonColorHover = 0xFF69ABE5; 
    startButton.graphics.rect((Game.WIDTH - buttonWidth) / 2, (Game.HEIGHT - buttonHeight) / 2, buttonWidth, buttonHeight);
    startButton.graphics.fillColor(buttonColor);
    startButton.onMouseOver.listen((_) {
      startButton.graphics.rect((Game.WIDTH - buttonWidth) / 2, (Game.HEIGHT - buttonHeight) / 2, buttonWidth, buttonHeight);
      startButton.graphics.fillColor(buttonColorHover);
    });
    startButton.onMouseOut.listen((_) {
      startButton.graphics.rect((Game.WIDTH - buttonWidth) / 2, (Game.HEIGHT - buttonHeight) / 2, buttonWidth, buttonHeight);
      startButton.graphics.fillColor(buttonColor);
    });
    startButton.onMouseClick.listen((_) {
      stage.removeChild(startMenu);
      setLevel(new BaseLevel());
    });
    startButton.mouseCursor = MouseCursor.POINTER;
    startButton.addChild(
      new TextField("START", new TextFormat("Comfortaa", 2, 0xFFCCCCCC, align: "center"))
        ..x = (Game.WIDTH - buttonWidth) / 2
        ..y = (Game.HEIGHT - buttonHeight) / 2 + 0.3
        ..width = buttonWidth
        ..height = buttonHeight - 0.6
        ..mouseCursor = MouseCursor.POINTER
    );
    startMenu.addChild(startButton);
    startMenu.addChild(
      new TextField("[arrow keys] or [WASD] to move", new TextFormat("Comfortaa", 1, BaseLevelBlock.COLOR_BLOCK, align: "center"))
        ..x = 0
        ..y = Game.HEIGHT - 2
        ..width = Game.WIDTH
    );
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
    if (fadingInSoundChannel != null) {
      fadingInSoundChannel.resume();
    }
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
        fadingProgress = 1;
        if (fadingOutSoundChannel != null) {
          fadingOutSoundChannel.pause();
        }
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
      case html.KeyCode.A:
        currentLevel.leftPressed();
        break;
      case html.KeyCode.UP:
        upPressed = true;
        currentLevel.upPressed();
        break;
      case html.KeyCode.W:
        upPressed = true;
        currentLevel.upPressed();
        break;
      case html.KeyCode.RIGHT:
        currentLevel.rightPressed();
        break;
      case html.KeyCode.D:
        currentLevel.rightPressed();
        break;
      case html.KeyCode.DOWN:
        currentLevel.downPressed();
        break;
      case html.KeyCode.S:
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
      case html.KeyCode.W:
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
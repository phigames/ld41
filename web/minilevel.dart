part of ld41;

class MiniLevel extends Level {

  /* '#' = solid block
   * 'o' = movable block
   * ' ' = air
   * 'P' = player
   * 'G' = goal
   */

  static const String LEVEL_1 =
    """
    #####
    #Po #
    #o oG
    #   #
    #####
    """;
  static const String LEVEL_2 =
    """
    ######
    # o  #
    #o o G
    #Poo #
    ######
    """;
  static const String LEVEL_3 =
    """
    #######
    ## Po #
    # oo ##
    ## ooG
    ##  o #
    ## ####
    #######
    """;
  static const String LEVEL_4 =
    """
    ######
    ## o #
    # oo #
    # # ##
    #  oG
    ## o##
    ## oP#
    ## o #
    ######
    """;
  /* static const String LEVEL_5 =
    """
    #### ##
    #  # ##
    #   o G
    #  #o##
    #   o #
    #ooPo #
    # #o  #
    #  #  #
    #     #
    #######
    """; */

  static final List<String> LEVELS = [ LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4 ];

  Sprite blockSprite;
  String blockString;
  MiniLevelPlayer player;
  List<List<MiniLevelBlock>> blocks;
  BaseLevel baseLevel;
  bool won;

  MiniLevel(this.blockString, this.baseLevel) {
    sprite = new Sprite();
    blockSprite = new Sprite();
    sprite.addChild(blockSprite);
    reset();
    sprite.addChild(
      new TextField("press [R] to restart", new TextFormat("Comfortaa", 1, MiniLevelBlock.COLOR_IMMOVABLE, align: "center"))
        ..x = 0
        ..y = Game.HEIGHT - 2
        ..width = Game.WIDTH
    );
    transitionFromBaseLevel(1);
  }

  void transitionFromBaseLevel(num duration) {
    sprite.addChild(baseLevel.sprite);
    void restoreBaseLevelSprite(Sprite sprite, num x, num y) {
      sprite.x = x;
      sprite.y = y;
      sprite.rotation = 0;
      sprite.alpha = 1;
      baseLevel.sprite.visible = false;
    }
    for (BaseLevelBlock block in baseLevel.blocks) {
      num origX = block.sprite.x;
      num origY = block.sprite.y;
      stage.juggler.add(
        new Tween(block.sprite, duration, Transition.easeOutQuadratic)
          ..animate.x.by(random.nextInt(Game.WIDTH) - Game.WIDTH / 2)
          ..animate.y.by((random.nextInt(2) * 2 - 1) * Game.HEIGHT)
          ..animate.rotation.by(random.nextDouble() * 2 * PI)
          ..animate.alpha.to(0)
          ..delay = 0.3 + random.nextDouble() * 0.1
          ..onComplete = () => restoreBaseLevelSprite(block.sprite, origX, origY)
      );
    }
    num playerX = player.sprite.x;
    num playerY = player.sprite.y;
    player.sprite.x = baseLevel.player.sprite.x + baseLevel.sprite.x - blockSprite.x;
    player.sprite.y = baseLevel.player.sprite.y - blockSprite.y;
    stage.juggler.add(
      new Tween(player.sprite, duration, Transition.easeInOutQuadratic)
        ..animate.x.to(playerX)
        ..animate.y.to(playerY)
        ..delay = 0.4
    );
    baseLevel.player.sprite.visible = false;
    
    for (List<MiniLevelBlock> row in blocks) {
      for (MiniLevelBlock block in row) {
        if (block != null && !(block is MiniLevelPlayer)) {
          num origX = block.sprite.x;
          num origY = block.sprite.y;
          block.sprite.x = (random.nextInt(2) * 2 - 1) * Game.WIDTH;
          block.sprite.y = random.nextInt(Game.HEIGHT) - Game.HEIGHT / 2;
          block.sprite.rotation = random.nextDouble() * 2 * PI;
          block.sprite.alpha = 0;
          stage.juggler.add(
            new Tween(block.sprite, duration, Transition.easeOutQuadratic)
              ..animate.x.to(origX)
              ..animate.y.to(origY)
              ..animate.rotation.to(0)
              ..animate.alpha.to(1)
              ..delay = 0.6 + random.nextDouble() * 0.2
          );
        }
      }
    }
  }

  void transitionToBaseLevel(num duration) {
    baseLevel.player.updateSprite();
    baseLevel.updateSprite();
    baseLevel.sprite.visible = true;
    baseLevel.countdownText.visible = false;
    for (BaseLevelBlock block in baseLevel.blocks) {
      num origX = block.sprite.x;
      num origY = block.sprite.y;
      block.sprite.x = random.nextInt(Game.WIDTH) - Game.WIDTH / 2;
      block.sprite.y = (random.nextInt(2) * 2 - 1) * Game.HEIGHT;
      block.sprite.rotation = random.nextDouble() * 2 * PI;
      block.sprite.alpha = 0;
      stage.juggler.add(
        new Tween(block.sprite, duration, Transition.easeOutQuadratic)
          ..animate.x.to(origX)
          ..animate.y.to(origY)
          ..animate.rotation.to(0)
          ..animate.alpha.to(1)
          ..delay = 0.6 + random.nextDouble() * 0.2
      );
    }
    stage.juggler.add(
      new Tween(player.sprite, duration, Transition.easeInOutQuadratic)
        ..animate.x.to(baseLevel.player.sprite.x + baseLevel.sprite.x - blockSprite.x)
        ..animate.y.to(baseLevel.player.sprite.y - blockSprite.y)
        ..delay = 0.4
        ..onComplete = () {
          baseLevel.player.sprite.visible = true;
          baseLevel.countdownText.visible = true;
          baseLevel.resetCountdown();
          game.setLevel(baseLevel);
        }
    );
    
    for (List<MiniLevelBlock> row in blocks) {
      for (MiniLevelBlock block in row) {
        if (block != null && !(block is MiniLevelPlayer)) {
          stage.juggler.add(
            new Tween(block.sprite, duration, Transition.easeOutQuadratic)
              ..animate.x.to((random.nextInt(2) * 2 - 1) * Game.WIDTH)
              ..animate.y.to(random.nextInt(Game.HEIGHT) - Game.HEIGHT / 2)
              ..animate.rotation.to(random.nextDouble() * 2 * PI)
              ..animate.alpha.to(1)
              ..delay = 0.3 + random.nextDouble() * 0.1
          );
        }
      }
    }
  }

  void reset() {
    blockSprite.removeChildren();
    blocks = new List<List<MiniLevelBlock>>();
    List<String> lines = blockString.trim().split("\n");
    for (int i = 0; i < lines.length; i++) {
      blocks.add(new List<MiniLevelBlock>());
      List<String> chars = lines[i].trim().split('');
      for (int j = 0; j < chars.length; j++) {
        MiniLevelBlock block;
        switch (chars[j]) {
          case "#":
            block = new MiniLevelBlock(i, j, false);
            break;
          case "o":
            block = new MiniLevelBlock(i, j, true);
            break;
          case " ":
            block = null;
            break;
          case "P":
            block = player = new MiniLevelPlayer(i, j);
            break;
          case "G":
            block = new MiniLevelGoal(i, j);
            break;
          default:
            print("MINILEVEL PARSING ERROR: char " + chars[j]);
        }
        blocks[i].add(block);
        if (block != null) {
          blockSprite.addChild(block.sprite);
        }
      }
    }
    blockSprite.x = (Game.WIDTH - blockSprite.width) / 2;
    blockSprite.y = (Game.HEIGHT - blockSprite.height) / 2;
  }

  void leftPressed() {
    if (!won) {
      player.move(-1, 0, blocks);
      checkWon();
    }
  }

  void upPressed() {
    if (!won) {
      player.move(0, -1, blocks);
      checkWon();
    }
  }

  void rightPressed() {
    if (!won) {
      player.move(1, 0, blocks);
      checkWon();
    }
  }

  void downPressed() {
    if (!won) {
      player.move(0, 1, blocks);
      checkWon();
    }
  }

  void rPressed() {
    if (!won) {
      reset();
    }
  }

  void update(num time) { }

  void checkWon() {
    if (player.won) {
      won = true;
      transitionToBaseLevel(1);
    } 
  }

}

class MiniLevelBlock {

  static const int COLOR_MOVABLE = 0xFF9E5E00;
  static const int COLOR_IMMOVABLE = BaseLevelBlock.COLOR_BLOCK;

  Sprite sprite;
  int x, y;
  bool movable;

  MiniLevelBlock(this.x, this.y, this.movable, [bool draw = true]) {
    sprite = new Sprite();
    if (draw) {
      sprite.graphics.rect(0, 0, 1, 1);
      if (movable) {
        sprite.graphics.fillColor(COLOR_MOVABLE);
      } else {
        sprite.graphics.fillColor(COLOR_IMMOVABLE);
      }
    }
    updateSprite(false);
  }

  bool move(int dx, int dy, List<List<MiniLevelBlock>> blocks) {
    if (movable) {
      MiniLevelBlock adjacientBlock = blocks[x + dx][y + dy];
      if (adjacientBlock == null || adjacientBlock.move(dx, dy, blocks)) {
        blocks[x][y] = null;
        blocks[x + dx][y + dy] = this;
        x += dx;
        y += dy;
        updateSprite(true);
        return true;
      }
    }
    return false;
  }

  void updateSprite(bool animate) {
    if (animate) {
      stage.juggler.add(
        new Tween(sprite, 0.1, Transition.easeOutCubic)
          ..animate.x.to(x)
          ..animate.y.to(y)
      );
    } else {
      sprite.x = x;
      sprite.y = y;
    }
  }

}

class MiniLevelPlayer extends MiniLevelBlock {

  static const int COLOR = BaseLevelPlayer.COLOR;
  bool won;

  MiniLevelPlayer(int x, int y) : super(x, y, true, false) {
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(COLOR);
    sprite.pivotX = 0.5;
    sprite.pivotY = 0.5;
    stage.juggler.add(createPulsationTween());
    won = false;
  }

  @override
  void updateSprite(bool animate) {
    if (animate) {
      stage.juggler.add(
        new Tween(sprite, 0.1, Transition.easeOutCubic)
          ..animate.x.to(x + 0.5)
          ..animate.y.to(y + 0.5)
      );
    } else {
      sprite.x = x + 0.5;
      sprite.y = y + 0.5;
    }
  }

  Tween createPulsationTween() {
    return new Tween(sprite, 0.5, Transition.easeInOutQuadratic)
      ..animate.scaleX.to(0.6)
      ..animate.scaleY.to(0.6)
      ..onComplete = () =>
        stage.juggler.add(new Tween(sprite, 0.5, Transition.easeInOutQuadratic)
          ..animate.scaleX.to(0.8)
          ..animate.scaleY.to(0.8)
          ..onComplete = () => stage.juggler.add(createPulsationTween())
        );
  }

}

class MiniLevelGoal extends MiniLevelBlock {

  static const int COLOR = 0xFFEFB834;

  MiniLevelGoal(int x, int y) : super(x, y, false, false) {
    sprite.graphics.circle(0.5, 0.5, 0.4);
    sprite.graphics.fillColor(COLOR);
  }

  @override
  bool move(int dx, int dy, List<List<MiniLevelBlock>> blocks) {
    if (blocks[x - dx][y - dy] is MiniLevelPlayer) {
      (blocks[x - dx][y - dy] as MiniLevelPlayer).won = true;
      stage.juggler.add(
        new Tween(sprite, 0.3, Transition.easeOutQuadratic)
          ..animate.y.by(2)
          ..animate.alpha.to(0)
          ..onComplete = () => sprite.removeFromParent()
      );
      return true;
    }
    return false;
  }

}
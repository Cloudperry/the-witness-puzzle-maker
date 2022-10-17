import std/[strformat, options, tables, sets]
import cligen, nimraylib_now
import levels, levelGfx, geometry, graphs

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

const fontSize = 30

proc doTextEntry(text: var string): bool =
  var key = getCharPressed()
  while key in 32 .. 125:
    text &= key.char
    key = getCharPressed()
  if isKeyPressed(BACKSPACE) and text.len > 0:
    text.setLen(text.len - 1)
  elif isKeyPressed(DELETE) and text.len > 0:
    text.setLen(0)
  elif isKeyPressed(ENTER) and text.len > 0:
    return true

proc game(levels: seq[string]) =
  # Game state could be moved into an object. That would make for example
  # unloading the level extremely simple.
  # Init
  var 
    screenWidth = 1280
    screenHeight = 720
    levelName: string
    level: Level
    drawOptions: DrawOptions 
    drawableLevel: DrawableLevel
    playingLevel: bool
    levelSolved: bool
    currentPointStr: string
    playerLine: Line
  
  proc unloadLevel() =
    level = Level()
    drawOptions = DrawOptions()
    drawableLevel = DrawableLevel()
    playingLevel = false
    levelSolved = false
    playerLine.setLen(0)

  proc loadLevel() =
    level = loadLevelFromFile(levelName)
    drawOptions = DrawOptions()
    drawOptions.setPositionDefaults((screenWidth, screenHeight))
    drawableLevel = level.getDrawableLevel(drawOptions)
    playingLevel = true

  setConfigFlags(MSAA_4X_HINT)
  setConfigFlags(FULLSCREEN_MODE)
  initWindow(screenWidth, screenHeight, "The Witness")
  let monitor = getCurrentMonitor()
  screenWidth = getMonitorWidth(monitor)
  screenHeight = getMonitorHeight(monitor)
  setTargetFPS(getMonitorRefreshRate(monitor))

  if levels.len > 0:
    levelName = levels[0]
    loadLevel()

  while not windowShouldClose(): # Main loop
    # Update
    if not playingLevel:
      if doTextEntry(levelName):
        loadLevel()
    else:
      if not levelSolved:
        if doTextEntry(currentPointStr):
          let point = currentPointStr.parsePoint()
          if point.isSome:
            if playerLine.len == 0 and level.pointData.getOrDefault(point.get) == Start:
              playerLine &= point.get
            elif playerLine.len > 0 and point.get in level.pointGraph and 
            point.get in level.pointGraph.adjList[playerLine[^1]]:
              playerLine &= point.get
              if level.pointData[playerLine[^1]] == End:
                levelSolved = level.checkSolution(playerLine)
            currentPointStr.setLen(0)
        if isKeyDown(C): 
          playerLine.setLen(0)
      else:
        if isKeyPressed(R):
          levelSolved = false
          playerLine.setLen(0)
        elif isKeyPressed(S):
          unloadLevel()

    # Draw
    beginDrawing()
    clearBackground(Darkgray)
    if playingLevel:
      # Draw text
      let textOffsetY = drawableLevel.mazeDistToScreen(
        dist(level.topLeftCorner.y, drawableLevel.topLeft.y) / 2, drawOptions
      )
      let textTop = fmt"playing {levelName}"
      let textTopWidth = measureText(textTop.cstring, fontSize)
      drawText(textTop.cstring, screenWidth div 2 - textTopWidth div 2, textOffsetY, fontSize, Raywhite)
      var textBot = fmt"enter a new point (or press S to clear line): {currentPointStr}"
      if levelSolved:
        textBot = "You have solved the level. Press esc to quit, s to select another level or r to restart the level."
      let textBotWidth = measureText(textBot.cstring, fontSize)
      drawText(textBot.cstring, screenWidth div 2 - textBotWidth div 2, screenHeight - textOffsetY, fontSize, Raywhite)
      # Draw level
      level.draw(drawableLevel.gfxData, drawOptions)
      if playerLine.len > 0:
        level.drawPlayerLine(playerLine, drawableLevel, drawOptions)
    else:
      let text = fmt"Type level name to play and press ENTER: {levelName}" 
      let textWidth = measureText(text.cstring, fontSize)
      # Text is not vertically centered, because using measureTextEx was giving me segfaults
      drawText(text.cstring, screenWidth div 2 - textWidth div 2, 
               screenHeight div 2, fontSize, Raywhite) 
    endDrawing()

  closeWindow()

dispatch game # Automatically generate a CLI that can be used to open a level to play

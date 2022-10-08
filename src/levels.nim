import std/[tables, sets]
import frosty/streams
import graphs

type
  Color* = tuple[r, g, b: int]
  PointKind* = enum ## All the puzzle symbols that can be attached to a point
    Empty, Start, End, Hex
  CellKind* = enum ## All the puzzle symbols that can be attached to a cell
    Empty, Square, Triangle, Star, Block, AntiBlock, Jack
  MazeCell* = object
    # NIMNOTE: Here kind is one field in the object, but the other fields the
    # object has depends on the value of kind. For example squares have a color
    # field, but no shape field and Blocks have the opposite. 
    case kind*: CellKind 
    of Square, Triangle, Star: ## Only these puzzle symbols can have a color
      color*: Color            ## The color will affect the puzzle solution
    of Block, AntiBlock:
      shape*: seq[Point2DInt] ## Polyomino shape as a collection of points.
    else:                     ## (0, 0) is the top left corner of the shape.
      discard
    
  Level* = object
    # A bit later I will add support for arbitrary maze shapes
    # For that the field below will be used to determine the coordinate space of the level
    # borderVertices*: seq[Point2D]
    # Right now the coordinate space of the level is determined by the 2 following fields
    topLeftCorner*: Point2D
    botRightCorner*: Point2D
    pointGraph*: Graph[Point2D]
    cellGraph*: Graph[seq[Point2D]]
    pointData*: Table[Point2D, PointKind]
    cellData*: Table[seq[Point2D], MazeCell]
    # Might need to add a color palette definition later for convenience 
    # as the colors will be reused a lot in the same level
    fgColor*: Color
    bgColor*: Color
    lineColor*: Color

# Soon I will create some level editing primitives in this module that make it easy to
# create a gui level editor. And then I will use them to make an editor in editor.nim.
# There is an example level in tests/tlevels.nim. That level should be rewritten as a 
# test for the new level editing primitives once they are done.

# Weird workaround used because of openFileStream errors. According to frosty sample code
# I shouldn't need to import std/streams at all.
import std/streams as s
proc saveLevelToFile*(l: Level, filename: string) =
  var handle = openFileStream(filename, fmWrite)
  freeze(handle, l)
  close handle

proc loadLevelFromFile*(filename: string): Level =
  var handle = openFileStream(filename, fmRead)
  thaw(handle, result)
  close handle

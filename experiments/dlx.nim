import strformat

type # Dancing links X and algo X related types
  DlxColList = object
    head: DlxMatrixNode
    count: int
  DlxMatrixNode = ref DlxMatrixNodeObj
  DlxMatrixNodeObj = object
    left, right, up, down: DlxMatrixNode
    colN, rowN: int
  DlxMatrix = object
    cols: seq[DlxColList]
    colsStartNode: DlxMatrixNode
    rowCount: int

proc addRow(m: var DlxMatrix, row: seq[int]) =
  var nodes: seq[DlxMatrixNode]
  for col in row:
    nodes.add DlxMatrixNode.new
    nodes[^1].colN = col
    nodes[^1].rowN = m.rowCount

  inc m.rowCount

  for i, newNode in nodes:
    # Link row horizontally
    if i == 0:
      newNode.left = nodes[^1]
    else:
      newNode.left = nodes[i-1]
    if i == nodes.high:
      newNode.right = nodes[0]
    else:
      newNode.right = nodes[i+1]

    if newNode.colN == -1:
      m.colsStartNode = newNode
    elif newNode.colN > m.cols.high:
      # Add list head if there isn't one
      newNode.down = newNode; newNode.up = newNode
      m.cols.add DlxColList(head: newNode)
    else:
      # Add new node to existing list head
      var listHead = m.cols[newNode.colN].head
      inc m.cols[newNode.colN].count
      var prevLast = listHead.up
      newNode.up = prevLast
      newNode.down = listHead
      prevLast.down = newNode
      listHead.up = newNode

func getMinCol(m: DlxMatrix): int =
  result = m.colsStartNode.right.colN
  var nodeToRight = m.colsStartNode.right.right
  while nodeToRight != m.colsStartNode:
    if m.cols[nodeToRight.colN].count < m.cols[result].count:
      result = nodeToRight.colN
    nodeToRight = nodeToRight.right

proc cover(m: var DlxMatrix, i: int) =
  # Switch links on column descriptor row to go around column i
  var colHead = m.cols[i].head
  debugEcho fmt"Covering {i} horizontally"
  colHead.left.right = colHead.right
  colHead.right.left = colHead.left

  var currRow = colHead.down
  while currRow != colHead:
    var currCol = currRow.right
    while currCol != currRow:
      debugEcho fmt"Covering {currCol.colN} vertically on row {currCol.rowN}"
      currCol.up.down = currCol.down
      currCol.down.up = currCol.up
      if currCol.colN != -1:
        dec m.cols[currCol.colN].count

      currCol = currCol.right
    currRow = currRow.down

proc uncover(m: var DlxMatrix, i: int) =
  # Restore links on column descriptor row
  var colHead = m.cols[i].head
  debugEcho fmt"Uncovering {i} horizontally"
  colHead.left.right = colHead
  colHead.right.left = colHead

  var currRow = colHead.up
  while currRow != colHead:
    var currCol = currRow.left
    while currCol != currRow:
      debugEcho fmt"Uncovering {currCol.colN} vertically on row {currCol.rowN}"
      currCol.up.down = currCol
      currCol.down.up = currCol
      if currCol.colN != -1:
        inc m.cols[currCol.colN].count

      currCol = currCol.left
    currRow = currRow.up

func collectRow(node: DlxMatrixNode): seq[int] =
  result.add node.colN
  var nodeToRight = node.right
  while nodeToRight != node:
    result.add nodeToRight.colN
    nodeToRight = nodeToRight.right

proc findCover(m: var DlxMatrix): seq[DlxMatrixNode] =
  var tempSolution, solution: seq[DlxMatrixNode]
  proc findCoverInner(m: var DlxMatrix, level = 0) =
    if m.colsStartNode.right == m.colsStartNode:
      solution = tempSolution
      return

    var colHead = m.cols[m.getMinCol()].head
    #debugEcho fmt"Below: {colHead.down.left} - {colHead.down} - {colHead.down.right}"
    m.cover colHead.colN
    
    var currRow = colHead.down
    while currRow != colHead:
      tempSolution.add currRow
      var currCol = currRow.right 
      while currCol != currRow:
        m.cover currCol.colN
        currCol = currCol.right

      m.findCoverInner(level + 1)
      tempSolution.del tempSolution.find(currRow)
      colHead = m.cols[currRow.colN].head

      currCol = currRow.left
      while currCol != currRow:
        m.uncover currCol.colN
        currCol = currCol.left

      m.uncover currCol.colN

      currRow = currRow.down

  m.findCoverInner()
  return solution


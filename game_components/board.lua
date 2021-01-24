Board = Object.extend(Object)

function Board:new(tilesize)

  local function getStartPos()
    local length = self.tilesize * self.size
    --so, if we want the middle point to be this:
    local middlex = love.graphics.getWidth() / 2
    local middley = love.graphics.getHeight() / 2
    --we know we should go half of our length to the left, and half of our length up
    --to get to the starting point (and dont forget to subtract the tilesize finally at the end)
    local startx = middlex - (length / 2) - self.tilesize
    local starty = middley - (length / 2) - self.tilesize
    --the reason we subtract tilesize is because we the formula of where to place tiles
    --is like startx + (i * tilesize) so when i == 1, we start tilesize units away from the start.
    --this is because indices in lua start at 1. wouldn't be a problem if we just started at 0
    print(string.format("startx %s, starty %s", startx + self.tilesize, starty + self.tilesize))
    return startx, starty
  end

  local function getFontData()
    local fontdata = {}
    fontdata.size = self.tilesize / 3 --make it a third of the size of a tile.
    fontdata.width = love.graphics.getFont():getWidth("A") --how long is that character?
    fontdata.height = love.graphics.getFont():getHeight("A") --how high is it?
    love.graphics.setFont(love.graphics.newFont(fontdata.size))
    return fontdata
  end

  self.size = 8 --8 rows and columns
  self.grid = {}
  self.tilesize = tilesize
  self.startx, self.starty = getStartPos()
  self.fontdata = getFontData()
  self.pieces = {} --creating an array of pieces that we can loop through to draw them
  --print(string.format("font width, height is %s %s", self.fontdata.width, self.fontdata.height))
end

function Board:create()
  local function flipColor(c)
    if c == "white" then return "black" end
    return "white" --return this otherwise.
  end
  --creating tiles:
  local color = "black"
  for row=1, self.size do
    local this_row = {}
    for col=1, self.size do
      color = flipColor(color)
      this_row[col] = Tile(color, row, col, self.tilesize)
    end
    self.grid[row] = this_row
    color = flipColor(color)
  end
  --creating pieces:
  local pieces = {}
  local flip = true
  local color = "red"
  for row=1, self.size do
    if row == 4 or row == 5 then
      pieces[row] = {0,0,0,0,0,0,0,0}
      color = "black" --it is now black.
    elseif flip then
      pieces[row] = {0,1,0,1,0,1,0,1}
    else
      pieces[row] = {1,0,1,0,1,0,1,0}
    end
    pieces[row].c = color
    flip = not flip --flip it
  end
  for row=1, self.size do
    for col=1, self.size do
      local t = self.grid[row][col]
      if not t:hasPiece() then
        if pieces[row][col] == 1 then
          local p = Piece(pieces[row].c, row, col, self.tilesize)
          t:placePiece(p)
        end
      end
    end
  end
end


function Board:draw()

  local function drawTilesAndPieces()
    for i=1, self.size do
      local row = self.grid[i]
      for j=1, self.size do
        local tile = self.grid[i][j]
        tile:draw(self.startx, self.starty) --call the tile draw
        if tile:hasPiece() then
          tile.piece:draw(self.startx, self.starty)
        end
      end
    end
  end

  local function drawColumnHeaders()
    local startposx = self.startx + (self.tilesize / 2) - (self.fontdata.width / 2) - 2
    local startposy = self.starty + self.tilesize - (self.fontdata.height * 2)
    local header = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" --have the rest of the alphabet in there
    for i=1, self.size do
      local char = string.sub(header, i, i) --get a single character
      love.graphics.print(char, startposx + (i * self.tilesize), startposy)
    end
  end

  local function drawRowHeaders()
    local startposx = self.startx + self.tilesize - (self.fontdata.height * 2)
    local startposy = self.starty + (self.tilesize / 2) - (self.fontdata.width / 2) - 6.5
    local header = "87654321" --hard coding in this header.
    for i=self.size, 1, -1 do
      local char = string.sub(header, i, i) --get a single character
      love.graphics.print(char, startposx, startposy + (i * self.tilesize))
    end
  end
  --do the drawing:
  drawTilesAndPieces()
  drawColumnHeaders()
  drawRowHeaders()

end

function Board:getPieces()
  local pieces = {}
  for row=1, self.size do
    for col=1, self.size do
      if self.grid[row][col]:hasPiece() then
        table.insert(pieces, self.grid[row][col].piece) --insert into table
      end
    end
  end
  return pieces
end

function Board:list()
  local pieces = self:getPieces()
  for i=1, #pieces do
    local p = pieces[i]
    local t = self.grid[p:getRow()][p:getColumn()]
    t:toggleLightUp(2)
  end
end

function Board:showMoves(start)
  local moves = self.grid[start.row][start.column].piece:getValidMoves(self.grid)
  for i=1, #moves do
    local t = self.grid[moves[i].row][moves[i].column]
    t:toggleLightUp(2) --call it with 2 second timer
  end
end

function Board:movePiece(startpos, endpos)
  local function isValidMove(startpos, endpos)
    if not self.grid[startpos.row][startpos.column]:hasPiece() then --if there is no piece at start position then
      print(string.format("Can't move a piece at %s, %s: it doesn't exist.", startpos.row, startpos.column))
      return false
    end
    local moves = self.grid[startpos.row][startpos.column].piece:getValidMoves(self.grid)
    for i=1, #moves do
      if moves[i].row == endpos.row and moves[i].column == endpos.column then
        return true --found the right move
      end
    end
    return false --if we made it here, then we didn't find the endpos in the list of possible moves, so that means it is false.
  end
  if isValidMove(startpos, endpos) then
    self.grid[startpos.row][startpos.column]:movePieceToOther(self.grid[endpos.row][endpos.column]) --move the piece.
  else
    local a = self:getTextFromTile(startpos)
    local b = self:getTextFromTile(endpos)
    print(string.format("Invalid move: %s to %s", a, b))
  end

end

function Board:tileUnderMouse(mousex, mousey)
  --right now, we can be greedy. mouse presses won't happen often. let's just scroll through every tile in the grid,
  --and see if the mouse was within its box. easy, right? why not? lets see the exact coordinate we draw the tiles at.
  local function mouseWithinBox(box_x,box_y,width,height)
    if mousex >= box_x and mousex <= box_x + width then
      if mousey >= box_y and mousey < box_y + height then
        return true
      end
    end
    return false
  end

  for row=1, self.size do
    for col=1, self.size do
      local t = self.grid[row][col]
      local x, y, s = t:getPos()
      if mouseWithinBox(x, y, s, s) then
        return t
      end
    end
  end
  return false
end

function Board:getTileFromText(text)
  local t = {}
  local alphabet = "ABCDEFGH"

  local function getColumn(alphabet, text)
    local letter = string.upper(string.sub(text, 1, 1))
    return string.find(alphabet, letter) --find what index in ABCDEFGH our character was
  end

  local function getRow(text)
    local num = string.sub(text, 2, 2) --get  the second letter from the text
    return self.size+1 - num
  end

  t.column = getColumn(alphabet, text)
  t.row = getRow(text)
  return t
end

function Board:getTextFromTile(t)
  --takes in t, a table with .row and .column properties.
  local alphabet = "ABCDEFGH"
  return string.sub(alphabet, t.column, t.column) .. (self.size+1 - t.row)
end

function Board:toggleLight(t_start, t_end, seconds)

  local function toggleSingular(row, column)
    self.grid[row][column]:toggleLightUp(seconds) --default
  end

  local function toggleRow(row, index1, index2)
    for i=index1, index2 do
      row[i]:toggleLightUp(seconds)
    end
  end

  local function toggleCol(col, index1, index2)
    for i=index1, index2 do
      col[i]:toggleLightUp(seconds)
    end
  end

  local function gatherCol(index)
    local col = {}
    for row=1, self.size do
      tile = self.grid[row][index]
      col[row] = tile
    end
    return col
  end

  if t_end then --we have an end specifier. so do that stuff
    if t_start.row == t_end.row then
      local row = self.grid[t_start.row]
      toggleRow(row, t_start.column, t_end.column)
    elseif t_start.column == t_end.column then
      toggleCol(gatherCol(t_start.column), t_start.row, t_end.row)
    end
  else --otherwise just toggle a singular tile
    toggleSingular(t_start.row, t_start.column)
  end
end

function Board:flash(t)
  --takes in t, a table with the properties row and column for easy access into self.grid
  local tile = self.grid[t.row][t.column]
  tile:toggleLightUp(2)
end

function Board:clearLights()
  for i=1, self.size do
    for j=1, self.size do
      self.grid[i][j]:clear() --call clear() on the tile.
    end
  end
end

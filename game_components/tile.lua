Tile = Object.extend(Object)

function Tile:new(color, row, column, size)
  self.color = color
  self.row = row
  self.column = column
  self.size = size or 50
  self.prev_color = self.color
  self.piece = nil
  self.startx = -1
  self.starty = -1
end

function Tile:movePieceToOther(other_tile)
  if other_tile:hasPiece() then
    print("ignoring the fact that im putting a piece on top of another piece")
  end
  other_tile:placePiece(self.piece)
  other_tile.piece.row = other_tile.row
  other_tile.piece.column = other_tile.column
  self.piece = nil
end

function Tile:deletePiece()
  self.piece = nil --does it
end

function Tile:placePiece(piece)
  self.piece = piece
end

function Tile:hasPiece()
  if self.piece then return true else return false end
end

--[[
right now im trying to figure out what to do with pieces.
how do we store them? do we attach them to tiles? i want easy access for getting a piece on the board
when I say move a8 b7, then i want the piece at a8 to move to b7.
we can translate a8 to t.row = 1, t.column = 1, but how do we get the piece there?
do we say self.grid[i][j]:hasPiece() ?
--]]

function Tile:draw(startx, starty)
  if self.startx == -1 and self.starty == -1 then
    self.startx = startx
    self.starty = starty
  end
  if self.color == "white" then
    love.graphics.setColor(1,1,1) --white
  elseif self.color == "black" then
    love.graphics.setColor(0,0,0) --black
  elseif self.color == "green" then
    love.graphics.setColor(0,1,0) --green
  elseif self.color == "flash" then
    --something? idk, let's think.
  end
  love.graphics.rectangle("fill", startx + (self.column * self.size), starty + (self.row * self.size), self.size, self.size)
end

function Tile:getPos()
  return (self.startx + (self.column * self.size)), (self.starty + (self.row * self.size)), self.size
end

function Tile:update(dt)
  --nothing
end

function Tile:toggleLightUp(seconds)
  if seconds then
    timer:after(seconds, function() self:toggleLightUp() end) --call itself again after those seconds
  end
  local function flipColor(c)
    if c == "green" then return self.prev_color end
    return "green"
  end
  self.color = flipColor(self.color) --flip the color
end

function Tile:flash()
  self.color = "green"
  local long, short = 1, 0.25
  timer:after(long, function() self.color = self.prev_color  end)
  timer:after(long+short, function() self.color = "green" end)
  timer:after((2*long) + short, function() self.color = self.prev_color end)
  timer:after((2*long) + (2*short), function() self.color = "green" end)
  timer:after((3*long) + (2*short), function() self.color = self.prev_color end)
end

function Tile:clear()
  --return this tile to its original state.
  self.color = self.prev_color
end

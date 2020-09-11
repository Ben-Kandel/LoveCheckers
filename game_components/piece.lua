Piece = Object.extend(Object)

--okay do this later..
function Piece:new(color, row, column, size, piece_type)
  --piece colors will be black or red.
  self.color = color
  self.row = row
  self.column = column
  self.size = size or 50
  self.radius = self.size/2.5
  self.piece_type = piece_type or "pawn"
end

function Piece:kingMe()
  self.piece_type = "king"
end

function Piece:getValidMoves(grid)

  local function checkBounds(row, column)
    if row >= 1 and row <= 8 and column >=1 and column <= 8 then return true else return false end
  end
  
  local function killingTeam(tile)
    if tile:hasPiece() then
      if tile.piece.color == self.color then
        return true --return true for killing team
      end
      return false --return false for not killing team
    end
    return false --return false for not killing team
  end
  
  local function downLeft(row, column, moves_list)
    if checkBounds(row+1, column-1) then --check if down and to the left is still valid
      local t1 = grid[row+1][column-1]
      if not t1:hasPiece() then --if this spot is available
        table.insert(moves_list, {row=t1.row, column=t1.column, jump=false})
      else --otherwise,
        if checkBounds(row+2, column-2) then --check if the next tile down to the left is valid
          local t2 = grid[row+2][column-2] --get the tile
          if not killingTeam(t1) and not t2:hasPiece() then --if not killing a teammate, and the place we are landing isnt occupied
            table.insert(moves_list, {row=t2.row, column=t2.column, jump=t1}) --then this is a jump move.
          end
        end
      end
    end
  end
  
  local function downRight(row, column, moves_list)
    if checkBounds(row+1, column+1) then
      local t1 = grid[row+1][column+1]
      if not t1:hasPiece() then
        table.insert(moves_list, {row=t1.row, column=t1.column, jump=false})
      else
        if checkBounds(row+2, column+2) then
          local t2 = grid[row+2][column+2]
          if not killingTeam(t1) and not t2:hasPiece() then --if not killing a teammate, and the place we are landing isnt occupied
            table.insert(moves_list, {row=t2.row, column=t2.column, jump=t1})
          end
        end
      end
    end
  end
  
  local function upLeft(row, column, moves_list)
    if checkBounds(row-1, column-1) then
      local t1 = grid[row-1][column-1]
      if not t1:hasPiece() then
        table.insert(moves_list, {row=t1.row, column=t1.column, jump=false})
      else
        if checkBounds(row-2, column-2) then
          local t2 = grid[row-2][column-2]
          if not killingTeam(t1) and not t2:hasPiece() then --if not killing a teammate, and the place we are landing isnt occupied
            table.insert(moves_list, {row=t2.row, column=t2.column, jump=t1})
          end
        end
      end
    end
  end
  
  local function upRight(row, column, moves_list)
    if checkBounds(row-1, column+1) then
      local t1 = grid[row-1][column+1]
      if not t1:hasPiece() then
        table.insert(moves_list, {row=t1.row, column=t1.column, jump=false})
      else
        if checkBounds(row-2, column+2) then
          local t2 = grid[row-2][column+2]
          if not killingTeam(t1) and not t2:hasPiece() then --if not killing a teammate, and the place we are landing isnt occupied
            table.insert(moves_list, {row=t2.row, column=t2.column, jump=t1})
          end
        end
      end
    end
  end
  
  local function forceJumps(moves_list)
    local remove_non_jumps = false
    for i=1, #moves_list do
      if moves_list[i].jump then --if there was at least 1 move that was a jump
        remove_non_jumps = true
        break
      end
    end
    
    if remove_non_jumps then --then force that move. remove all non-jumping moves.
      local new_moves = {}
      for i=1, #moves_list do
        if moves_list[i].jump then
          table.insert(new_moves, moves_list[i])
        end
      end
      return new_moves
    else
      return moves_list --return the unmodified moves list
    end
  end
  --testing
  local moves = {}
  if self.piece_type == "king" then
    downLeft(self.row, self.column, moves)
    downRight(self.row, self.column, moves)
    upLeft(self.row, self.column, moves)
    upRight(self.row, self.column, moves)
  else
    if self.color == "red" then
      downLeft(self.row, self.column, moves)
      downRight(self.row, self.column, moves)
    elseif self.color == "black" then
      upLeft(self.row, self.column, moves)
      upRight(self.row, self.column, moves)
    end
  end
  return forceJumps(moves)
end

function Piece:getTeam()
  return self.color
end

function Piece:getColor()
  return self.color
end

function Piece:getRow()
  return self.row
end

function Piece:getColumn()
  return self.column
end

function Piece:getPos()
  return self:getRow(), self:getColumn()
end

function Piece:draw(startx, starty)
  local function setColor()
    if self.color == "red" then
      love.graphics.setColor(1,0,0) --red
    elseif self.color == "black" then
      love.graphics.setColor(0.45,0.45,0.45) --black
    end
  end
  
  local function drawPawn()
    love.graphics.circle("fill", startx + (self.column * self.size), starty + (self.row * self.size),  self.radius)
  end
  
  local function drawKing()
    love.graphics.circle("line", startx + (self.column * self.size), starty + (self.row * self.size),  self.radius)
    love.graphics.circle("fill", startx + (self.column * self.size), starty + (self.row * self.size),  self.radius/1.5) --super lazy way.
  end
  
  setColor()
  startx = startx + self.size/2
  starty = starty + self.size/2
  if self.piece_type == "pawn" then
    drawPawn()
  else
    drawKing()
  end

end
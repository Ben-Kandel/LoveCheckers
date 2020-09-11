TurnQueue = Object.extend(Object)

function TurnQueue:new(board)
  self.first = 0
  self.last = -1
  self.list = {}
  self.board = board
end

function TurnQueue:startGame()
  --restart everything
  self.first = 0
  self.last = -1
  self.list = {}
  self:pushRight(1) --put player 1 in the queue.
  self:pushRight(2) --put player 2 right after.
  print("started the game!")
end


function TurnQueue:endTurn(player_id)
  self:pushRight(player_id)
end

function TurnQueue:getTurn()
  local function getValidPieces(team_color)
    local moves = {}
    for row=1, self.board.size do
      for col=1, self.board.size do
        local t = self.board.grid[row][col]
        if t:hasPiece() then
          if t.piece:getColor() == team_color then
            table.insert(moves, {row=row, column=col})
          end
        end
      end
    end
    return moves
  end
  
  local function forceJumps(moves)
    local new_moves = {} -- a table of tables with .row and .column properties representing a tile in the grid
    for i=1, #moves do
      local p = self.board.grid[moves[i].row][moves[i].column].piece
      local piece_moves = p:getValidMoves(self.board.grid)
      for j=1, #piece_moves do
        if piece_moves[j].jump then
          table.insert(new_moves, moves[i])
        end
      end
    end
    if #new_moves == 0 then
      print("this player had no pieces with jumps.")
      return moves --return this unchanged table of rows and columns
    end
    print("this player had pieces with jumps. we are forcing them.")
    return new_moves --return the list of row:column pairs that have jumps. we have to force these
  end
  
  
  local player = self:popLeft() --pop the first item off
  local tiles_to_click = {}
  if player == 1 then
    tiles_to_click = getValidPieces("red")
  else
    tiles_to_click = getValidPieces("black")
  end
  --if player == 1 then tiles_to_click = getValidPieces("red") else getValidPieces("black") end
  tiles_to_click = forceJumps(tiles_to_click) --force jumps if needed
  return player, tiles_to_click  --pop the left thing off and return it
end

function TurnQueue:endTurnCheat(player_id)
  self:pushLeft(player_id) --place this player at the beginning of the queue, so they go again.
end

function TurnQueue:endTurn(player_id)
  self:pushRight(player_id) --place this player on the end of the queue again.
end

function TurnQueue:pushLeft(value)
  local first = self.first - 1
  self.first = first
  self.list[first] = value
end

function TurnQueue:pushRight(value)
  local last = self.last + 1
  self.last = last
  self.list[last] = value
end

function TurnQueue:popLeft()
  local first = self.first
  if first > self.last then error("List is empty") end
  local value = self.list[first]
  self.list[first] = nil
  self.first = first + 1
  return value
end

function TurnQueue:popRight()
  local last = self.last
  if self.first > last then error("List is empty") end
  local value = self.list[last]
  self.list[last] = nil
  self.last = last - 1
  return value
end
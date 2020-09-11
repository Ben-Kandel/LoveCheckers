Console = Object.extend(Object)

function Console:new(board, turnq)
  self.current_text = ""
  self.commands = {} --point command names to actual function and run them
  self.board = board
  self.mouse_clicks = 0
  self.starting_tile = nil
  self.turnq = turnq
  self:nextTurn()
end

function Console:nextTurn()
  --could prob do this in a shorter way with lua
  local player, tiles_to_click = self.turnq:getTurn() --get the next players turn
  self.player = player
  self.tiles_to_click = tiles_to_click
end

function Console:endTurn(go_again)

  local function tryKingPieces()
    for row=1, self.board.size do
      for col=1, self.board.size do
        local tile = self.board.grid[row][col]
        if tile:hasPiece() then
          if tile.piece.color == "red" and tile.row == 8 then
            tile.piece:kingMe()
          elseif tile.piece.color == "black" and tile.row == 1 then
            tile.piece:kingMe()
          end
        end
      end
    end
  end

  local function gameOver()
    local red_count = 0
    local black_count = 0
    for row=1, self.board.size do
      for col=1, self.board.size do
        local t = self.board.grid[row][col]
        if t:hasPiece() then
          if t.piece.color == "red" then
            red_count = red_count + 1
          else
            black_count = black_count + 1
          end
        end
      end
    end
    if red_count == 0 or black_count == 0 then
      return true
    end
    return false
  end

  if go_again then
    self.turnq:endTurnCheat(self.player)
  else
    self.turnq:endTurn(self.player)
  end
  if gameOver() then
    love.event.quit() --just end the game, lol.
  end
  tryKingPieces()
  self:nextTurn() --call next turn
end

function Console:textinput(text)
  self.current_text = self.current_text..text --update current_text
end

function Console:parseCommand(cmd_string)
  --we are going to return a table with the correct values in it
  local function mysplit (inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

  local answer = {}
  tokens = mysplit(cmd_string)
  if #tokens >= 1 then
    answer.cmd = tokens[1]
  end
  if #tokens >= 2 then
    answer.arg1 = tokens[2]
  end
  if #tokens >= 3 then
    answer.arg2 = tokens[3]
  end
  return answer
end

function Console:executeTextCommand(cmd)
  if cmd.cmd == "flash" then
    local t = self.board:getTileFromText(cmd.arg1) --get the table representing this position
    self.board:flash(t) --call flash with this position
  elseif cmd.cmd == "hold" then
    local t_start = self.board:getTileFromText(cmd.arg1) --get the position of first tile
    if cmd.arg2 then
      local t_end = self.board:getTileFromText(cmd.arg2)
      self.board:toggleLight(t_start, t_end) --toggle the range
      --timer:after(2, function() self.board:toggleLight(t_start, t_end) end) --toggle it off after 2 seconds
    else
      print("Error: incorrect arguments to hold command.")
    end
  elseif cmd.cmd == "move" then
    local t_start = self.board:getTileFromText(cmd.arg1) --get the position of first tile
    if cmd.arg2 then
      local t_end = self.board:getTileFromText(cmd.arg2)
      print("t_start, t_end: ", t_start, t_end)
      self.board:movePiece(t_start, t_end) --call the function
    else
      print("Error: incorrect arguments to move command.")
    end
  elseif cmd.cmd == "show" then
    local t_start = self.board:getTileFromText(cmd.arg1)
    self.board:showMoves(t_start) --call the board function.
  elseif cmd.cmd == "clear" then
    self.board:clearLights()
  elseif cmd.cmd == "list" then
    self.board:list()
  elseif cmd.cmd == "exit" or cmd.cmd == "close" or cmd.cmd == "quit" then
    love.event.quit() --quit the game
  end
end

function Console:keypressed(key, isrepeat)
  if key == "backspace" then
    self.current_text = string.sub(self.current_text, 1, #self.current_text-1)
  elseif key == "return" then
    self:executeTextCommand(self:parseCommand(self.current_text))
    self.current_text = "" --reset it
  end
end

function Console:mouseClick(tile_clicked, click_number, previous_click)

  local function lightUpMoves(moves_list)
    for i=1, #moves_list do
      self.board.grid[moves_list[i].row][moves_list[i].column]:toggleLightUp() --light up tile
    end
  end

  local function wasValidMove(moves_list, destination)
    for i=1, #moves_list do
      if moves_list[i].row == destination.row and moves_list[i].column == destination.column then
        return moves_list[i]
      end
    end
    return false
  end

  if click_number == 1 then
    local p = tile_clicked.piece
    local moves = p:getValidMoves(self.board.grid)
    lightUpMoves(moves) --light them up
    return true, false --successful
  elseif click_number == 2 then
    local p = previous_click.piece --get the previous thing we clicked on
    local moves = p:getValidMoves(self.board.grid)
    lightUpMoves(moves) --turn them off now
    local m = wasValidMove(moves, tile_clicked)
    if m then --then m is our move we took
      previous_click:movePieceToOther(tile_clicked)
      if m.jump then
        m.jump:deletePiece()
        return true, true
      end
      return true, false
    end
    return false, false
  else
    print("Something went wrong")
    return false, false
  end
end

function Console:mousepressed(x,y,button)

  local function hasJump(piece)
    local move_list = piece:getValidMoves(self.board.grid)
    for i=1, #move_list do
      if move_list[i].jump then
        return true --if we found a jump, return true
      end
    end
    return false --if we made it here, no jump was found
  end

  local function wasGoodClick(tile)
    for i=1, #self.tiles_to_click do
      local other_tile = self.board.grid[self.tiles_to_click[i].row][self.tiles_to_click[i].column]
      if tile.row == other_tile.row and tile.column == other_tile.column then
        return true
      end
    end
    return false --if we get to the end, then it wasn't a good click.
  end

  local function showPlayerTiles()
    for i=1, #self.tiles_to_click do
      self.board.grid[self.tiles_to_click[i].row][self.tiles_to_click[i].column]:toggleLightUp(2)
    end
  end

  local t = self.board:tileUnderMouse(x,y)
  if not self.tile_clicked then --if we don't have a tile currently selected.
    if t and wasGoodClick(t) then --if we actually clicked on something, and it belongs to the current player's team
      --showPlayerTiles() --show these real quick.
      self.tile_clicked = t
      self:mouseClick(t, 1)
    end
  else
    if t then --if we clicked somewhere valid,
      local success, jump = self:mouseClick(t, 2, self.tile_clicked)
      if success then --if we clicked on a correct move.
        if jump and hasJump(t.piece) then
          --if we just made a jump, and we have another jump, then
          self:endTurn(true) --end turn but put this player up again.
        else
          self:endTurn() --end turn normally
        end
      end
    end
    self.tile_clicked = nil
  end
end

function Console:draw()
  love.graphics.print(self.current_text, 0, 50)
  local coloredtext = {}
  if self.player == 1 then
    coloredtext = {{1,1,1,1}, "It is ", {1,0,0,1}, "red ", {1,1,1,1}, "player's turn."}
  else
    coloredtext = {{1,1,1,1}, "It is ", {0,0,0,1}, "black ", {1,1,1,1}, "player's turn."}
  end
  love.graphics.print(coloredtext, 0, 30)
end

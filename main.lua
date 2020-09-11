function love.load()
  Object = require("useful_things/classic")
  require("game_components/board")
  require("game_components/tile")
  require("game_components/console")
  require("game_components/piece")
  require("useful_things/turnqueue")
  Timer = require("useful_things/Timer")
  timer = Timer()
  love.graphics.setBackgroundColor(0.3, 0.3, 0.3) -- a nice gray
  board = Board(65) --takes in the size of a tile in the grid.
  board:create()
  turnq = TurnQueue(board)
  turnq:startGame()
  console = Console(board, turnq)
end

function love.update(dt)
  timer:update(dt)
end

function love.textinput(text)
  console:textinput(text)
end

function love.keypressed(key, isrepeat)
  console:keypressed(key, isrepeat)
end

function love.mousepressed(x,y,button,istouch,presses)
  console:mousepressed(x,y,button)
end

function love.draw()
  board:draw()
  console:draw()
  --love.graphics.print(string.format("x: %s y: %s", love.mouse.getX(), love.mouse.getY())) --displaying the mouse pos for debug purposes.
end

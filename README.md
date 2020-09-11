# LoveCheckers

## Two Player Checkers

This project was written in lua and utilizes the love2d framework.

All traditional checkers rules are followed.
- Red goes first
- Pieces can only move diagonally toward the opposite side of the board
- A piece can be crowned king if it moves to the opposite end of the board
- Kings can move in any diagonal direction they want
- You can capture a piece by jumping over it onto an empty space
- If you have a jump, you have to take it (if there is another jump available, this rule applies again)

The game is won when a player captures all of their opponent's pieces.
The game exits automatically when you win.

## Running the game

You must have the love executable ready. Simply navigate to the directory in your shell and run `love .`

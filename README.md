# Assignment 1: snake, Snake!
## snake.c: Snake!
snake.c is an implementation of the classic video game Snake!  

The starting state of a game to the right, where you can see all the key parts of the game. Snake is played on a 15×15 grid. The snake is made up of a head (#), and a number of body segments (o), and can move around the grid.  

When the user enters one of `w`, `a`, `s`, or `d`, the snake will move one step on the grid either north, west, south, or east, respectively. The snake won't move if the requested direction is where the first non-head segment is.  

Also on the grid: apples! Snakes like apples<sup>[citation needed]</sup> so, if the snake's head moves over an apple (denoted @), the snake consumes it, and gains three segments over the next three moves. If there's no apple on the grid, a new one is added in a random empty cell.  

The game ends only when either the snake falls off one of the edges of the board, or the snake runs into its own body — as the snake's length increases, not falling off the board or running into itself become increasingly tricky!  

## snake.s: The Assignment
Your task in this assignment is to implement snake.s in MIPS assembly.  

You have been provided with some assembly and some helpful information in snake.s. Read through the provided code carefully, then add MIPS assembly so it executes exactly the same as snake.c.  

A handful of utility functions have already been translated to MIPS assembly for you. You only have to implement the following unfinished functions in MIPS assembly:
* main,
* init_snake,
* update_apple,
* update_snake,
* move_snake_in_grid, and
* move_snake_in_array

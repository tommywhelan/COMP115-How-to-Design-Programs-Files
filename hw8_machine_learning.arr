include image
include shared-gdrive("image115.arr", "1eSV5o5JQqKA8bBpA3ijknR7KOV6SUYiw")
include reactors

#|
   
   In this homework, you will implement 
   the following falling blocks game:
   https://youtu.be/Kr-B5q2Xppo

   Game rules:
   * There are a number of stationary blocks, and one falling block.
   * Over time, the falling block falls downwards in a column.
   * If the falling block is in the bottom row, or 
     the falling block is immediately above a stationary block
     of a different color, the falling block lands, and becomes 
     a stationary block.
   * If the falling block is immediately above a stationary 
     block of the same color, both blocks disappear.
   * When the falling block lands or disappears, a new falling
     block appears in the top row, in a randomly generated column,
     with a randomly generated color.
   * Pressing the left or right arrow keys moves the falling block
     left or right, 
     (BONUS) unless it is at the edge or another block is in the way.
   * (BONUS) The game is over
     (lose) when there is a stationary block in the top row
     (win) when there are no stationary blocks.
   
|#

# Changing these should change the number of rows and columns in the board.
WIDTH :: Number = 5
HEIGHT :: Number = 13

#|
 
   We represent a block by its x,y coordinates and its color.
   
   The x coordinate is the column of the block, which ranges 
   from 0 (left) to WIDTH - 1 (right).
   
   The y coordinate is the row of the block, which ranges 
   from 0 (top) to HEIGHT - 1 (bottom).
   
|#

data Block:
  | block(x :: Number, y :: Number, color :: String)
end

#|
 
   We represent a world by an aggregate of a single falling block,
   and a list of stationary blocks.
   
|#

data World:
  | world(falling :: Block, stationary :: List<Block>)
end 

#|
   
   Your job is to design 
   (1) display, 
   (2) key-handing, and 
   (3) ticking, 
   functions to implement the game.  
   
   Hint: for each of these, you will likely want to design 
   one or more helper functions that process the list of
   stationary blocks in some way.  
  
   For extra credit (no penalty if you don't do it), you can also:
   - extend the key handling so that the falling block does not move
     if there is a block next to it or if it is next to the side
   - add a game-over check (use this with stop-when in your reactor)
   - add a function that generates a random game board
     from a specified number of squares
   
|#

# --------------------------------------------------------------
#| displaying
   
   To display the board, we scale the x-y coordinates of each block up 
   so that each row/column has size SIDE.  
   
   For example, a block whose x coordinate is 0 would have its upper-left corner    at x=0, while a block whose x coordinate is 2 would have its upper-left
   corner at SIDE * 2 = 80. 
   
|#
fun random-color() -> String:
  doc: "Randomly picks one of the 5 colors"
  r :: Number = random(5)
  if r == 0: "crimson"
  else if r == 1: "deep-sky-blue"
  else if r == 2: "lime-green"
  else if r == 3: "purple"
  else if r == 4: "gold"
  end
end

fun randomer()-> Block:
  doc: "Randomly puts a block in the first row of a random color"
  block(random(WIDTH), 0, random-color())
end



SIDE :: Number = 40

BACKGROUND :: Image = rectangle(WIDTH * SIDE, HEIGHT * SIDE, "solid", "white") 

clear-back :: Image = rectangle(WIDTH * SIDE, HEIGHT * SIDE, "solid", "transparent")

fun blocker( one :: Block)-> Image:
  doc: "This function displays one singular block on the background"
  cases(Block) one:
    |block(x,y,color)=> overlay-at(rectangle(SIDE - 3,SIDE - 3,"solid", color), x * SIDE, y * SIDE, clear-back)
  end
  
end

  
  
fun blocker-backer(many-blocks :: List<Block>)-> Image:
  doc: "Displays a list of blocks onto a background"
    cases(List<Block>) many-blocks:
    |empty=> clear-back
    |link(first,rest)=> overlay(blocker-backer(rest), blocker(first))
    end
end

fun real-blocker(many-blocks :: List<Block>)-> Image:
  doc: "Mimics the function above but now has a white background opposed to grey"
  overlay(blocker-backer(many-blocks), BACKGROUND)
end



fun win-checker(many-blocks :: List<Block>)-> Boolean:   
  doc: "Checks if the game has been won ie no blocks left"
  cases(List<Block>) many-blocks:
    |empty=> true
    |link(first,rest)=> if (first == empty): true
      else: false
      end
  end

  
  
end

fun lose-checker(many-blocks :: List<Block>)-> Boolean:  
  doc: "Checks if the game has been lost ie a block in the top row"
  cases(List<Block>) many-blocks:
    |empty=> false
    |link(first,rest)=> if
            (cases(Block) first:
            |block(x,y,color)=> y end) == 0: true
            else if lose-checker(rest) == true: true
      else: false
      end
  end
end


fun world-displayer( w :: World)-> Image:
  doc:"A culmination of the helpers above that displays the entire game"
  cases(World) w:
    |world(falling, stationary)=> if win-checker(stationary) == true: text("Winner!!!", 50, "gold")
      else if lose-checker(stationary) == true: overlay(text("You're a big fat loser", 50, "gold"),  overlay(blocker(falling), real-blocker(stationary)))
      else:
      
      overlay(blocker(falling), real-blocker(stationary))
  end
end
end

  



# --------------------------------------------------------------
# responding to keys


fun cant-move-left(mover :: Block, many-blocks :: List<Block>)-> Boolean:
  doc: "Checks if the block is able to move leftward"
  cases(List<Block>) many-blocks:
    |empty=> false
    |link(first,rest) => if (((cases(Block) first: 
          |block(x,y,color)=> y end) == (cases(Block) mover: |block(x,y,color)=> y end))
        
        and 
        
        ((cases(Block) first: 
            |block(x,y,color)=> x end) == (cases(Block) mover: |block(x,y,color)=> (x - 1) end))) or (((cases(Block) mover: 
            |block(x,y,color)=> x end)) == 0): true
        
      else if cant-move-left(mover, rest) == true : true
      else: false
          
        
      end
  end
end
  

fun cant-move-right(mover :: Block, many-blocks :: List<Block>)-> Boolean:
  doc: "Checks if the block is able to move rightward"
  cases(List<Block>) many-blocks:
    |empty=> false
    |link(first,rest) => if (((cases(Block) first: 
          |block(x,y,color)=> y end) == (cases(Block) mover: |block(x,y,color)=> y end))
        
        and 
        
        ((cases(Block) first: 
            |block(x,y,color)=> x end) == (cases(Block) mover: |block(x,y,color)=> (x + 1) end))) or (((cases(Block) mover: 
            |block(x,y,color)=> x end)) == 4) : true
        
      else if cant-move-right(mover, rest) == true : true
      else: false
          
        
      end
  end
end
  

fun key-responder( w :: World, event :: String)-> World:
  doc: "Moves the falling block lef/ right if able"
  cases(World) w:
    | world(falling, stationary)=>
      
      if (event == "right") and (cant-move-right(falling, stationary) == false): world(cases(Block) falling:
            |block(x,y,color)=> block(x + 1, y, color)
          end
              
              , stationary)
      else if (event == "left") and (cant-move-left(falling, stationary) == false): 
        world(cases(Block) falling:
            |block(x,y,color)=> block(x - 1, y, color)
          end
              
              , stationary)
        
      else: w
      end
  end
end


# --------------------------------------------------------------
# ticking


fun vertical-helper(mover :: Block, many-blocks :: List<Block>)-> Boolean:
  doc: "Checks if the falling block is directly above another block"
cases(List<Block>) many-blocks:
    |empty=> false
    |link(first,rest) => if ((cases(Block) first: 
          |block(x,y,color)=> x end) == (cases(Block) mover: |block(x,y,color)=> x end))
        
        and 
        
        ((cases(Block) first: 
          |block(x,y,color)=> y end) == (cases(Block) mover: |block(x,y,color)=> (y + 1) end)): true
        
      else if vertical-helper(mover, rest) == true : true
      else: false
          
        
      end
  end
end


fun color-checker(mover :: Block, many-blocks :: List<Block>)-> Boolean:
  doc: "Checks if the block is directly above a block of the same color"
  cases(List<Block>) many-blocks:
    |empty=> false
    |link(first,rest) => if ((cases(Block) first: 
          |block(x,y,color)=> x end) == (cases(Block) mover: |block(x,y,color)=> x end))
        
        and 
        
        ((cases(Block) first: 
          |block(x,y,color)=> y end) == (cases(Block) mover: |block(x,y,color)=> (y + 1) end)) and (((cases(Block) mover: 
            |block(x,y,color)=> color end)) == ((cases(Block) first: |block(x,y,color)=> color end))): true
        
      else if color-checker(mover, rest) == true : true
      else: false
          
        
      end
  end
end

fun block-remover(mover :: Block, many-blocks :: List<Block>)->List<Block>:
   doc: "Removes the stationary block that is supposed to dissapear"
  cases(List<Block>) many-blocks:
|empty=> empty
|link(first,rest) =>
      if ((cases(Block) mover: |block(x,y,color)=> x end) == ((cases(Block) first: |block(x,y,color)=> x end))) and ((cases(Block) mover: |block(x,y,color)=> (y + 1) end) == ((cases(Block) first: |block(x,y,color)=> y end))): rest
      else: link(first, block-remover(mover, rest))
 
  end
  
end
end
   

fun am-i-at-bottom(mover :: Block)-> Boolean:
  doc: "Checks if the falling block is at the bottom of the board"
  cases(Block) mover:
    |block(x,y,color)=> if y == (HEIGHT - 1): true
      else: false
      end
  end

end


fun tick(w :: World)-> World:
  doc: "Updates the board as time moves on, using the helpers above"
  cases(World) w :
      | world(falling, stationary)=>
      if am-i-at-bottom(falling) == true: world(randomer(), link(falling,stationary))
      else if (vertical-helper(falling, stationary) == true) and (color-checker(falling, stationary) == false): world(randomer(), link(falling, stationary))
      else if (vertical-helper(falling, stationary) == true) and (color-checker(falling, stationary) == true): world(randomer(), block-remover(falling, stationary))
      else:
      world(cases(Block) falling:
      |block(x,y,color)=> block(x, y + 1, color) end, stationary)
  end
end
end

  
  
  
#|
 
  Hint: First write a tick function where the falling block falls 
   all the way to the bottom.  
   Then change the function so that the falling block stops 
   when it is on top of a stationary block.  
   Then change the function so that the falling block disappears
   if it is on top of a stationary block of the same color.  
 
|#

#|
   The function random(n :: Number) picks an arbitrary number
   between 0 and n-1, and will give different numbers
   each time you run it.  You can use this to pick the column
   of a new block.  You can also use the following 
   function to pick the color.  Try running 
   random-color()
   in the interactions frame a few times 
   to see what it does.
|#





# --------------------------------------------------------------
# bonus: game over


# --------------------------------------------------------------
# bonus: generating game boards


# --------------------------------------------------------------
# here are some game boards you can use before/if you don't 
# write the board generator

#HEIGHT 13, WIDTH 5
board0 :: List<Block> = 
[list: block(0, 7, "gold"), block(2, 5, "lime-green"), block(1, 4, "crimson"), block(4, 8, "purple"), block(0, 10, "crimson"), block(4, 12, "crimson"), block(4, 9, "crimson"), block(1, 5, "purple"), block(3, 9, "crimson"), block(4, 7, "purple"), block(4, 11, "crimson"), block(0, 9, "crimson"), block(1, 9, "lime-green"), block(0, 12, "deep-sky-blue"), block(1, 8, "lime-green"), block(0, 8, "gold"), block(0, 11, "crimson"), block(4, 5, "gold"), block(1, 12, "deep-sky-blue"), block(2, 9, "crimson"), block(1, 11, "purple"), block(4, 4, "purple"), block(2, 7, "gold")]

#HEIGHT 10, WIDTH 4
board1 :: List<Block> = 
  [list: block(0, 9, "purple"), block(2, 4, "gold"), block(3, 7, "gold"), block(3, 5, "deep-sky-blue"), block(0, 4, "purple"), block(3, 8, "crimson"), block(2, 8, "lime-green"), block(0, 8, "deep-sky-blue"), block(3, 9, "purple"), block(3, 6, "crimson"), block(1, 5, "purple"), block(1, 6, "deep-sky-blue"), block(1, 4, "deep-sky-blue"), block(2, 7, "lime-green"), block(0, 7, "crimson"), block(2, 9, "deep-sky-blue")]

#HEIGHT 10, WIDTH 4
board2 :: List<Block> = 
[list: block(3, 5, "gold"), block(2, 6, "deep-sky-blue"), block(1, 7, "purple"), block(1, 4, "deep-sky-blue"), block(0, 4, "deep-sky-blue"), block(2, 7, "crimson"), block(1, 5, "purple"), block(0, 6, "purple"), block(1, 9, "crimson"), block(2, 4, "crimson"), block(3, 9, "crimson"), block(3, 4, "deep-sky-blue"), block(3, 8, "crimson"), block(0, 7, "purple"), block(1, 8, "crimson"), block(3, 6, "purple"), block(0, 9, "deep-sky-blue"), block(2, 9, "gold"), block(3, 7, "purple")]

#HEIGHT 13, WIDTH 7
board3 :: List<Block> = 
  [list: block(0, 6, "deep-sky-blue"), block(3, 7, "deep-sky-blue"), block(6, 4, "lime-green"), block(3, 5, "crimson"), block(6, 10, "deep-sky-blue"), block(1, 11, "purple"), block(4, 8, "deep-sky-blue"), block(3, 12, "deep-sky-blue"), block(6, 9, "crimson"), block(6, 7, "crimson"), block(0, 5, "deep-sky-blue"), block(1, 12, "gold"), block(4, 9, "deep-sky-blue"), block(3, 6, "crimson"), block(3, 4, "purple"), block(5, 7, "crimson"), block(2, 8, "purple"), block(2, 5, "lime-green"), block(3, 11, "gold"), block(5, 10, "lime-green"), block(3, 8, "crimson"), block(6, 12, "lime-green"), block(0, 4, "lime-green"), block(0, 9, "lime-green"), block(4, 7, "gold"), block(5, 4, "lime-green"), block(5, 12, "deep-sky-blue"), block(4, 6, "gold"), block(6, 11, "gold"), block(2, 9, "lime-green"), block(2, 10, "lime-green"), block(0, 12, "crimson"), block(1, 8, "purple"), block(6, 8, "crimson"), block(5, 5, "purple"), block(4, 4, "purple")]



initial :: World = world(randomer(), board0)

interact(reactor:
  init:initial,  
  on-key:key-responder, 
  to-draw:world-displayer,
  on-tick:tick,
    seconds-per-tick: 0.25 # 1/4 second ticks

  end)


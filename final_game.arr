import lists as L
include image
include shared-gdrive("image115.arr", "1eSV5o5JQqKA8bBpA3ijknR7KOV6SUYiw")
include reactors

#|
   
   20/20
   only suggestion for improvement would be to try using 
   some higher-order functions next time; e.g. key-l/r-helper
   
   
   
   
   
   
   
   ***************************************
   Please fill out the following survey:
   https://www.surveymonkey.com/r/comp115
   ***************************************
   
   
   
   
   
   
   
   
   
|#


#|
  
 PROJECT IDEA:
   
   Implement a Breakout-style game
   https://www.youtube.com/watch?v=Up-a5x3coC0
   (originally released in 1976, and an early collaboration between 
    later Apple co-founders Steve Wozniak and Steve Jobs).  
  
   MVP (70%): 
   * There should be multiple rows of blocks, and a ball.
   * The left and right keys move the paddle.  
   * When the ball bounces off a block, that block disappears.
   * The ball also bounces off the top, left, and right of the screen.
   * A score counter shows how many blocks have been cleared.
   * When the ball falls off the bottom of the screen, pressing a key
     should start a new ball.
   
   Additional features (30%): 
   * Give the player some control over the angle/speed that the ball
     bounces at, by making the place at which the ball hits a paddle
     or block change the way the ball bounces.  
   * Give more points in the score when blocks in higher rows are cleared.  
   * Keep track of how many new balls the player has used (how many misses).  
   * Add the ability to have multiple paddles and/or multiple balls
     at once: 
     https://www.youtube.com/watch?v=QIs3UOTdsJM
     The number of rows, and the placement of the blocks and balls
     should be configurable by changing variables in the program.
   
   OPTIONAL BONUS TASKS:
   * Make the game have a few different levels 
     with different initial arrangements of blocks; clearing 
     one level takes you to a new one.
   * Make different blocks have different physics (e.g. 
     slower or faster or different angle bounces).

|#

# -------------------------------------------------------------------

# some list functions that might be helpful 

fun contains<A>(f :: (A -> Boolean), l :: List<A>) -> Boolean:
  doc: "check if there is some element of l for which f returns true"
  L.any(f,l)
where:
  fun positive(n): n > 0 end
  contains(positive,[list: 1,2,3,-2,4,-5]) is true
end

fun append<A>(l1 :: List<A>, l2 :: List<A>) -> List<A>:
  doc: "merge l1 and l2 into one list, with l1 before l2"
  L.append(l1,l2)
where:
  append([list:4,6,8], [list:1,2,3]) is [list: 4,6,8,1,2,3]
end

fun length<A>(l :: List<A>) -> Number:
  doc: "get the length of the list l"
  L.length(l)
end

#| this one is built-in with this name
fun map<A,B>(f :: (A -> B), l :: List<A>) -> List<B>:
  doc: "apply f to each element of the list, and return the list of results"
  map(f,l)
where:
  fun plus1(n): n + 1 end
  map(plus1, [list: 1,2,3]) is [list: 2,3,4]
end
|#

fun keep<A>(f :: (A -> Boolean), l :: List<A>) -> List<A>:
  doc: "keep all and only the elements of l for which f returns true"
  L.filter(f,l)
where:
  fun positive(n): n > 0 end
  keep(positive,[list: 1,2,3,-2,4,-5]) is [list: 1,2,3,4]
end

fun take<A>(l :: List<A>, n :: Number) -> List<A>:
  doc: "get a list containing the first n elements of l"
  l.take(n)
where:
  take([list: 3,7,6,2],3) is [list: 3,7,6]
end

fun sort<A>(before :: (A,A -> Boolean), l :: List<A>) -> List<A>:
  doc: "sort the list l, where x goes before y when before(x,y) is true"
  L.sort-by(l,lam(x,y): before(x,y) and not(before(y,x)) end,
    lam(x,y): before(x,y) and before(y,x) end)
end

# -------------------------------------------------------------------
WIDTH :: Number = 900
HEIGHT :: Number = 500

block-width :: Number = 75
block-height :: Number = 40
ball-size :: Number = 6
paddle-length :: Number = 120
paddle-height :: Number = 20

background :: Image = rectangle(WIDTH, HEIGHT, "solid", "black")

top-block :: Image = rectangle( block-width, block-height, "solid", "red" )
two-block :: Image = rectangle( block-width, block-height, "solid", "orange" )
three-block :: Image = rectangle( block-width, block-height, "solid", "yellow" )
four-block :: Image = rectangle( block-width, block-height, "solid", "blue") 

ball-disp :: Image= circle(ball-size, "solid", "gray")
paddle-disp :: Image = rectangle(paddle-length, paddle-height, "solid", "white")



data Block:
  |block(horiz :: Number, height :: Number)
end

data Ball:
  |ball(x :: Number, y :: Number, x-velocity :: Number, y-velocity :: Number)
end

data Paddle:
  |paddle(pad-x :: Number)
end

data World:
  |world(balls :: List<Ball>, stuff :: List<Block>, pads :: List<Paddle>, points :: Number, deaths :: Number)
end

starting-blocks :: List<Block> = 
  [list: block(0, 0), block(1, 0), block(2, 0), block(3, 0), block(4,0), block(5,0), block(6,0), block(7,0), block(8,0), block(9, 0), block(10, 0), block(11, 0), block(0, 1), block(1, 1), block(2, 1), block(3, 1), block(4,1), block(5,1), block(6,1), block(7,1), block(8,1),block(9, 1), block(10, 1), block(11, 1), block(0, 2), block(1, 2), block(2, 2), block(3, 2), block(4,2), block(5,2), block(6,2), block(7,2), block(8,2), block(9,2), block(10, 2), block(11, 2),  block(0, 3), block(1, 3), block(2, 3), block(3, 3), block(4,3), block(5,3), block(6,3), block(7,3), block(8,3), block(9, 3), block(10, 3), block(11, 3)]

two-paddles :: List<Paddle> =
[list: paddle(0), paddle( WIDTH / 2)]

two-balls :: List<Ball> =
  [list: ball(100,250, 4,4), ball( 600, 350, -4, 4)]

fun displayer-help(blockz :: List<Block>)-> Image:
  doc: "Helps display all of our blocks"
  cases(List<Block>) blockz:
    |empty=> rectangle(1,1, "solid", "transparent")
    |link(first,rest)=>
      cases(Block) first:
        |block(x,y)=> if y == 0: overlay-at(top-block, (x * block-width), (y * block-height), displayer-help(rest))
              else if y == 1:overlay-at(two-block, (x * block-width), (y * block-height), displayer-help(rest))
          else if y == 2: overlay-at(three-block, (x * block-width), (y * block-height), displayer-help(rest))
          else:
            overlay-at(four-block, (x * block-width), (y * block-height), displayer-help(rest))
          end
      end
  end
end

fun paddler( l :: List<Paddle>)-> Image:
  doc: "displays our list of paddles"
  cases(List<Paddle>) l:
    |empty=> rectangle(1,1,"solid","transparent")
    |link(first,rest)=> 
      cases(Paddle) first:
        |paddle(pad-x)=> overlay-at(paddle-disp, pad-x, 0, paddler(rest))
      end
  end
end

fun baller( l :: List<Ball>)-> Image:
  doc: "displays our list of balls"
  cases(List<Ball>) l:
    |empty=> rectangle(1,1,"solid","transparent")
    |link(first,rest)=> 
      cases(Ball) first:
        |ball(x,y,x-vel,y-vel)=> overlay-at(ball-disp, x, y, baller(rest))
      end
  end
end

fun score-help(b :: Block)-> Number:
  doc: "Gives each block a score according to its y-value"
  cases(Block) b:
    |block(x,y)=> if y == 0 : 40
      else if y == 1: 30
      else if y == 2: 20
      else: 10
      end
  end
where: score-help(block(2,4)) is 10
end

fun score-help-2(l :: List<Block>)-> Number:
  doc: "Aggregates the values of all the blocks"
  cases(List<Block>) l:
    |empty=> 0
    |link(first,rest)=> score-help(first) + score-help-2(rest)
      
  end
  
where:score-help-2(starting-blocks) is 1200
end

fun score-keeper(l :: List<Block>)-> Number:
  doc: "fixes the function above by counting upwards"
  
  1200 - score-help-2(l)
  
where: score-keeper(starting-blocks) is 0
end

fun world-displayer-help2(w :: World)-> Image:
  doc: "Helps display the block, paddles, and balls"
  cases(World) w:
    |world(balls,stuff,pads,points,deaths)=> overlay-at(baller(balls),0,0,overlay-at( paddler(pads), 0, (HEIGHT - paddle-height), overlay-at(displayer-help(stuff),0,0,background)))
  end
end

fun world-displayer(w:: World)-> Image:
  doc: "Displays our whole word (deaths/ points added)"
  cases(World)w:
    |world(balls,stuff,pads,points,deaths)=>
      above(beside(beside(beside((text("Score:", 40, "black")),text(num-to-string(score-keeper(stuff)),40,"black")),(text(" Deaths:", 40, "black"))),text(num-to-string(deaths),40,"black")),world-displayer-help2(w))
  end
end

fun key-l-helper(l :: List<Paddle>)-> List<Paddle>  :
  doc: "moves the paddles to the left"
  cases(List<Paddle>) l:
    |empty=> empty
    |link(first,rest)=> 
  cases(Paddle) first:
    |paddle(x)=> 
          link(paddle(x - 25), key-l-helper(rest))
  end
end
where: key-l-helper(two-paddles) is [list: paddle(-25), paddle(425)]
end

fun key-r-helper(l :: List<Paddle>)-> List<Paddle>  :
  doc: "moves the paddles to the right"
  cases(List<Paddle>) l:
    |empty=> empty
    |link(first,rest)=> 
  cases(Paddle) first:
    |paddle(x)=> 
          link(paddle(x + 25), key-r-helper(rest))
  end
end
where: key-r-helper(two-paddles) is [list: paddle(25), paddle(475)]
end




fun key-responder(w :: World, s :: String)-> World:
  doc: "Updates paddle positions and resets the ball positions"
  cases(World) w:
    |world(balls,stuff,pad,points,death)=>
      cases(List<Paddle>) pad:
        |empty=> empty
        |link(first,rest)=>
          if s == "right" : world(balls,stuff, key-r-helper(pad), points, death)
            
          else if s == "left": world(balls,stuff,key-l-helper(pad), points, death)
          else if s == "a": world(two-balls,stuff,key-l-helper(pad), points, death + 1)
        else: w
          end
      end
  end
end

fun x-deflect-block(b :: Ball, l :: List<Block>)-> Boolean:
  doc: "Yields true if the ball hits something on the side"
  cases(List<Block>) l :
    |empty=> false
    |link(first,rest)=>
      cases(Block) first:
        |block(xb,yb)=>
          cases(Ball) b:
            |ball(x,y,x-vel,y-vel)=> 
              if ((x + (2 * ball-size)) >= WIDTH) or (x <= 0): true
              else if (((((xb ) * block-width) + (0.1 * block-width)) > (x  + (2 * ball-size))))  and (((xb ) * block-width) < (x + (2 * ball-size)))  and (((yb * block-height) + (0.2 * block-height)) <= y) and ((((yb + 1) * (block-height)) - (0.2 * block-height)) >= y) and (x-vel > 0): true
              else if  ((((xb + 1) * block-width) - (0.1 * block-width)) < x)  and ((((xb + 1) * block-width) + 2)  > x)  and (((yb * block-height) + (0.2 * block-height)) <= y) and ((((yb + 1) * (block-height)) - (0.2 * block-height)) >= y) and (x-vel < 0): true
              else if x-deflect-block(b,rest) == true: true
             
              else: false
              end
          end
      end
  end
where: x-deflect-block(ball(WIDTH,3,2,4), starting-blocks) is true
end

fun y-deflect-block(b :: Ball, l :: List<Block>)-> Boolean:
  doc: "Yields true if the ball should change y-direction"
  cases(List<Block>) l:
    |empty=> false
    |link(first,rest)=> 
      cases(Block) first:
        |block(xb,yb)=>
          cases(Ball) b:
            |ball(x,y,x-vel,y-vel)=>
              if (((((yb) * block-height) + (0.3 * block-height)) > y))  and (((yb ) * block-height) < y)  and((xb * block-width) <= x) and (((xb + 1) * block-width) >= x) and (y-vel > 0): true
              else if  ((((yb + 1) * block-height) - (0.3 * block-height)) < y)  and (((yb + 1) * block-height)  > y) and ((xb * block-width) <= x) and (((xb + 1) * block-width) >= x) and (y-vel < 0): true

              else if y >= (HEIGHT - (2 * ball-size)): true
              else if y < 0: true
              else if y-deflect-block(b, rest) == true: true

              else: false

              end
          end
      end
  end
where: y-deflect-block(ball(50,60,3,-3),starting-blocks) is false
end



fun pad-check(b:: Ball, p :: List<Paddle>)-> String:
  doc: "checks if/ where the ball hits a paddle"
  cases(List<Paddle>) p :
    |empty=> "miss"
    |link(first,rest)=>
      cases(Paddle) first:
        |paddle(xp)=>
          cases(Ball) b:
            |ball(x,y,x-vel,y-vel)=> 
              if (x <= (xp + (paddle-length / 3))) and (x >= xp) and ((y + (2 * ball-size)) >= (HEIGHT - paddle-height)) and (y-vel > 0): "faster"
              else if (x >= (xp + (paddle-length / 3))) and (x <= (xp + ((2 / 3) * paddle-length))) and ((y + (2 * ball-size))  >= (HEIGHT - paddle-height)) and (y-vel > 0): "slower"
              else if (x <= (xp + (paddle-length))) and (x >= (xp + ((2 / 3) * paddle-length))) and ((y + (2 * ball-size))  >= (HEIGHT - paddle-height)) and (y-vel > 0): "faster"
                
              else if pad-check(b,rest) == "faster": "faster"
              else if pad-check(b,rest) == "slower": "slower"
              else: "miss"
              end
          end
      end
  end
end

fun ball-help1(b :: Ball, p :: List<Paddle>, l :: List<Block>)-> Ball:
  doc: "Changes the speed and direction of the ball, using the helpers above"
  cases(Ball)b:
    |ball(x,y,x-vel,y-vel)=>
      if (x-deflect-block(b,l) ) == true : ball(x,y, (-1 * x-vel), y-vel)
      
      else if y-deflect-block(b,l) == true: ball(x,y,x-vel,(-1 * y-vel))
            
      else if pad-check(b,p) == "faster": ball(x,y, x-vel * 1.25, -1.25 * (y-vel))
      else if pad-check(b,p) == "slower": ball(x,y, x-vel * 0.75, -0.75 * (y-vel))
      else: b
      end
  end
end


fun ball-help2(b :: List<Ball>, p :: List<Paddle>, l :: List<Block>)-> List<Ball>:
  doc: "repeats the function above for the list of balls"
  cases(List<Ball>) b:
    |empty=> empty
      |link(first,rest)=> 
      link(ball-help1(first,p,l), ball-help2(rest,p,l))
  end
end
  
fun bottom-hit(b :: Ball)-> Boolean:
  doc: "checks if the ball hits the bottom of the screen"
  cases(Ball) b:
    |ball(x,y,x-vel,y-vel)=> if (y + (2 * ball-size)) >= HEIGHT: true else: false
      end
  end
where: bottom-hit(ball(1,1000,2,3)) is true
end

fun bottom-hit-2(l :: List<Ball>)-> Boolean:
  doc: "Repeats the function above for the list of balls"
  cases(List<Ball>) l:
    |empty=> false
    |link(first,rest)=> if bottom-hit(first) == true: true
      else if bottom-hit-2(rest) == true: true
      else: false
      end
  end
where: bottom-hit-2([list: ball(665, 185, 5, 5), ball(10, 310, -5, 5)]) is false
end


fun destroyer-help( b :: Ball, l :: List<Block>)-> List<Block>:
  doc: "Checks if a block should be destroyed"
  cases(List<Block>) l:
    |empty=> empty
      |link(first,rest)=> 
        cases(Ball) b:
          |ball(x,y,x-vel,y-vel)=>
        cases(Block) first:
            |block(xb,yb)=> if ((y-deflect-block(b,l) == true ) or (x-deflect-block(b,l) == true)) and  ((yb * block-height) <= y) and (((yb + 1) * block-height) >= y ) and ((xb * block-width) <= x) and ((((xb + 1) * block-width)) >= x) : rest
              else: link(first,destroyer-help(b,rest))
                  end
                end
            end
        end
  end



fun destroyer(b :: List<Ball>, l :: List<Block>)-> List<Block>:
  doc: "destroys the block that the ball hits"
  cases(List<Ball>) b:
    |empty=> l
    |link(first,rest)=> destroyer(rest, destroyer-help(first,l))
  end
end






fun tic-help(l :: List<Ball>)-> List<Ball>:
  doc: "adjusts the positions of the balls as times goes on"
  cases(List<Ball>) l:
    |empty=> empty
    |link(first,rest)=>
      cases(Ball) first:
        |ball(x,y,x-vel,y-vel)=> 
          if bottom-hit-2(l) == true: l
          else:
          link(ball(x + x-vel, y + y-vel, x-vel, y-vel), tic-help(rest))
      end
  end
end


end


fun respond-tic(w :: World)-> World:
  doc: "Updates each portion of the world, using helpers, as time moves on"
  cases(World) w:
    |world(balls,stuff,pads,points,deaths)=> world(tic-help(ball-help2(balls,pads,stuff)),destroyer(balls,stuff),pads,points,deaths)
  
end
end

initial :: World = world(two-balls,starting-blocks, two-paddles, 0 , 0)   
    
interact(reactor:
    init:initial  ,
  on-key:key-responder, 
    
    on-tick: respond-tic,
    to-draw: world-displayer,
    seconds-per-tick: 1/15

  end)

#thanks so much for everything this semester. I learned a lot and had a bunch of fun. This was my favorite class of my freshmen year! I hope that I am in one of your classes again in the near future.

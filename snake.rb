require 'ruby2d'

set background: 'black'
set title: "Shane's Snake game"
set fps_cap: 30
set width: 640
set height: 480

GRID_SIZE = 28

class Snake
    def initialize
        @positions = [[0,2],[1,2],[2,2],[3,2]] #Starting point
        @direction = 'right' #Starting direction
        @head_rotation = 0 # Sets starting rotation of the snake head image
    end

    def reset #Restarts the game
        initialize
    end

    def draw
        #Creates each sqaure snake occupies
        @positions.each do |position|
            @body = Image.new(
                'snake-body.png',
                x: position[0] * GRID_SIZE,
                y: position[1] * GRID_SIZE,
                width: GRID_SIZE,
                height: GRID_SIZE,
                z: 10
            )
        end
        if @positions.last
            Image.new(
                'snake-head.png',
                x: @positions.last[0] * GRID_SIZE,
                y: @positions.last[1] * GRID_SIZE,
                width: GRID_SIZE,
                height: GRID_SIZE,
                rotate: @head_rotation,
                z: 10
                )
        end
    end

    def snake_head
        @positions.last #returns the position of the snakes head
    end


    def move
        if @positions.length > 3
            @positions.shift # removes butt end of the snake
            case @direction
            when 'down'
                @positions.push([snake_head[0],snake_head[1] + 1]) #Adds new square to the end to create movement
                @head_rotation = 90
            when 'up'
                @positions.push([snake_head[0],snake_head[1] - 1])
                @head_rotation = 270
            when 'left'
                @positions.push([snake_head[0] - 1,snake_head[1]])
                @head_rotation = 180
            when 'right'
                @positions.push([snake_head[0] + 1,snake_head[1]])
                @head_rotation = 0
            end
        end
    end

    def direction(to)
        @direction = to #method to set snakes current direction
    end

    def position
        @positions
    end

    def grow
        case @direction #Snake grows 1 square in the direction it's travelling
        when 'down'
            @positions.append([snake_head[0],snake_head[1] + 1])
        when 'up'
            @positions.append([snake_head[0],snake_head[1] - 1])
        when 'left'
            @positions.append([snake_head[0] - 1,snake_head[1]])
        when 'right'
            @positions.append([snake_head[0] + 1,snake_head[1]])
        end
    end

end

class Apple
    def initialize
        @position = [rand(Window.width / GRID_SIZE-1),rand(Window.height / GRID_SIZE-1)] #Starting point
    end

    def draw
        #Creates apple sqaure

        Image.new(
            'apple2.png',
            x: @position[0] * GRID_SIZE,
            y: @position[1] * GRID_SIZE,
            width: GRID_SIZE,
            height: GRID_SIZE,
            z: 10
          )
    end

    def current_position
        @position
    end

    def new_position
        @position = [rand(Window.width / GRID_SIZE-1),rand(Window.height / GRID_SIZE-1)] #Sets new position for the apple when eaten
    end
end

class Arena
    def initialize #Player starts on 1 point
        @points = 1
    end

    def draw #Display Score counter and background image
        Text.new(
        "Score: #{@points}",
            x: Window.width - 120, y: 2, # Text position (top right)
            size: 20,
            color: 'black'
        )

        Image.new(
            'snake-background.png',
            x: 0, y: 0,
            width: Window.width, height: Window.height,
            z: -1
          )
    end

    def increment_score #Increments score by 1
        @points +=1
    end

    def reset
        initialize
    end

end

class Start_Screen
    Text.new(
        "Shane's Snake Game",
        x: 50, y: 80,
        style: 'bold',
        size: 30,
        color: 'green',
        z: 10
      )
      Text.new(
        "Press P to play",
        x: 50, y: 160,
        size: 25,
        color: 'red',
        z: 10
      )
end

start = Start_Screen.new #Opens start screen

@play = false #Gameplay turned off till player hits P
@frame_number = 0 #Sets frame counter to 0
@slowness = 8 # Snakes starting speed - a slow number 8

snake = Snake.new #Sets the snakes size, position, direction etc

apple = Apple.new #Adds the apple

arena = Arena.new #Creates the Score counter and background

update do #Actions carried out for every frame
    next unless @play #Doesn't execute unless the game as started
    @frame_number += 1 #Counts each frame
    next unless @frame_number % @slowness == 0 #Controls the speed of the game by only executing on certain frames
    clear
    snake.move
    #Makes snake, apple and arena visible
    snake.draw
    apple.draw
    arena.draw
    #Checks if snake is out of bounds
    if snake.snake_head[0] == Window.width / GRID_SIZE || snake.snake_head[0] < 0 || 
        snake.snake_head[1] == Window.height / GRID_SIZE || snake.snake_head[1] < 0
            snake.reset
            apple.new_position
            arena.reset
    end
    #Checks if snake touches itself
    if snake.position.uniq.length < snake.position.length #checks for duplicate positions
        snake.reset
        apple.new_position
        arena.reset
        @slowness = 8 #Resets snake back to original speed
    end
    #Snake eats Apple
    if snake.position.include? (apple.current_position)
        apple.new_position
        snake.grow
        arena.increment_score
        @slowness -= 1 unless @slowness < 3 #Increases the speed of the snake
    end
end



on :key_down do |event| # When a key is pressed do
    if ['left', 'right','up','down'].include?(event.key) # Is the key a valid direction?
        snake.direction(event.key) #Set the direction to the corresponding key
    end
    if ['p'].include?(event.key)
        @play = true
        clear
    end
end

show #Opens ruby2d window
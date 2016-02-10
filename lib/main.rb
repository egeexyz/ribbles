require 'gosu'

# Still chilling
module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

# Just chilling
class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = 'Ribbles'

    @background_image = Gosu::Image.new('assets/images/space.png',
                                        tileable: true)

    @player = Player.new
    @player.warp(320, 240)
    @font = Gosu::Font.new(20)
    @star_anim = Gosu::Image.load_tiles('assets/images/star.png', 25, 25)
    @stars = []
  end

  def update
    if Gosu.button_down? Gosu::KbLeft
      @player.turn_left
    end
    if Gosu.button_down? Gosu::KbRight
      @player.turn_right
    end
    if Gosu.button_down? Gosu::KbUp
      @player.accelerate
    end
    @player.move
    @player.collect_stars(@stars)

    if rand(100) < 4 && @stars.size < 25
      @stars.push(Star.new(@star_anim))
    end
  end

  def draw
    @background_image.draw(0, 0, 0)
    @player.draw
    @stars.each { |star| star.draw }
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end
end

# Just chilling again
class Player
  attr_reader :score

  def initialize
    @image = Gosu::Image.new('assets/images/starfighter.bmp')
    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu.offset_x(@angle, 0.5)
    @vel_y += Gosu.offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def collect_stars(stars)
    if stars.reject! { |star| Gosu.distance(@x, @y, star.x, star.y) < 35 }
      @score += 1
    end
  end
end

#
class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff_000000)
    @color.red = rand(256 - 40) + 40
    @color.green = rand(256 - 40) + 40
    @color.blue = rand(256 - 40) + 40
    @x = rand * 640
    @y = rand * 480
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    img.draw(@x - img.width / 2.0,
             @y - img.height / 2.0,
             ZOrder::STARS,
             1,
             1,
             @color,
             :add)
  end
end

window = GameWindow.new
window.show

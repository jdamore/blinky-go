require 'blinky'

def light pos
  blinky = Blinky.new
  blinky.lights[pos]
end
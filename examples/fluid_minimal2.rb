
require 'pixelflow' # library as a gem

include PixelFlow
include Fluid

#
# PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
# Modified for JrubyArt by Martin Prout
# A Processing/Java library for high performance GPU-Computing (GLSL).
# MIT License: https://opensource.org/licenses/MIT
#











# Simple example that shows how to add Data (density, velocity) to the fluid.
#
# controls:
#
# LMB: add Density + Velocity
# MMB: add Velocity
# RMB: add Velocity






VIEWPORT_W = 1280
VIEWPORT_H = 720
VIEWPORT_X = 230
VIEWPORT_Y = 0
BACKGROUND_COLOR = 255

#  int viewport_w = 800
#  int viewport_h = 800
attr_reader :fluidgrid_scale, :fluid, :pg_fluid, :pg_obstacles, :context

def settings
  size(VIEWPORT_W, VIEWPORT_H, P2D)
  smooth(2)
end




def setup
  surface.setLocation(VIEWPORT_X, VIEWPORT_Y)
  # main library context
  @context = DwPixelFlow.new(self)
  context.print
  context.printGL
  # fluid simulation
  @fluid = Fluid::DwFluid2D.new(context, VIEWPORT_W, VIEWPORT_H, fluidgrid_scale)

  @fluidgrid_scale = 1
  # set some simulation parameters
  fluid.param.dissipation_density     = 0.98
  fluid.param.dissipation_velocity    = 0.92
  fluid.param.dissipation_temperature = 0.69
  fluid.param.vorticity               = 0.10

  # interface for adding data to the fluid simulation
  fluid.addCallback_FluiData(MyFluidData.new)

  # pgraphics for fluid
  @pg_fluid = createGraphics(VIEWPORT_W, VIEWPORT_H, P2D)
  pg_fluid.smooth(4)

  # pgraphics for obstacles
  @pg_obstacles = createGraphics(VIEWPORT_W, VIEWPORT_H, P2D)
  pg_obstacles.noSmooth
  pg_obstacles.beginDraw
  pg_obstacles.clear
  # rand obstacles
  pg_obstacles.rectMode(CENTER)
  pg_obstacles.noStroke
  pg_obstacles.fill(64)
  srand(0)
  80.times do
    px = rand(width)
    py = rand(height)
    sx = rand(15..60)
    sy = rand(15..60)
    pg_obstacles.rect(px, py, sx, sy)
  end
  # border-obstacle
  pg_obstacles.rectMode(CORNER)
  pg_obstacles.strokeWeight(20)
  pg_obstacles.stroke(64)
  pg_obstacles.noFill
  pg_obstacles.rect(0, 0, pg_obstacles.width, pg_obstacles.height)
  pg_obstacles.endDraw
  # add to the fluid-solver
  fluid.addObstacles(pg_obstacles)
  frameRate(60)
end


def draw
  # update simulation
  fluid.update
  # clear render target
  pg_fluid.beginDraw
  pg_fluid.background(BACKGROUND_COLOR)
  pg_fluid.endDraw
  # render fluid stuff
  fluid.renderFluidTextures(pg_fluid, 0)
  # display
  image(pg_fluid    , 0, 0)
  image(pg_obstacles, 0, 0)

  # info

  format_string = 'Fluid Minimal  [size %d/%d]  [frame %d]  [fps: (%6.2f)]'
  surface.set_title(format(format_string, fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frame_rate))
end

class MyFluidData
  include Fluid::DwFluid2D::FluidData
  # include Processing::Proxy
  def update(fluid)
    if mouse_pressed?
      vscale = 15
      px     = mouseX
      py     = height-mouseY
      vx     = (mouseX - pmouseX) * +vscale
      vy     = (mouseY - pmouseY) * -vscale
      radius = 20
      intensity = 1.0
      temperature = 5.0

      fluid.addVelocity(px, py, radius, vx, vy)

      if mouse_button == LEFT
        fluid.addTemperature(px, py, radius, temperature)

        radius = 20
        fluid.add_density(px, py, radius, 0, 0, 0, intensity)
        radius = 16
        fluid.add_density(px, py, radius, 0, 0.4, 1, intensity)
      end
    end
  end
end

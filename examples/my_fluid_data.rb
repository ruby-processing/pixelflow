class MyFluidData
  include DwFluid2D::FluidData
  include Processing::Proxy
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

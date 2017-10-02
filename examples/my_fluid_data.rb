class MyFluidData < com.thomasdiewald.pixelflow.java.fluid.DwFluid2D::FluidData
  include Processing::Proxy

  # this is called during the fluid-simulation update step.
  def update(fluid)
    if !cp5.isMouseOver && mouse_pressed?
      vscale = 15
      px     = mouse_x
      py     = height - mouse_y
      vx     = (mouse_x - pmouse_x) * +vscale
      vy     = (mouse_y - pmouse_y) * -vscale

      if mouse_button == LEFT
        radius = 20
        fluid.add_velocity(px, py, radius, vx, vy)
      end
      if mouse_button == CENTER
        radius = 50
        fluid.add_density(px, py, radius, 1.0, 0.0, 0.40, 1.0, 1)
      end
      if mouse_button == RIGHT
        radius = 15
        fluid.add_temperature(px, py, radius, 15.0)
      end

    end


#      px = view_w/2
#      py = 50
#      radius = 50
#      fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1)
#      fluid.addTemperature(px, py, radius, 5)

    # use the text as input for density
    add_density_texture(fluid, opticalflow) if ADD_DENSITY_MODE == 0
    add_density_texture_cam(fluid, opticalflow) if ADD_DENSITY_MODE == 1
    add_temperature_texture(fluid, opticalflow)
    add_velocity_texture(fluid, opticalflow)
  end

  # custom shader, to add density from a texture (PGraphics2D) to the fluid.
  def add_density_texture(fluid, opticalflow)
    context.begin
    context.beginDraw(fluid.tex_density.dst)
    shader = context.createShader(data_path('addDensity.frag'))
    shader.begin
    shader.uniform2f("wh", fluid.fluid_w, fluid.fluid_h)
    shader.uniform1i("blend_mode", 6)
    shader.uniform1f("multiplier", 3)
    shader.uniform1f("mix_value", 0.1)
    shader.uniformTexture("tex_opticalflow", opticalflow.frameCurr.velocity)
    shader.uniformTexture("tex_density_old", fluid.tex_density.src)
    shader.drawFullScreenQuad
    shader.end
    context.endDraw
    context.end("app.add_density_texture")
    fluid.tex_density.swap
  end


  def add_density_texture_cam(fluid, opticalflow)
    pg_tex_handle = []

    return unless pg_cam_a.getTexture.available

    mix = opticalflow.UPDATE_STEP > 1 ? 0.01 : 1.0

    context.begin
    context.getGLTextureHandle(pg_cam_a, pg_tex_handle)
    context.beginDraw(fluid.tex_density.dst)
    @shader = context.createShader(data_path('addDensityCam.frag'))
    shader.begin
    shader.uniform2f("wh"        , fluid.fluid_w, fluid.fluid_h)
    shader.uniform1i("blend_mode", 6)
    shader.uniform1f("mix_value" , mix)
    shader.uniform1f("multiplier", 1)
    # shader.uniformTexture("tex_ext", opticalflow.tex_frames.src)
    shader.uniformTexture("tex_ext", pg_tex_handle[0])
    shader.uniformTexture("tex_src", fluid.tex_density.src)
    shader.drawFullScreenQuad
    shader.end
    context.endDraw
    context.end("app.addDensityTexture")
    fluid.tex_density.swap
  end

  # custom shader, to add temperature from a texture (PGraphics2D) to the fluid.
  def add_temperature_texture(fluid, opticalflow)
    context.begin
    context.beginDraw(fluid.tex_temperature.dst)
    shader = context.create_shader(data_path('addTemperature.frag'))
    shader.begin
    shader.uniform2f("wh"        , fluid.fluid_w, fluid.fluid_h)
    shader.uniform1i("blend_mode", 1)
    shader.uniform1f("mix_value" , 0.1)
    shader.uniform1f("multiplier", 0.05)
    shader.uniformTexture("tex_ext"   , opticalflow.frameCurr.velocity)
    shader.uniformTexture("tex_src"   , fluid.tex_temperature.src)
    shader.drawFullScreenQuad
    shader.end
    context.endDraw
    context.end("app.add_temperature_texture")
    fluid.tex_temperature.swap
  end

  # custom shader, to add density from a texture (PGraphics2D) to the fluid.
  def add_velocity_texture(fluid, opticalflow)
    context.begin
    context.beginDraw(fluid.tex_velocity.dst)
    DwGLSLProgram shader = context.create_shader(data_path('addVelocity.frag'))
    shader.begin
    shader.uniform2f("wh", fluid.fluid_w, fluid.fluid_h)
    shader.uniform1i("blend_mode", 2)
    shader.uniform1f("multiplier", 1.0)
    shader.uniform1f("mix_value", 0.1)
    shader.uniformTexture("tex_opticalflow", opticalflow.frameCurr.velocity)
    shader.uniformTexture("tex_velocity_old", fluid.tex_velocity.src)
    shader.drawFullScreenQuad
    shader.end
    context.endDraw
    context.end("app.add_density_texture")
    fluid.tex_velocity.swap
  end
end

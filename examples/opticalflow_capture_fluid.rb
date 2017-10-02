# PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
#
# A Processing/Java library for high performance GPU-Computing (GLSL).
# MIT License: https://opensource.org/licenses/MIT


load_libraries :controlP5, :PixelFlow, :video

module OpticalFlo
  java_import 'com.thomasdiewald.pixelflow.java.DwPixelFlow'
  java_import 'com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram'
  java_import 'com.thomasdiewald.pixelflow.java.fluid.DwFluid2D'
  java_import 'com.thomasdiewald.pixelflow.java.imageprocessing.DwOpticalFlow'
  java_import 'com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter'
  java_import 'controlP5.Accordion'
  java_import 'controlP5.ControlP5'
  java_import 'controlP5.Group'
  java_import 'controlP5.RadioButton'
  java_import 'controlP5.Toggle'
end

include OpticalFlo


require_relative 'my_fluid_data'

CAM_W  = 640
CAM_H  = 480
VIEW_W  = 1200
VIEW_H  = (VIEW_W * CAM_H / CAM_W.to_f).floor
GUI_W = 200
GUI_X = VIEW_W
GUI_Y = 0
attr_reader :filter, :fluid, :cb_fluid_data, :opticalflow, :pg_cam_a, :pg_cam_b
attr_reader :context, :cam, :fluidgrid_scale, :display_particles
attr_reader :update_fluid, :display_fluid_textures, :display_fluid_vectors
attr_reader :display_fluid_texture_mode, :display_source, :apply_grayscale, :apply_bilateral
# some state variables for the GUI/display
BACKGROUND_COLOR = 0
VELOCITY_LINES = 6
ADD_DENSITY_MODE = 1

def settings
  size(VIEW_W  + GUI_W, VIEW_H , P2D)
  smooth(4)
end

def setup
  @fluidgrid_scale = 1
  @update_fluid = true
  @display_fluid_textures = true
  @display_fluid_vectors = false
  @display_particles = false
  @display_source = true
  @apply_grayscale = true
  @apply_bilateral = true
  # main library context
  @context = DwPixeFlow.new(self)
  context.print
  context.printGL

  @filter = DwFilter.new(context)

  # fluid object
  @fluid = DwFluid2.newD(context, VIEW_W , VIEW_H , fluidgrid_scale)

  # some fluid parameters
  fluid.param.dissipation_density     = 0.90
  fluid.param.dissipation_velocity    = 0.80
  fluid.param.dissipation_temperature = 0.70
  fluid.param.vorticity               = 0.30

  # calback for adding fluid data
  @cb_fluid_data = MyFluid_data.new
  fluid.addCallback_FluiData(cb_fluid_data)

  # optical flow object
  @opticalflow = DwOpticalFlow.new(context, CAM_W , CAM_H)

  # optical flow parameters
  opticalflow.param.display_mode = 1

  # webcam capture
  @cam = Capture.new(self, CAM_W, CAM_H, 30)
  cam.start

  # render buffers
  @pg_cam_a = create_graphics(CAM_W, CAM_H, P2D)
  pg_cam_a.noSmooth
  pg_cam_a.begin_draw
  pg_cam_a.background(0)
  pg_cam_a.end_draw

  @pg_cam_b = create_graphics(CAM_W , CAM_H , P2D)
  pg_cam_b.noSmooth

  @pg_fluid = create_graphics(VIEW_W , VIEW_H , P2D)
  pg_fluid.smooth(4)
  createGUI
  background 0
  frame_rate 60
end

def draw
  if cam.available
    cam.read
    # render to offscreenbuffer
    pg_cam_b.begin_draw
    pg_cam_b.background(0)
    pg_cam_b.image(cam, 0, 0)
    pg_cam_b.end_draw
    swap_cam_buffer # 'pg_cam_a' has the image now

    if apply_bilateral
      filter.bilateral.apply(pg_cam_a, pg_cam_b, 5, 0.10, 4)
      swap_cam_buffer
    end

    # update Optical Flow
    opticalflow.update(pg_cam_a)

    if apply_grayscale
      # make the capture image grayscale (for better contrast)
      filter.luminance.apply(pg_cam_a, pg_cam_b)
      swap_cam_buffer
    end
  end


  fluid.update if update_fluid


  # render everything
  pg_fluid.begin_draw
  pg_fluid.background(BACKGROUND_COLOR)

  pg_fluid.image(pg_cam_a, 0, 0, VIEW_W , VIEW_H ) if display_source && add_density_mode.zero?

  pg_fluid.end_draw

  # add fluid stuff to rendering

  fluid.renderFluidTextures(pg_fluid, display_fluid_texture_mode) if display_fluid_textures

  fluid.renderFluidVectors(pg_fluid, 10) if display_fluid_vectors
  # add optical flow stuff to rendering
  opticalflow.renderVelocityShading(pg_fluid) if opticalflow.param.display_mode == 2
  opticalflow.renderVelocityStreams(pg_fluid, VELOCITY_LINES)


  # display result
  background(0)
  image(pg_fluid, 0, 0)

  # info
  title_format = 'Optical Flow Capture | [size %d/%d] [frame %d] [fps %6.2f]'
  surface.set_title(format(title_format, CAM_W , CAM_H , opticalflow.UPDATE_STEP, frame_rate))
end

def swap_cam_buffer
  pg_cam_a, pg_cam_b = pg_cam_b, pg_cam_a
end

def fluid_resizeUp
  fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale))
end

def fluid_resizeDown
  fluid.resize(width, height, ++fluidgrid_scale)
end

def fluid_reset
  fluid.reset
end

def fluid_togglePause
  update_fluid = !update_fluid
end

def fluid_displayMode(val)
  @display_fluid_texture_mode = val
  @display_fluid_textures = display_fluid_texture_mode != -1
end

def fluid_displayVelocityVectors(val)
  display_fluid_vectors = val != -1
end

def fluid_displayParticles(val)
  display_particles = val != -1
end

def opticalFlow_setDisplayMode(val)
  opticalflow.param.display_mode = val
end

def activeFilters(val)
  @apply_grayscale = (val[0] > 0)
  @apply_bilateral = (val[1] > 0)
end

def setOptionsGeneral(val)
  @display_source = (val[0] > 0)
end

def setAdd_densityMode(val)
  @add_density_mode = val
end


def mouseReleased
end


def key_released
  case(key)
  when 'p'
    fluid_togglePause # pause / unpause simulation
  when '+'
    fluid_resizeUp    # increase fluid-grid resolution
  when '-'
    fluid_resizeDown  # decrease fluid-grid resolution
  when 'r'
    fluid_reset       # restart simulation
  when '1', '2', '3', '4'
    @display_fluid_texture_mode = key.to_i # density
  when 'q'
    @display_fluid_textures = !display_fluid_textures
  when 'w'
    @display_fluid_vectors = !display_fluid_vectors
  when 'e'
    @display_particles = !display_particles
  end
end

def createGUI
  @cp5 = ControlP5.new(self)
  sx = 100
  sy = 14
  oy = (sy*1.5).to_i


  ######################################
  # GUI - FLUID
  ######################################
  group_fluid = cp5.addGroup('fluid')

  group_fluid.setHeight(20).setSize(GUI_W, 300)
  .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180))
  group_fluid.getCaptionLabel.align(CENTER, CENTER)

  px = 10
  py = 15

  cp5.addButton('reset').setGroup(group_fluid).plugTo(this, 'fluid_reset'     ).setSize(80, 18).setPosition(px    , py)
  cp5.addButton('+'    ).setGroup(group_fluid).plugTo(this, 'fluid_resizeUp'  ).setSize(39, 18).setPosition(px+=82, py)
  cp5.addButton('-'    ).setGroup(group_fluid).plugTo(this, 'fluid_resizeDown').setSize(39, 18).setPosition(px+=41, py)

  px = 10

  cp5.addSlider('velocity').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py += (oy*1.5).to_i)
  .setRange(0, 1).setValue(fluid.param.dissipation_velocity).plugTo(fluid.param, 'dissipation_velocity')

  cp5.addSlider('density').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 1).setValue(fluid.param.dissipation_density).plugTo(fluid.param, 'dissipation_density')

  cp5.addSlider('temperature').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 1).setValue(fluid.param.dissipation_temperature).plugTo(fluid.param, 'dissipation_temperature')

  cp5.addSlider('vorticity').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 1).setValue(fluid.param.vorticity).plugTo(fluid.param, 'vorticity')

  cp5.addSlider('iterations').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 80).setValue(fluid.param.num_jacobi_projection).plugTo(fluid.param, 'num_jacobi_projection')

  cp5.addSlider('timestep').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 1).setValue(fluid.param.timestep).plugTo(fluid.param, 'timestep')

  cp5.addSlider('gridscale').setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 50).setValue(fluid.param.gridscale).plugTo(fluid.param, 'gridscale')

  rb_set_fluid_display_mode = cp5.addRadio('fluid_display_mode').setGroup(group_fluid).setSize(80,18).setPosition(px, py += (oy*1.5).to_i)
  .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(2)
  .addItem('Density'    ,0)
  .addItem('Temperature',1)
  .addItem('Pressure'   ,2)
  .addItem('Velocity'   ,3)
  .activate(display_fluid_texture_mode)
  rb_set_fluid_display_mode.get_items.each do |toggle|
    toggle.getCaptionLabel.alignX(CENTER)

    cp5.addRadio('fluid_displayVelocityVectors').setGroup(group_fluid).setSize(18,18).setPosition(px, py += (oy*2.5).to_i)
    .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
    .addItem('Velocity Vectors', 0)
    .activate(display_fluid_vectors ? 0 : 2)
  end



  ######################################
  # GUI - OPTICAL FLOW
  ######################################
  group_oflow = cp5.addGroup('Optical Flow')

  group_oflow.setSize(GUI_W, 165).setHeight(20)
  .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180))
  group_oflow.getCaptionLabel.align(CENTER, CENTER)

  px = 10
  py = 15

  cp5.addSlider('blur input').setGroup(group_oflow).setSize(sx, sy).setPosition(px, py)
  .setRange(0, 30).setValue(opticalflow.param.blur_input).plugTo(opticalflow.param, 'blur_input')

  cp5.addSlider('blur flow').setGroup(group_oflow).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 10).setValue(opticalflow.param.blur_flow).plugTo(opticalflow.param, 'blur_flow')

  cp5.addSlider('temporal smooth').setGroup(group_oflow).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 1).setValue(opticalflow.param.temporal_smoothing).plugTo(opticalflow.param, 'temporal_smoothing')

  cp5.addSlider('flow scale').setGroup(group_oflow).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 200).setValue(opticalflow.param.flow_scale).plugTo(opticalflow.param, 'flow_scale')

  cp5.addSlider('threshold').setGroup(group_oflow).setSize(sx, sy).setPosition(px, py+=oy)
  .setRange(0, 3.0).setValue(opticalflow.param.threshold).plugTo(opticalflow.param, 'threshold')

  cp5.addRadio('opticalFlow_setDisplayMode').setGroup(group_oflow).setSize(18, 18).setPosition(px, py+=oy)
  .setSpacingColumn(40).setSpacingRow(2).setItemsPerRow(3)
  .addItem('dir'    , 0)
  .addItem('normal' , 1)
  .addItem('Shading', 2)
  .activate(opticalflow.param.display_mode)
  # end



  ######################################
  # GUI - DISPLAY
  ######################################
  group_display = cp5.addGroup('display')

  group_display.setHeight(20).setSize(GUI_W, 175)
  .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180))
  group_display.getCaptionLabel.align(CENTER, CENTER)

  px = 10
  py = 15

  cp5.addSlider('BACKGROUND').setGroup(group_display).setSize(sx,sy).setPosition(px, py)
  .setRange(0, 255).setValue(BACKGROUND_COLOR).plugTo(this, 'BACKGROUND_COLOR')

  cp5.addCheckBox('setOptionsGeneral').setGroup(group_display).setSize(38, 18).setPosition(px, py += oy)
  .setItemsPerRow(1).setSpacingColumn(3).setSpacingRow(3)
  .addItem('display source', 0).activate(display_source ? 0 : 100)

  cp5.addCheckBox('activeFilters').setGroup(group_display).setSize(18, 18).setPosition(px, py += (oy * 1.5).to_i)
  .setItemsPerRow(1).setSpacingColumn(3).setSpacingRow(3)
  .addItem('grayscale'       , 0).activate(apply_grayscale ? 0 : 100)
  .addItem('bilateral filter', 1).activate(apply_bilateral ? 1 : 100)

  cp5.addRadio('setAdd_densityMode').setGroup(group_display).setSize(18,18).setPosition(px, py += (oy * 2.5).to_i)
  .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
  .addItem('color', 0)
  .addItem('camera', 1)
  .activate(ADD_DENSITY_MODE)
  # end


  ######################################
  # GUI - ACCORDION
  ######################################
  cp5.addAccordion('acc').setPosition(GUI_X, GUI_Y).setWidth(GUI_W).setSize(GUI_W, height)
  .setCollapseMode(Accordion::MULTI)
  .addItem(group_fluid)
  .addItem(group_oflow)
  .addItem(group_display)
  .open(0, 1, 2)
end

require 'RMagick'
require 'nokogiri'
require "ap"

class MindmapToImage

  attr_accessor :mindmap
  attr_accessor :map_hash
  attr_accessor :fixed_width,:fixed_height 

  include MindmapToImageParamMethods
  include MindmapToImageHashMethods
  include MindmapToImagePaintMethods

  def initialize(mindmap)
    @mindmap = mindmap
  end


  # 尝试导出导图为图片，返回临时文件地址
  def export(size_param)
    param = size_param.to_s

    @map_hash = get_nodes_hash(mindmap.struct)


    if param.include?('x')
      @fixed_width , @fixed_height = param.split('x').map{|x| x.to_i}
      return write_to_file(export_fixed)
    end

    @zoom = param.to_f
    return write_to_file(export_zoom)
  end

  # 尝试导出指定尺寸图片
  def export_fixed
    # 6.25 对于尺寸放大的图片，要做到清晰，目前没有比较好的方法，仍需修改
    @zoom = 1
    img          = export_zoom(false)

    min_scale = _get_min_scale(img)

    img.resize(min_scale)
  end

  # 此处用了ImgResizer的公用代码，将来换成统一的
  def _get_min_scale(img)
    w_scale = @fixed_width.to_f / img.columns
    h_scale = @fixed_height.to_f / img.rows
    return [w_scale , h_scale , 1].min
  end

  # 尝试导出放大缩小的图片
  def export_zoom(with_sign = true)

    image_width = _width_of_image(with_sign)
    image_height = _height_of_image

    img = Magick::Image.new(image_width, image_height, Magick::HatchFill.new('white','white'))

    paint_nodes(img)
    if with_sign
      paint_sign(img, image_width, image_height)
    end

    return img
  end

  def _height_of_image
    _height_of_mindmap.round
  end

  def _height_of_mindmap
    map_hash[:max_height] + height_padding
  end

  def _width_of_image(with_sign = true)
    if with_sign
      return [_width_of_mindmap, _width_min, _width_of_sign].max.round
    end
    return [_width_of_mindmap, _width_min].max.round
  end

  def _width_of_mindmap
    map_hash[:left_subtree_width] + map_hash[:width] + map_hash[:right_subtree_width] + width_padding
  end

  def _width_min
    200 + 50 + 120
  end

  def _width_of_sign
    get_text_size(mindmap.title).width +
    width_margin +
    get_text_size(_author_name).width
  end

  def _author_name
    " "
  end

  def write_to_file(img)
    file_path = "/tmp/#{randstr}.png"
    img.write(file_path)
    return file_path
  end

  def randstr(length=8)
    base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size = base.size
    re = ''<<base[rand(size-10)]
    (length-1).times  do
      re<<base[rand(size)]
    end
    re
  end
  
end
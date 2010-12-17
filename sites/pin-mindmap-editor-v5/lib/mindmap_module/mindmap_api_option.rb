class MindmapApiOption

#{"op"=>"do_title", "node"=>"dkhJoFru", "map"=>"192", "params"=>{"title"=>"根\345\205\253"}}
#{"op"=>"do_insert", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"parent"=>"0", "index"=>8}}
#{"op"=>"do_title", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"title"=>"根\344\271\235"}}
#{"op"=>"do_move", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"0", "index"=>0}}
#{"op"=>"do_move", "node"=>"dkhJoFru", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"0", "index"=>0}}
#{"op"=>"do_insert", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"parent"=>"3", "index"=>3}}
#{"op"=>"do_title", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"title"=>"三\345\233\233"}}
#{"op"=>"do_move", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"parent"=>"3", "putright"=>"1", "index"=>1}}
#{"op"=>"do_move", "node"=>"3", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"1", "index"=>4}}

  def initialize(oper_hash)
    @oper = oper_hash
    @operation = @oper["op"]
    @map_id = @oper["map"]
    @params = OptionParams.new(@oper["params"])
    raise 'operation 未指定' if @operation.blank?
    raise 'map_id 未指定' if  @map_id.blank?
  end

  # 操作类型
  def operation
    @operation
  end

  # 被操作的导图ID
  def map_id
    @map_id
  end

  # 被操作的导图对象
  def map
    Mindmap.find(@map_id)
  end

  # 操作的附加参数 参考/doc 下文档
  def params
    @params
  end


  class OptionParams
    def initialize(params_hash)
      @params = params_hash
    end

    def hash
      @params
    end

    # 父节点ID
    def parent_id
      _parent_id = @params["parent_id"]
      raise '父节点ID 未指定' if _parent_id.blank?
      return _parent_id
    end

    # 节点所在兄弟数组的下标，从0开始 -1 表示未指定
    def index
      _index = @params["index"]
      _index = -1 if _index.blank?
      return _index.to_i
    end

    def new_node_id
      _new_node_id = @params["new_node_id"]
      _new_node_id = randstr(8) if _new_node_id.blank?
      return _new_node_id
    end

    def title
      _title = @params["title"]
      _title = "NewSubNode" if _title.blank?
      return _title
    end

    def node_id
      _node_id = @params["node_id"]
      raise '节点ID 未指定' if _node_id.blank?
      return _node_id
    end

    def fold
      _fold = @params["fold"].to_s
      if _fold.blank?
        _fold = nil
      else
        raise "节点展开/关闭状态 #{_fold} 值指定错误，不是1或者0" if !["1","0"].include?(_fold)
      end
      return _fold
    end

    def image
      _image = MapParamsImage.new(@params["image"])
      return _image
    end

    def note
      _note = @params['note']
      return _note
    end

    def putright
      _putright = @params['putright']
      if _putright.blank?
        _putright = "1"
      else
        raise "节点放置侧状态 #{_putright} 值指定错误，不是1或者0" if !["1","0"].include?(_putright)
      end
      return _putright
    end

    class MapParamsImage
      def initialize(image_hash)
        @image = image_hash
      end

      def url
        _url = @image['url']
        raise '图片URL 未指定' if _url.blank?
        return _url
      end

      def width
        _width = @image["width"]
        _width = nil if _width.blank?
        return _width
      end

      def height
        _height = @image["height"]
        _height = nil if _height.blank?
        return _height
      end
    end
  end
end
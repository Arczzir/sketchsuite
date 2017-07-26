
Dir.chdir __dir__

require 'erb'
require 'json'
#require 'active_model'
require 'fileutils'



def pp(e)
 print JSON.pretty_generate(JSON.parse(e.to_json)) 
end

class JSONable
  #include ActiveModel::Serializers::JSON
  def instance_values
    Hash[instance_variables.map { |name| [name[1..-1], instance_variable_get(name)] }]
  end

  def attributes
    instance_values
  end

  def eql? other
    self == other
  end
  
  def hash
    attributes.hash
  end

  def == other
    attributes == other.attributes
  end

end

class Color < JSONable
  attr_accessor :hex, :type
  def var
    "#{@type}_#{@hex}"
  end
end

class Font < JSONable
  attr_accessor :name, :size
  def var
    "#{@name.gsub(/[^0-9a-zA-Z]/, "_")}_#{@size}"
  end
end

class Style < JSONable
  attr_accessor :font, :color
  def var
    "#{font.var}_#{@color.hex}"
  end
end

class CGRect
  attr_accessor :x, :y, :width, :height
  def initialize(h)
    @x = h["x"].to_f
    @y = h["y"].to_f
    @width = h["width"].to_f
    @height = h["height"].to_f
  end
  def to_s
    "#{@x}, #{@y}, #{@width}, #{@height}"
  end
  def toCGRect
    "CGRect(x: #{@x}, y: #{@y}, width: #{@width}, height: #{@height})"
  end
  def midX
    @x + @width / 2
  end
  def midY
    @y + @height / 2
  end
  def maxX
    @x + @width
  end
  def maxY
    @y + @height
  end
end

class View
  attr_accessor :frame
  attr_accessor :name, :declaration, :declaration_objc, :initialization_objc
  
  def transform
    "#{@name}.transform = Geometry.referringMatrix"
  end

  def frameString
    "#{@name}.frame = transform(#{@frame.toCGRect}, bounds, Device.referringMatrix, Geometry.referringBounds)"
  end

  def constrains(bounds, i, scale)
    top = @frame.y
    left = @frame.x
    width = @frame.width
    height = @frame.height
    midXOffset = @frame.midX - bounds.midX 
    midYOffset = @frame.midY - bounds.midY
    midX = @frame.midX
    midY = @frame.midY
    
    bottom = bounds.height - @frame.maxY
    right = bounds.width - @frame.maxX
<<M
var c#{i} = DAConstrains()
        c#{i}.top = #{top}
        c#{i}.left = #{left}
        //c#{i}.right = #{right}
        //c#{i}.bottom = #{bottom}
        //c#{i}.midXOffset = #{midXOffset} 
        //c#{i}.midYOffset = #{midYOffset}
        //c#{i}.midX = #{midX}
        //c#{i}.midY = #{midY}
        c#{i}.width = #{width}
        c#{i}.height = #{height}
        c#{i}.updateViewFrameInBoundsRespectingFrameScale(#{@name}, in: bounds, scale: #{scale})
M
  end

  def setup
    "_#{@name}.layer.borderWidth = 1;\n"
  end

  def initialize(h)
    @name = h["name"]
    @declaration = "var #{name} = UIView()"
    @declaration_objc = "@property (nonatomic, strong) UIView *#{name};"
    @initialization_objc = "_#{name} = [UIView new];"
    @frame = CGRect.new(h["frame"])
  end
end




class TextView < View
  attr_accessor :style, :text
  attr_accessor :alignment

  def initialize(h)
    super(h)

    @text = h["text"]

    @alignment = case (h["textAlignment"]) 
      when "0"
        "Left"
      when "1"
        "Right"
      else
        "Center"
    end
    
    if @name.end_with?('Label')
      @declaration = "var #{name} = DALabel()"
      @declaration_objc = "@property (nonatomic, strong) UILabel *#{name};"
      @initialization_objc = "_#{name} = [UILabel new];"
    elsif @name.end_with?('Edit')
      @declaration = "var #{name} = DALabel()"
      @declaration_objc = "@property (nonatomic, strong) UITextField *#{name};"
      @initialization_objc = "_#{name} = [UITextField new];"
    elsif @name.end_with?('Text')
      @declaration = "var #{name} = DALabel()"
      @declaration_objc = "@property (nonatomic, strong) UITextView *#{name};"
      @initialization_objc = "_#{name} = [UITextView new];"
    end
  end

  def setup
<<"M" + "        " + super()
_#{@name}.font = UIFont.#{@style.font.var};
        _#{@name}.textColor = UIColor.#{@style.color.var};
        _#{@name}.textAlignment = NSTextAlignment#{@alignment};
        _#{@name}.text = @"#{@text}";
M
  end
  
end

class Line < View
  attr_accessor :thickness
end

class ImageView < View
  def initialize(h)
    super(h)
    @declaration = "var #{name} = UIImageView()"
    @declaration_objc = "@property (nonatomic, strong) UIImageView *#{name};"
    @initialization_objc = "_#{name} = [UIImageView new];"
  end
  def setup
<<"M" + "        " + super()
_#{@name}.image = [UIImage imageNamed: @"#{@name}"];
M
  end
end

class ButtonView < View
  def initialize(h)
    super(h)
    @declaration = "var #{name} = DALabel()"
    @declaration_objc = "@property (nonatomic, strong) UIButton *#{name};"
    @initialization_objc = "_#{name} = [UIButton new];"
  end
end

result = JSON.parse(File.read("#{$*[1]}/kkk_objc.json"))

components = []
bounds = nil
host = result[0]["name"]

result[0]["sublayers"].each_with_index {|layer, i|
  if i == 0
    bounds = CGRect.new(layer["frame"])
    next
  end
p layer["type"]
  case layer["type"]
  when "line"
    next
  when "text"
    v = TextView.new(layer)
    color = Color.new
    color.hex = layer["color"]["hex"]
    color.type = layer["color"]["type"]

    font = Font.new
    font.name = layer["font"]["name"]
    font.size = layer["font"]["size"]

    style = Style.new
    style.font = font
    style.color = color

    v.style = style
  when "basic"
    if layer["name"].end_with?('Btn')
      v = ButtonView.new(layer)
    elsif layer["name"].end_with?('Icon') || layer["name"].end_with?('ImageView')
      v = ImageView.new(layer)
    else
      v = View.new(layer)
    end
  end
  components << v
}

eh = ERB.new(File.read("./view.h"), nil, '-').result
em = ERB.new(File.read("./view.m"), nil, '-').result

outputDir = "#{$*[1]}/output/"
FileUtils.mkdir_p outputDir
File.open("#{outputDir}/#{host}.h", 'w') {|file|
    file.write eh
}
File.open("#{outputDir}/#{host}.m", 'w') {|file|
    file.write em
}

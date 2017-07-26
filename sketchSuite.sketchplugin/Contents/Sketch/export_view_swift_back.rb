
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
    x + width / 2
  end
  def midY
    y + height / 2
  end
  def maxX
    x + width
  end
  def maxY
    y + height
  end
end

class View
  attr_accessor :frame
  attr_accessor :name, :declaration
  
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
    "#{@name}.layer.borderWidth = 1\n"
  end

  def initialize(h)
    @name = h["name"]
    @declaration = "var #{name} = UIView()"
    @frame = CGRect.new(h["frame"])
  end
end




class TextView < View
  attr_accessor :style
  attr_accessor :alignment

  def initialize(h)
    super(h)
    @alignment = case (h["textAlignment"]) 
      when "0"
        "Left"
      when "1"
        "Right"
      else
        "Center"
    end
    
    if @name.start_with?('label')
      @declaration = "var #{name} = DALabel()"
    elsif @name.start_with?('edit')
      @declaration = "var #{name} = DATextEdit()"
    elsif @name.start_with?('text')
      @declaration = "var #{name} = DATextArea()"
    end
  end

  def setup
<<"M" + "        " + super()
#{@name}.style = Style.#{@style.var}
        #{@name}.textAlignment = NSTextAlignment.#{@alignment}
M
  end
  
end

class Line < View
  attr_accessor :thickness
end


result = JSON.parse(File.read("#{$*[1]}/kkk.json"))

components = []
bounds = nil
host = nil
result.each_with_index {|layer, i|
  if i == 0 
    bounds = CGRect.new(layer["frame"])
    host = layer["name"]
    next
  end

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
    v = View.new(layer)
  end
  components << v
}



e = ERB.new(File.read("./view_#{$*[0]}.swift"), nil, '-').result
outputDir = "#{$*[1]}/output/"
FileUtils.mkdir_p outputDir
File.open("#{outputDir}/#{host}.swift", 'w') {|file|
    file.write e
}

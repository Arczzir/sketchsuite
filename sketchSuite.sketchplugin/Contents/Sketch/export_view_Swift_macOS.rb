
Dir.chdir __dir__

require 'erb'
require 'json'
#require 'active_model'
require 'fileutils'


LLKeys = {}


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
  attr_accessor :name, :declaration, :declaration_objc, :initialization_objc, :ll_key# localizable key
  
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
        c#{i}.updateViewFrame(view: #{@name}, bounds: bounds)
M
  end

  def setup
    "#{@name}.layer.borderWidth = 1\n"
  end

  def initialize(h)
    a = h["name"].split(":")
    @name = a[0]
    @ll_key = a[1]

    LLKeys[@ll_key] = h["text"] ? h["text"] : "" if @ll_key

    @declaration = "var #{name} = UIView()"
    @frame = CGRect.new(h["frame"])
  end
end




class TextView < View
  attr_accessor :style, :text
  attr_accessor :alignment

  def self.init(h)
    if h["type"] == "text"
      return TextView.new(h)
    else
      if h["sublayers"]
        h["sublayers"].each{|x|
          if x["type"] == "text"
            me = View.new(h)
            v = TextView.new(x)
            v.name = me.name
            v.ll_key = me.ll_key
            v.frame = me.frame
            return v
          end
        }
      end
    end
  end

  def initialize(h)
    super(h)
    @text = h["text"]

    @alignment = case (h["textAlignment"]) 
      when "4","0"
        "left"
      when "1"
        "right"
      when "2"
        "center"
      else
        "left"
    end
    

    color = Color.new
    color.hex = h["color"]["hex"]
    color.type = h["color"]["type"]

    font = Font.new
    font.name = h["font"]["name"]
    font.size = h["font"]["size"]

    style = Style.new
    style.font = font
    style.color = color

    @style = style
    
  end

  def declaration
    if @name.end_with?('Label')
      "var #{name} = UILabel()"
    elsif @name.end_with?('Edit')
      "var #{name} = UITextField()"
    elsif @name.end_with?('Text')
      "var #{name} = UITextView()"
    end
  end

  def setup
    p @name
<<"M" + "        " + super()
#{@name}.font = UIFont.#{@style.font.var}
        #{@name}.textColor = UIColor.#{@style.color.var}
        #{@name}.textAlignment = .#{@alignment}
        #{@name}.text = NSLocalizedString("#{@ll_key}", comment: "")
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
  end
  def setup
<<"M" + "        " + super()
#{@name}.image = UIImage(named: "#{@name}")
M
  end
end

class ButtonView < View
  attr_accessor :label
  def initialize(h)
    super(h)
    @declaration = "var #{name} = UIButton()"
    if h["sublayers"]
      h["sublayers"].each{|x|
        if x["type"] == "text"
          @label = TextView.init(x)
          break
        end
      }
    elsif h["type"] == "text"
      @label = TextView.init(h)
    end

  end
  def setup
    return unless @label
<<"M" + "        " + super()
#{@name}.setAttributedTitle(Style.#{@label.style.var}.styled(NSLocalizedString("#{@label.ll_key}", comment: "")), for: UIControlState.normal)
M
  end
end

result = JSON.parse(File.read("#{$*[0]}/kkk.json"))

components = []
bounds = nil
host = result[0]["name"]

result[0]["sublayers"].each_with_index {|layer, i|
  if i == 0
    bounds = CGRect.new(layer["frame"])
    next
  end
 
  case layer["type"]
  when "line"
    next
  else
    name = layer["name"].split(":")[0]
    if name.end_with?('Btn')
      v = ButtonView.new(layer)
    elsif name.end_with?('Icon') || name.end_with?('ImageView')
      v = ImageView.new(layer)
    elsif name.end_with?('Edit') || name.end_with?("Label") || name.end_with?("Text")
      v = TextView.init(layer)
    else
      v = View.new(layer)
    end
  end
  components << v
}

e = ERB.new(File.read("./view_macOS.swift"), nil, '-').result
outputDir = "#{$*[0]}/output/"
FileUtils.mkdir_p outputDir
File.open("#{outputDir}/#{host}.swift", 'w') {|file|
    file.write e
}


File.open("#{outputDir}/#{host}.strings", 'w') {|file|
  LLKeys.each{|k, v|
    file.write "\"#{k}\" = \"#{v.gsub(/\n/,"\\n")}\";\n"
  }
}

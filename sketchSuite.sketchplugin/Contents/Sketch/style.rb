
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

result = JSON.parse(File.read("#{$*[1]}/kk.json"), :external_encoding => 'utf-8')
#print JSON.pretty_generate(result)


colors = []
fonts = []
styles = []

result.each {|layer|
  case layer["type"]
  when "text"
    color = Color.new
    color.hex = layer["color"]["hex"]
    color.type = layer["color"]["type"]
    colors << color unless colors.include?(color)

    font = Font.new
    font.name = layer["font"]["name"]
    font.size = layer["font"]["size"]
    fonts << font unless fonts.include?(font)

    style = Style.new
    style.font = font
    style.color = color
    styles << style unless styles.include?(style)
  when "basic"
    if layer["fill"] 
      color = Color.new
      color.hex = layer["fill"]["hex"]
      color.type = layer["fill"]["type"]
      colors << color unless colors.include?(color)
    end
    if layer["border"] 
      color = Color.new
      color.hex = layer["border"]["hex"]
      color.type = layer["border"]["type"]
      colors << color unless colors.include?(color)
    end
  end
}

fonts = styles.map{|style|style.font}


e = ERB.new(File.read("./style_#{$*[0]}.swift"), nil, '-').result
outputDir = "#{$*[1]}/output/"
FileUtils.mkdir_p outputDir
File.open("#{outputDir}/palette.swift", 'w') {|file|
    file.write e
}


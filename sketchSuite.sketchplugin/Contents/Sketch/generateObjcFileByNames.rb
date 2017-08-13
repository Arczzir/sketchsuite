
Dir.chdir __dir__

require 'erb'
require 'json'
require 'fileutils'

result = JSON.parse(File.read("#{$*[0]}/kkk.json"))

outputDir = "#{$*[0]}/output/"
FileUtils.mkdir_p outputDir

host = ""
result[0]["sublayers"].each {|g|
  g["sublayers"].map {|l| 
    host = l["text"]
    eh = ERB.new(File.read("./obj.h"), nil, '-').result
    em = ERB.new(File.read("./obj.m"), nil, '-').result

    FileUtils.mkdir_p "#{outputDir}/#{g["name"]}"

    File.open("#{outputDir}/#{g["name"]}/#{host}.h", 'w') {|file|
        file.write eh
    }
    File.open("#{outputDir}/#{g["name"]}/#{host}.m", 'w') {|file|
        file.write em
    }
  }


}








names.each {|name|
  h}

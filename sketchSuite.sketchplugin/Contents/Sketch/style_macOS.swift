 
import Cocoa

extension NSColor {
<% max=(colors.map{|x|x.var.length}).max; colors.sort_by{|x|[x.var]}.each_with_index do |color, index|; a=color.hex.split("_") -%>
    class var <%= color.var%>: <%= " "* (max-color.var.length)%>NSColor { return NSColor(rgb: "<%=a[0]%>", alpha: <%= a[1].to_i/100.0%>)! }
<%- end -%>
}

extension NSFont {
<% fonts.uniq!;max=fonts.map{|x| x.var.length}.max;max2=fonts.map{|x|x.name.length}.max;fonts.sort_by{|x|[x.name, x.size.to_i]}.each do |font| -%>
    class var <%= font.var %>: <%= " "*(max-font.var.length)%>NSFont { return NSFont(name: "<%= font.name%>", <%= " "* (max2-font.name.length)%>size: <%= font.size%>)! }
<%- end -%>
}

extension Style {
<% max=styles.map{|x|x.var.length}.max;max2=styles.map{|x|x.font.var.length}.max;styles.each do |style| -%>
    static var <%= style.var %>: <%= " "*(max-style.var.length)%>Style { return Style([.font(.<%= style.font.var %>), <%= " "*(max2-style.font.var.length)%>.color(.<%= style.color.var %>)]) }
<%- end -%>
}

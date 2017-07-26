 

@implementation UIColor(Palette)
<% max=(@colors.map{|x|x.var.length}).max; @colors.sort_by{|x|[x.var]}.each_with_index do |color, index|; a=color.hex.split("_") -%>
+ (UIColor *)<%= color.var%> <%= " "* (max-color.var.length)%>{ return [UIColor hex:0x<%= a[0]%> alpha:<%= a[1].to_i/100.0%>]; }
<%- end -%>
@end


@implementation UIFont(Palette)
<% @fonts.uniq!;max=@fonts.map{|x| x.var.length}.max;max2=@fonts.map{|x|x.name.length}.max;@fonts.sort_by{|x|[x.name, x.size.to_i]}.each do |font| -%>
+ (UIFont *)<%= font.var%> <%= " "* (max-font.var.length)%>{ return [UIFont fontWithName:@"<%= font.name%>" <%= " "* (max2-font.name.length)%>size:<%= font.size%>]; }
<%- end -%>
@end

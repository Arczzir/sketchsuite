
@interface UIColor(Palette)
<% max=(@colors.map{|x|x.var.length}).max; @colors.sort_by{|x|[x.var]}.each_with_index do |color, index|; a=color.hex.split("_") -%>
+ (UIColor *)<%= color.var%>;
<%- end -%>
@end

@interface UIFont(Palette)
<% @fonts.uniq!;max=@fonts.map{|x| x.var.length}.max;max2=@fonts.map{|x|x.name.length}.max;@fonts.sort_by{|x|[x.name, x.size.to_i]}.each do |font| -%>
+ (UIFont *)<%= font.var%>;
<%- end -%>
@end


#import "UIColor+INColor.h"
#import "UIColor+Palette.h"
#import "<%=host%>.h"

@interface <%=host%>()
<%- components.each_with_index do |x, i| -%>
<%= x.declaration_objc%>
<%- end -%>
@end

static CGRect referenceFrame = {<%= bounds.x%>, <%= bounds.y%>, <%= bounds.width%>, <%= bounds.height%>};

@implementation <%=host%>
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        <%- components.each_with_index do |x, i| -%>
        <%= x.initialization_objc%>
        <%= x.setup -%>
        [self addSubview:_<%= x.name%>];
        <%- end -%>
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat frameScale = self.bounds.size.width / referenceFrame.size.width;
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, frameScale, frameScale); 
    
    <%- components.each_with_index do |x, i| -%>
    self.<%= x.name%>.frame = CGRectApplyAffineTransform(CGRectMake(<%= x.frame.x%>, <%= x.frame.y%>, <%= x.frame.width%>, <%= x.frame.height%>), transform);
    <%- end -%>
}

- (void)setFrameSizeByWidthProportionally:(CGFloat)width {
    CGRect r = self.frame;
    r.size.height = referenceFrame.size.height * width / referenceFrame.size.width;
    r.size.width = width;
    self.frame = r;
}
@end


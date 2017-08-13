
import UIKit
import DAFoundation_iOS

fileprivate let referenceFrame = CGRect(x: <%= bounds.x%>, y: <%= bounds.y%>, width: <%= bounds.width%>, height: <%= bounds.height%>)

class <%=host%>: UIView {

    <%- components.each_with_index do |x, i| -%>
    <%= x.declaration%>
    <%- end -%>
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        <%- components.each_with_index do |x, i| -%>
        <%= x.setup%>
        <%- end -%>
        <%- components.each_with_index do |x, i| -%>
        addSubview(<%= x.name%>)
        <%- end -%>
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*override func resizeSubviews(withOldSize oldSize: NSSize)  {*/
        /*var c = DAConstrains()*/
        /*let frameScale = bounds.width / referenceFrame.width*/
        /*<% components.each_with_index do |x, i| %>*/
        /*<%= x.constrains(bounds, i, "frameScale")%>*/
        /*<% end %>*/
    /*}*/

    override func layoutSubviews() {
        let frameScale = self.bounds.size.width / referenceFrame.size.width
        let transform = CGAffineTransform(scaleX: frameScale, y: frameScale)
   
        <%- components.each_with_index do |x, i| -%>
        <%= x.name%>.frame = CGRect(x: <%= x.frame.x%>, y: <%= x.frame.y%>, width: <%= x.frame.width%>, height: <%= x.frame.height%>).applying(transform)
        <%- end -%>
    }

    func setFrameSizeByWidthProportionally(_ width: CGFloat) {
        frame.size.height = referenceFrame.size.height * width / referenceFrame.size.width;
        frame.size.width = width;
    }
}


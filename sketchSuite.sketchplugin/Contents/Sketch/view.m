
import Cocoa
import DAFoundation_macOS

class View1: UIView {

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

    override func resizeSubviews(withOldSize oldSize: NSSize)  {
        var c = DAConstrains()
        <% components.each_with_index do |x, i| %>
        <%= x.constrains(bounds)%>
        <% end %>

    }
}


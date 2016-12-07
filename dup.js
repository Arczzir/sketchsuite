var sketch = context.api()

// n: total items = all copies + origin
// distance: + -: direction
// orientation: vertical = "="; horizontal = "||"
function dup(layer, n, distance, orientation) {
    var r = layer.frame
    for(i=0;i<n-1;i++){
        var l = layer.duplicate()
        var f = l.frame
        if (orientation == "||") {
            f.x += (i+1)*distance
        } else if (orientation == "="){
            f.y += (i+1)*distance
        }
        l.frame = f
    }
}

var document = sketch.selectedDocument;
var selection = document.selectedLayers;
var l = nil


selection.iterate(function(layer){
    l = layer
})

//dup(l, 2, -20, 1)
dup(l, 2, 40, "||")

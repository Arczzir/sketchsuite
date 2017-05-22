# sketchsuite
A sketch plugin provides following features:

![Interface](https://pbs.twimg.com/media/DAaj5zZVYAAswuj.png:small)

#### Analyze all layers' colors and fonts on current page, then generate ```palette.swift``` like this:
```swift
extension UIColor {
    class var border_64B9FF_100: UIColor { return UIColor(rgb: "64B9FF", alpha: 1.0)! }
    class var border_67BCFF_100: UIColor { return UIColor(rgb: "67BCFF", alpha: 1.0)! }
    class var border_979797_100: UIColor { return UIColor(rgb: "979797", alpha: 1.0)! }
    class var border_9E9E9E_100: UIColor { return UIColor(rgb: "9E9E9E", alpha: 1.0)! }
    class var fill_000000_100:   UIColor { return UIColor(rgb: "000000", alpha: 1.0)! }
    class var fill_28B4FA_100:   UIColor { return UIColor(rgb: "28B4FA", alpha: 1.0)! }
    class var fill_5CCCFF_100:   UIColor { return UIColor(rgb: "5CCCFF", alpha: 1.0)! }
    class var fill_64B9FF_100:   UIColor { return UIColor(rgb: "64B9FF", alpha: 1.0)! }
    class var fill_9ED4FF_100:   UIColor { return UIColor(rgb: "9ED4FF", alpha: 1.0)! }
    class var fill_D8D8D8_100:   UIColor { return UIColor(rgb: "D8D8D8", alpha: 1.0)! }
    class var fill_F8F8F8_100:   UIColor { return UIColor(rgb: "F8F8F8", alpha: 1.0)! }
    class var fill_FFB5B5_100:   UIColor { return UIColor(rgb: "FFB5B5", alpha: 1.0)! }
    class var fill_FFFFFF_100:   UIColor { return UIColor(rgb: "FFFFFF", alpha: 1.0)! }
    class var text_64B9FF_100:   UIColor { return UIColor(rgb: "64B9FF", alpha: 1.0)! }
    class var text_9B9B9B_100:   UIColor { return UIColor(rgb: "9B9B9B", alpha: 1.0)! }
    class var text_A6A6A6_100:   UIColor { return UIColor(rgb: "A6A6A6", alpha: 1.0)! }
    class var text_BDBDBD_100:   UIColor { return UIColor(rgb: "BDBDBD", alpha: 1.0)! }
    class var text_C4C4C4_100:   UIColor { return UIColor(rgb: "C4C4C4", alpha: 1.0)! }
    class var text_FF1700_79:    UIColor { return UIColor(rgb: "FF1700", alpha: 0.79)! }
    class var text_FFFFFF_100:   UIColor { return UIColor(rgb: "FFFFFF", alpha: 1.0)! }
}

extension UIFont {
    static var SFUIDisplay_Regular_9:  UIFont { return UIFont(name: "SFUIDisplay-Regular", size: 9)! }
    static var SFUIDisplay_Regular_10: UIFont { return UIFont(name: "SFUIDisplay-Regular", size: 10)! }
    static var SFUIDisplay_Regular_12: UIFont { return UIFont(name: "SFUIDisplay-Regular", size: 12)! }
    static var SFUIDisplay_Regular_14: UIFont { return UIFont(name: "SFUIDisplay-Regular", size: 14)! }
    static var SFUIText_Light_20:      UIFont { return UIFont(name: "SFUIText-Light",      size: 20)! }
    static var SFUIText_Regular_11:    UIFont { return UIFont(name: "SFUIText-Regular",    size: 11)! }
}

extension Style {
    static var SFUIDisplay_Regular_9_FFFFFF_100:  Style { return Style([.font(.SFUIDisplay_Regular_9),  .color(.text_FFFFFF_100)]) }
    static var SFUIDisplay_Regular_10_9B9B9B_100: Style { return Style([.font(.SFUIDisplay_Regular_10), .color(.text_9B9B9B_100)]) }
    static var SFUIDisplay_Regular_14_C4C4C4_100: Style { return Style([.font(.SFUIDisplay_Regular_14), .color(.text_C4C4C4_100)]) }
    static var SFUIDisplay_Regular_12_64B9FF_100: Style { return Style([.font(.SFUIDisplay_Regular_12), .color(.text_64B9FF_100)]) }
    static var SFUIText_Light_20_FF1700_79:       Style { return Style([.font(.SFUIText_Light_20),      .color(.text_FF1700_79)]) }
    static var SFUIText_Regular_11_A6A6A6_100:    Style { return Style([.font(.SFUIText_Regular_11),    .color(.text_A6A6A6_100)]) }
    static var SFUIDisplay_Regular_10_BDBDBD_100: Style { return Style([.font(.SFUIDisplay_Regular_10), .color(.text_BDBDBD_100)]) }
}
```


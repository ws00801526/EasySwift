//  ColorExtension.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)

#if !os(Linux)

#if canImport(UIKit)
import UIKit
/// Color
public typealias Color = UIColor
#endif

#if canImport(Cocoa)
import Cocoa
/// Color
public typealias Color = NSColor
#endif


// MARK: - Properties

public extension Color {
    
    ///  EasySwift:Hexadecimal value string (read-only).
    var hexString: String {
        let components: [Int] = {
            let comps = cgColor.components!
            let components = comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
            return components.map { Int($0 * 255.0) }
        }()
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }
    
    /// EasySwift: Alpha of Color (read-only).
    var alpha: CGFloat {
        return cgColor.alpha
    }
    
    /// EasySwift: Get RGB components of color (between 0 and 255)
    var rgbComponents: (red: Int, green: Int, blue: Int) {
        var components: [CGFloat] {
            let comps = cgColor.components!
            if comps.count == 4 { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        return (red: Int(red * 255.0), green: Int(green * 255.0), blue: Int(blue * 255.0))
    }
    
    /// EasySwift: Get components of hue, saturation, and brightness, and alpha (read-only).
    var hsbaComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// MARK: Methods

public extension Color {
    

    /// EasySwift: Blend two Colors
    ///
    /// - Parameters:
    ///   - color1: first color to blend
    ///   - intensity1: intensity of first color (default is 0.5)
    ///   - color2: second color to blend
    ///   - intensity2: intensity of second color (default is 0.5)
    /// - Returns: Color created by blending first and seond colors.
    static func blend(_ color1: Color, intensity1: CGFloat = 0.5, with color2: Color, intensity2: CGFloat = 0.5) -> Color {
        // http://stackoverflow.com/questions/27342715/blend-uicolors-in-swift
        let total = intensity1 + intensity2
        let level1 = intensity1/total
        let level2 = intensity2/total
        
        guard level1 > 0 else { return color2 }
        guard level2 > 0 else { return color1 }
        
        let components1: [CGFloat] = {
            let comps = color1.cgColor.components!
            return comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
        }()
        
        let components2: [CGFloat] = {
            let comps = color2.cgColor.components!
            return comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
        }()
        
        let red1 = components1[0]
        let red2 = components2[0]
        
        let green1 = components1[1]
        let green2 = components2[1]
        
        let blue1 = components1[2]
        let blue2 = components2[2]
        
        let alpha1 = color1.cgColor.alpha
        let alpha2 = color2.cgColor.alpha
        
        let red = level1*red1 + level2*red2
        let green = level1*green1 + level2*green2
        let blue = level1*blue1 + level2*blue2
        let alpha = level1*alpha1 + level2*alpha2
        
        return Color(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// EasySwift: Lighten a color
    ///
    ///     let color = Color(red: r, green: g, blue: b, alpha: a)
    ///     let lighterColor: Color = color.lighten(by: 0.2)
    ///
    /// - Parameter percentage: Percentage by which to lighten the color
    /// - Returns: A lightened color
    func lighten(by percentage: CGFloat = 0.2) -> Color {
        // https://stackoverflow.com/questions/38435308/swift-get-lighter-and-darker-color-variations-for-a-given-uicolor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: min(red + percentage, 1.0),
                     green: min(green + percentage, 1.0),
                     blue: min(blue + percentage, 1.0),
                     alpha: alpha)
    }
    
    /// EasySwift: Darken a color
    ///
    ///     let color = Color(red: r, green: g, blue: b, alpha: a)
    ///     let darkerColor: Color = color.darken(by: 0.2)
    ///
    /// - Parameter percentage: Percentage by which to darken the color
    /// - Returns: A darkened color
    func darken(by percentage: CGFloat = 0.2) -> Color {
        // https://stackoverflow.com/questions/38435308/swift-get-lighter-and-darker-color-variations-for-a-given-uicolor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: max(red - percentage, 0),
                     green: max(green - percentage, 0),
                     blue: max(blue - percentage, 0),
                     alpha: alpha)
    }
}

// MARK: - Initializers
public extension Color {
    
    
    /// EasySwift: create color from RGB components
    ///
    /// - Parameters:
    ///   - red:     red value of color
    ///   - green: green value of color
    ///   - blue:   blue value of color
    ///   - alpha: alpha value of color. default is 1.0
    ///   - p3:      is preferred using p3 color. default is true
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1, p3: Bool = true) {
        if #available(iOS 10, *), p3 { self.init(displayP3Red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha) }
        else { self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha) }
    }
    
    /// EasySwift: create a random color
    ///
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color
    class func random(_ p3: Bool = true) -> Color {
        let red   = CGFloat(Int.random(in: 0...255))
        let green = CGFloat(Int.random(in: 0...255))
        let blue  = CGFloat(Int.random(in: 0...255))
        return .init(red: red, green: green, blue: blue, alpha: 1.0, p3: p3)
    }
    
    /// EasySwift:create a color from hex value which does not contains alpha value
    ///
    /// - Parameters:
    ///   - hex3:  hex value of color. such as 0x333, 0xfff...
    ///   - alpha: alpha of color. default is 1.0
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color
    class func hex3(_ hex3: UInt16, alpha: CGFloat = 1.0, p3: Bool = true) -> Color {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        return .init(red: red, green: green, blue: blue, alpha: alpha, p3: p3)
    }
    
    /// EasySwift:create a color from hex value
    ///
    /// - Parameters:
    ///   - hex4: hex value of color. such as 0x333F. 0xF12F...
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color
    class func hex4(_ hex4: UInt16, p3: Bool = true) -> Color {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat( hex4 & 0x00F0  >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        return .init(red: red, green: green, blue: blue, alpha: alpha, p3: p3)
    }
    
    
    /// EasySwift:create a color from hex value which does not contains alpha value
    ///
    /// - Parameters:
    ///   - hex6: hex value of color. such as 0xf1f2f3, 0x333333
    ///   - alpha: alpha of color. default is 1.0
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color
    class func hex6(_ hex6: UInt32, alpha: CGFloat = 1.0, p3: Bool = true) -> Color {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        return .init(red: red, green: green, blue: blue, alpha: alpha, p3: p3)
    }
    
    
    /// EasySwift:create a color from hex value
    ///
    /// - Parameters:
    ///   - hex8: hex value of color. such as 0xf1f2f3ff, 0x333333ff
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color
    class func hex8(_ hex8: UInt32, p3: Bool = true) -> Color {
        
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        return .init(red: red, green: green, blue: blue, alpha: alpha, p3: p3)
    }
    
    
    /// EasySwift:create a color from hex string
    ///
    /// - Parameters:
    ///   - hex: hex string of color. such as "0x303", "0xf1f2", "0xff1122", "0x22ff00", "#f23"
    ///   - p3:      is preferred using p3 color. default is true
    /// - Returns: the color if created succeed,  otherwise will be .white color
    class func hex(_ hex: String, p3: Bool = true) -> Color {

        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if str.hasPrefix("#")  { str = str.replacingOccurrences(of: "#", with: "") }
        if str.hasPrefix("0x") { str = str.replacingOccurrences(of: "0x", with: "") }
        guard let rgb = Int(str, radix: 16) else { return .white }
        
        switch str.count {
        case 3: return .hex3(UInt16(rgb), p3: p3)
        case 4: return .hex4(UInt16(rgb), p3: p3)
        case 6: return .hex6(UInt32(rgb), p3: p3)
        case 8: return .hex8(UInt32(rgb), p3: p3)
        default: return .white
        }
    }
}


// MARK: - Social
public extension Color {
    
    /// EasySwift: Brand identity color of popular social media platform.
    struct Social {
        // https://www.lockedowndesign.com/social-media-colors/
        private init() {}
        
        /// red: 59, green: 89, blue: 152
        public static let facebook: Color = Color(red: 59, green: 89, blue: 152)
        
        /// red: 0, green: 182, blue: 241
        public static let twitter = Color(red: 0, green: 182, blue: 241)
        
        /// red: 223, green: 74, blue: 50
        public static let googlePlus = Color(red: 223, green: 74, blue: 50)
        
        /// red: 0, green: 123, blue: 182
        public static let linkedIn = Color(red: 0, green: 123, blue: 182)
        
        /// red: 69, green: 187, blue: 255
        public static let vimeo = Color(red: 69, green: 187, blue: 255)
        
        /// red: 179, green: 18, blue: 23
        public static let youtube = Color(red: 179, green: 18, blue: 23)
        
        /// red: 195, green: 42, blue: 163
        public static let instagram = Color(red: 195, green: 42, blue: 163)
        
        /// red: 203, green: 32, blue: 39
        public static let pinterest = Color(red: 203, green: 32, blue: 39)
        
        /// red: 244, green: 0, blue: 131
        public static let flickr = Color(red: 244, green: 0, blue: 131)
    
        /// red: 67, green: 2, blue: 151
        public static let yahoo = Color(red: 67, green: 2, blue: 151)
        
        /// red: 67, green: 2, blue: 151
        public static let soundCloud = Color(red: 67, green: 2, blue: 151)
        
        /// red: 44, green: 71, blue: 98
        public static let tumblr = Color(red: 44, green: 71, blue: 98)
        
        /// red: 252, green: 69, blue: 117
        public static let foursquare = Color(red: 252, green: 69, blue: 117)
    
        /// red: 255, green: 176, blue: 0
        public static let swarm = Color(red: 255, green: 176, blue: 0)
        
        /// red: 234, green: 76, blue: 137
        public static let dribbble = Color(red: 234, green: 76, blue: 137)
        
        /// red: 255, green: 87, blue: 0
        public static let reddit = Color(red: 255, green: 87, blue: 0)
        
        /// red: 74, green: 93, blue: 78
        public static let devianArt = Color(red: 74, green: 93, blue: 78)
        
        /// red: 238, green: 64, blue: 86
        public static let pocket = Color(red: 238, green: 64, blue: 86)
        
        /// red: 170, green: 34, blue: 182
        public static let quora = Color(red: 170, green: 34, blue: 182)
        
        /// red: 247, green: 146, blue: 30
        public static let slideShare = Color(red: 247, green: 146, blue: 30)
        
        /// red: 0, green: 153, blue: 229
        public static let px500 = Color(red: 0, green: 153, blue: 229)
        
        /// red: 223, green: 109, blue: 70
        public static let listly = Color(red: 223, green: 109, blue: 70)
        
        /// red: 0, green: 180, blue: 137
        public static let vine = Color(red: 0, green: 180, blue: 137)
        
        /// red: 0, green: 175, blue: 240
        public static let skype = Color(red: 0, green: 175, blue: 240)
        
        /// red: 235, green: 73, blue: 36
        public static let stumbleUpon = Color(red: 235, green: 73, blue: 36)
        
        /// red: 255, green: 252, blue: 0
        public static let snapchat = Color(red: 255, green: 252, blue: 0)
        
        /// red: 37, green: 211, blue: 102
        public static let whatsApp = Color(red: 37, green: 211, blue: 102)
    }
    
}

// MARK: - Flat UI colors
public extension Color {
    
    /// EasySwift: Flat UI colors
    struct FlatUI {
        // http://flatuicolors.com.
        /// EasySwift: hex #1ABC9C
        public static let turquoise: Color             = .hex6(0x1abc9c)
        
        /// EasySwift: hex #16A085
        public static let greenSea: Color              = .hex6(0x16a085)
        
        /// EasySwift: hex #2ECC71
        public static let emerald: Color               = .hex6(0x2ecc71)
        
        /// EasySwift: hex #27AE60
        public static let nephritis: Color             = .hex6(0x27ae60)
        
        /// EasySwift: hex #3498DB
        public static let peterRiver: Color            = .hex6(0x3498db)
        
        /// EasySwift: hex #2980B9
        public static let belizeHole: Color            = .hex6(0x2980b9)
        
        /// EasySwift: hex #9B59B6
        public static let amethyst: Color              = .hex6(0x9b59b6)
        
        /// EasySwift: hex #8E44AD
        public static let wisteria: Color              = .hex6(0x8e44ad)
        
        /// EasySwift: hex #34495E
        public static let wetAsphalt: Color            = .hex6(0x34495e)
        
        /// EasySwift: hex #2C3E50
        public static let midnightBlue: Color          = .hex6(0x2c3e50)
        
        /// EasySwift: hex #F1C40F
        public static let sunFlower: Color             = .hex6(0xf1c40f)
        
        /// EasySwift: hex #F39C12
        public static let flatOrange: Color            = .hex6(0xf39c12)
        
        /// EasySwift: hex #E67E22
        public static let carrot: Color                = .hex6(0xe67e22)
        
        /// EasySwift: hex #D35400
        public static let pumkin: Color                = .hex6(0xd35400)
        
        /// EasySwift: hex #E74C3C
        public static let alizarin: Color              = .hex6(0xe74c3c)
        
        /// EasySwift: hex #C0392B
        public static let pomegranate: Color           = .hex6(0xc0392b)
        
        /// EasySwift: hex #ECF0F1
        public static let clouds: Color                = .hex6(0xecf0f1)
        
        /// EasySwift: hex #BDC3C7
        public static let silver: Color                = .hex6(0xbdc3c7)
        
        /// EasySwift: hex #7F8C8D
        public static let asbestos: Color              = .hex6(0x7f8c8d)
        
        /// EasySwift: hex #95A5A6
        public static let concerte: Color              = .hex6(0x95a5a6)
    }
    
}

#endif

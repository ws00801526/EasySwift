//  Auto.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Auto

import UIKit

public struct Auto {
    
    public static func set(_ closure: @escaping ((Double) -> Double)) {
        self.closure = closure
    }
    
    static var closure: ((Double) -> Double) = {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return $0 }
        let base = 375.0
        let width = Double(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
        return ($0 * (width / base)).rounded(places: 3)
    }
    
    static func conversion(_ value: Double) -> Double {
        return closure(value)
    }
}

public protocol AutoCalculator {
    func auto() -> Self
}

extension Double: AutoCalculator {
    public func auto() -> Double { return Auto.conversion(self) }
}

extension BinaryInteger {
    public func auto() -> Double { return (Double("\(self)") ?? 0.0).auto() }
    
    public func auto<T: BinaryInteger>() -> T { return T((Double("\(self)") ?? 0.0).auto()) }
    
    public func auto<T: BinaryFloatingPoint>() -> T { return T((Double("\(self)") ?? 0.0).auto()) }
}

extension BinaryFloatingPoint {
    public func auto() -> Double { return (Double("\(self)") ?? 0.0).auto() }
    
    public func auto<T: BinaryInteger>() -> T { return T((Double("\(self)") ?? 0.0).auto()) }
    
    public func auto<T: BinaryFloatingPoint>() -> T { return T((Double("\(self)") ?? 0.0).auto()) }
}

extension CGPoint: AutoCalculator {
    public func auto() -> CGPoint {
        return CGPoint(x: x.auto(), y: y.auto())
    }
}

extension CGSize: AutoCalculator {
    public func auto() -> CGSize {
        return CGSize(width: width.auto(), height: height.auto())
    }
}

extension CGRect: AutoCalculator {
    public func auto() -> CGRect {
        return CGRect(origin: origin.auto(), size: size.auto())
    }
}

extension CGVector: AutoCalculator {
    
    public func auto() -> CGVector {
        return CGVector(dx: dx.auto(), dy: dy.auto())
    }
}

extension UIOffset: AutoCalculator {
    public func auto() -> UIOffset {
        return UIOffset(horizontal: horizontal.auto(), vertical: vertical.auto())
    }
}

extension UIEdgeInsets: AutoCalculator {
    public func auto() -> UIEdgeInsets {
        return UIEdgeInsets(top: top.auto(), left: left.auto(), bottom: bottom.auto(), right: right.auto())
    }
}

extension NSLayoutConstraint {
    
    @IBInspectable private var autoConstant: Bool {
        set {
            guard newValue else { return }
            constant = constant.auto()
        }
        get { return false }
    }
}


extension UILabel {
    
    @IBInspectable private var autoFont: Bool {
        set {
            guard newValue else { return }
            let font = (self.font ?? UIFont.systemFont(ofSize: 17.0))
            self.font = UIFont(name: font.fontName, size: font.pointSize.auto())
        }
        get { return false }
    }
}

extension UITextField {
    @IBInspectable private var autoFont: Bool {
        set {
            guard newValue else { return }
            let font = (self.font ?? UIFont.systemFont(ofSize: 12.0))
            self.font = UIFont(name: font.fontName, size: font.pointSize.auto())
        }
        get { return false }
    }
}

extension UITextView {
    @IBInspectable private var autoFont: Bool {
        set {
            guard newValue else { return }
            let font = (self.font ?? UIFont.systemFont(ofSize: 17.0))
            self.font = UIFont(name: font.fontName, size: font.pointSize.auto())
        }
        get { return false }
    }
}

fileprivate extension Double {
    
    func rounded(places: Int) -> Double {
        let divisor = pow(10, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

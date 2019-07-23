//  Phone.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/1
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Phone

import UIKit

public enum Phone: Int {
    
    public static let current: Phone = get()
    
    public static func get(of size: CGSize = UIScreen.main.bounds.size, scale: CGFloat = UIScreen.main.scale) -> Phone {
        
        let width = min(size.width, size.height) * scale
        let height = max(size.width, size.height) * scale
        let size = CGSize(width: width, height: height)
        
        switch size {
        case Phone.i35.native:     return .i35
        case Phone.i40.native:     return .i40
        case Phone.i47.native:     return .i47
        case Phone.i55.native:     return .i55
        case Phone.i58Full.native: return .i58Full
        case Phone.i61Full.native: return .i61Full
        case Phone.i65Full.native: return .i65Full
        default:                   return .unknown
        }
    }
    
    
    public var width: CGFloat {
        switch self {
        case .unknown:  return 0.0
            
        case .i35:      return 320.0
        case .i40:      return 320.0
        case .i47:      return 375.0
        case .i55:      return 414.0
            
        case .i58Full:  return 375.0
        case .i61Full:  return 414.0
        case .i65Full:  return 414.0
        }
    }
    
    public var height: CGFloat {
        switch self {
        case .unknown:  return 0.0
            
        case .i35:      return 480.0
        case .i40:      return 568.0
        case .i47:      return 667.0
        case .i55:      return 736.0
            
        case .i58Full:  return 812.0
        case .i61Full:  return 896.0
        case .i65Full:  return 896.0
        }
    }
    
    public var scale: CGFloat {
        switch self {
        case .unknown:  return 0.0
            
        case .i35:      return 2.0
        case .i40:      return 2.0
        case .i47:      return 2.0
        case .i55:      return 3.0
            
        case .i58Full:  return 3.0
        case .i61Full:  return 2.0
        case .i65Full:  return 3.0
        }
    }
    
    public var size: CGSize { return CGSize(width: width, height: height) }
    
    public var native: CGSize { return CGSize(width: width * scale, height: height * scale) }

    public var isXMode: Bool {
        // using Range to compare, should conforms Comparable Protocol
//        if Phone.i58Full...Phone.i65Full ~= self { return true }
        // using Array to compare
        if [.i58Full, .i61Full, .i65Full].contains(self) { return true }
        return false
    }
    
    public var isPlusMode: Bool {
        if case .i55 = self { return true }
        return false
    }
    
    case unknown = -1
    case i35
    case i40
    case i47
    case i55
    case i58Full
    case i61Full
    case i65Full
}

public protocol PhoneVariable {
    func i35(_ value: Self) -> Self
    func i40(_ value: Self) -> Self
    func i47(_ value: Self) -> Self
    func i55(_ value: Self) -> Self
    
    func ifull(_ value: Self) -> Self
    func i58full(_ value: Self) -> Self
    func i61full(_ value: Self) -> Self
    func i65full(_ value: Self) -> Self
    
    func w320(_ value: Self) -> Self
    func w375(_ value: Self) -> Self
    func w414(_ value: Self) -> Self
}

extension PhoneVariable {
    
    public func i35(_ value: Self) -> Self { return matching(phone: .i35, value) }
    public func i40(_ value: Self) -> Self { return matching(phone: .i40, value) }
    public func i47(_ value: Self) -> Self { return matching(phone: .i47, value) }
    public func i55(_ value: Self) -> Self { return matching(phone: .i55, value) }
    
    
    public func ifull(_ value: Self) -> Self { return matching(phones: [.i58Full, .i61Full, .i65Full], value) }
    public func i58full(_ value: Self) -> Self { return matching(phone: .i58Full, value) }
    public func i61full(_ value: Self) -> Self { return matching(phone: .i61Full, value) }
    public func i65full(_ value: Self) -> Self { return matching(phone: .i65Full, value) }

    public func w320(_ value: Self) -> Self { return matching(width: 320.0, value) }
    public func w375(_ value: Self) -> Self { return matching(width: 375.0, value) }
    public func w414(_ value: Self) -> Self { return matching(width: 414.0, value) }
    
    private func matching(phone: Phone, _ value: Self) -> Self { return phone == .current ? value : self }
    private func matching(width: CGFloat, _ value: Self) -> Self { return Phone.current.width == width ? value : self }
    private func matching(phones: [Phone], _ value: Self) -> Self { return phones.contains(.current) ? value : self }
}


extension Int: PhoneVariable {}
extension Bool: PhoneVariable {}
extension Float: PhoneVariable {}
extension Double: PhoneVariable {}
extension String: PhoneVariable {}

extension CGRect: PhoneVariable {}
extension CGSize: PhoneVariable {}
extension CGFloat: PhoneVariable {}
extension CGPoint: PhoneVariable {}

extension UIFont: PhoneVariable {}
extension UIImage: PhoneVariable {}
extension UIColor: PhoneVariable {}
extension UIOffset: PhoneVariable {}
extension UIEdgeInsets: PhoneVariable {}

//  Storyboard.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/1
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Storyboard

import UIKit



///  A simple way to get view controller from storyboard
///
/// you can using in next ways, such as extension
///
///      extension Storybord {
///        public static var another: Storybord { return "Another" }
///      }
///
/// or using it with a Enum:
///
///      enum StoryboardCase<T: UIViewController>: String, StoryboardLoader  {
///         typealias ViewController = T
///         case main
///         case another = "another storyboard'name"
///
///         public var bundle: Bundle? { return nil }
///      }
public protocol StoryboardLoader: RawRepresentable {
    associatedtype ViewController
    
    var bundle: Bundle? { get }
    var value: ViewController? { get }
}

extension StoryboardLoader where Self.ViewController : UIViewController, Self.RawValue == String {
    
    public var value: ViewController? {
        
        let storyboard = UIStoryboard(name: rawValue, bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: ViewController.identifier)
        if let controller = controller as? ViewController { return controller }
        assertionFailure("cannot load view controller:\(ViewController.identifier) from storyboard:\(rawValue) ")
        return nil
    }
}

public struct Storybord<T: UIViewController>: StoryboardLoader {
    public typealias ViewController = T
    
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var bundle: Bundle? { return nil }
    
    public static var main: Storybord<T> { return "Main" }
}

extension Storybord: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: Storybord.RawValue) {
        rawValue = value
    }
    
    public init(unicodeScalarLiteral value: Storybord.RawValue) {
        rawValue = value
    }
    
    public init(extendedGraphemeClusterLiteral value: Storybord.RawValue) {
        rawValue = value
    }
}

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
///      extension Storyboard {
///        public static var another: Storyboard { return "Another" }
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

        let identifier = String(describing: ViewController.self)
        let storyboard = UIStoryboard(name: rawValue, bundle: bundle)
        if let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? ViewController { return controller }
        assertionFailure("Couldn't find ViewController:\(identifier) from storyboard:\(rawValue) ")
        return nil
    }
}

public struct Storyboard<T: UIViewController>: StoryboardLoader {
    public typealias ViewController = T

    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var bundle: Bundle? { return nil }

    public static var main: Storyboard<T> {
        let name = (Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String) ?? "Main"
        return Storyboard(rawValue: name)
    }
}

extension Storyboard: ExpressibleByStringLiteral {

    public init(stringLiteral value: Storyboard.RawValue) { rawValue = value }

    public init(unicodeScalarLiteral value: Storyboard.RawValue) { rawValue = value }

    public init(extendedGraphemeClusterLiteral value: Storyboard.RawValue) { rawValue = value }
}

//  Identifiable.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/1
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Identifiable

import UIKit

public protocol Identifiable {
    associatedtype ID
    static var identifier: Self.ID { get }
}

extension Identifiable {
    
    public static var identifier: String { return "\(self)" }
}

extension UITableViewCell: Identifiable {}

extension UICollectionViewCell: Identifiable {}

extension UIViewController: Identifiable {}

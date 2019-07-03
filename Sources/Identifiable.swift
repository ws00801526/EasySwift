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

public extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>(with clazz: T.Type) -> T? {
        guard let controller = instantiateViewController(withIdentifier: clazz.identifier) as? T else { return nil }
        return controller
    }
}

public extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(with clazz: T.Type) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: clazz.identifier) as? T else { return nil }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with clazz: T.Type, for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: clazz.identifier, for: indexPath) as? T else { return nil }
        return cell
    }
}

public extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(with clazz: T.Type, for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withReuseIdentifier: clazz.identifier, for: indexPath) as? T else { return nil }
        return cell
    }
}

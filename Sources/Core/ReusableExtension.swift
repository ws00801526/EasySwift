//  ReusableExtension.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/1
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)

import UIKit

public extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>(with clazz: T.Type) -> T? {
        guard let controller = instantiateViewController(withIdentifier: String(describing: clazz)) as? T else { return nil }
        return controller
    }
}

public extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(withClass clazz: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: clazz)) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: clazz))), make sure the cell is registered with table view")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass clazz: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: clazz), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: clazz))), make sure the cell is registered with table view")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass clazz: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: String(describing: clazz)) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(String(describing: clazz))), make sure the view is registered with table view")
        }
        return view
    }
    
    func register<T: UITableViewCell>(cellWithClass clazz: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: clazz))
    }

    func register<T: UITableViewHeaderFooterView>(headerFooterViewWithClass clazz: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: clazz))
    }
    
    func register<T: UITableViewHeaderFooterView>(nib: UINib?, withClass clazz: T.Type) {
        register(nib, forHeaderFooterViewReuseIdentifier: String(describing: clazz))
    }

    func register<T: UITableViewCell>(nib: UINib?, withClass clazz: T.Type) {
        register(nib, forCellReuseIdentifier: String(describing: clazz))
    }
}

public extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass clazz: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: clazz), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: clazz))), make sure the cell is registered with collection view")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, withClass clazz: T.Type, for indexPath: IndexPath) -> T {
        
        guard let view = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: String(describing: clazz), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(String(describing: clazz))), make sure the view is registered with collection view")
        }
        return view;
    }
    
    func register<T: UICollectionViewCell>(cellWithClass clazz: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing:clazz))
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewOfKind elementKind: String, withClass clazz: T.Type) {
        register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: String(describing:clazz))
    }
    
    func register<T: UICollectionViewCell>(nib: UINib?, forCellWithClass clazz: T.Type) {
        register(nib, forCellWithReuseIdentifier: String(describing: clazz))
    }

    func register<T: UICollectionReusableView>(nib: UINib?, forSupplementaryViewOfKind elementKind: String, withClass clazz: T.Type) {
        register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: String(describing: clazz))
    }
}

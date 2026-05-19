//
//  EXTableview+Register.swift
//  Chainup
//
//  Created by liuxuan on 2020/8/3.
//  Copyright © 2020 ChainUP. All rights reserved.
//

import Foundation

public protocol EXReusableView: class {}

public extension EXReusableView where Self:UIView {
    static var reuseIdentifier:String {
        return String.init(describing: self)
    }
}

public extension UITableView {
    func register<T: UITableViewCell & EXReusableView >(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell & EXReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}

public extension UICollectionView {
    func register<T: UICollectionViewCell & EXReusableView>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell & EXReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}

//
//  UIStackViewExtension.swift
//  Chainup
//
//  Created by youbin on 2021/6/9.
//  Copyright © 2021 Chainup. All rights reserved.
//

import UIKit

public extension UIStackView {
    
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views{
            addArrangedSubview(view)
        }
    }
    
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
}

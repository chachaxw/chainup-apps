//
//  EXKitLayouts.swift
//  EXKit-EXKit
//
//  Created by liuxuan on 2022/7/27.
//


import UIKit
import Blueprints

public class EXKitLayouts: NSObject {
    
    public class func homeMenuVerticalLayouts() -> VerticalBlueprintLayout {
        let homeVertical = VerticalBlueprintLayout(
          itemsPerRow: 5.0,
          height: 58,
          minimumInteritemSpacing: 0,
          minimumLineSpacing: 8,
          sectionInset: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
          stickyHeaders: true,
          stickyFooters: false
        )
        return homeVertical
    }
    
    public class func contractMenuVerticalLayouts() -> VerticalBlueprintLayout {
        let homeVertical = VerticalBlueprintLayout(
          itemsPerRow: 4.0,
          height: 50,
          minimumInteritemSpacing: 0,
          minimumLineSpacing: 20,
          sectionInset: EdgeInsets(top: 20, left: 16, bottom: 20, right: 16),
          stickyHeaders: true,
          stickyFooters: false
        )
        homeVertical.footerReferenceSize = CGSize(width:Device_W, height: 52)
        return homeVertical
    }
}

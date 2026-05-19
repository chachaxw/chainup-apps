//
//  LookinConfig.swift
//  EXLookin
//
//  Created by zq on 2023/2/14.
//

import EXKit

public let LookIn2D     = Notification.Name("Lookin_2D")
public let LookIn3D     = Notification.Name("Lookin_3D")
public let LookInExport = Notification.Name("Lookin_Export")

private extension NSObject {
    @objc class func lookin_colorAlias() -> [String:Any] { UIColor.Ex.LookinColorAlias }
}


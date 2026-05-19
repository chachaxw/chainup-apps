//
//  EXViewStateProtocol.swift
//  EXKit
//
//  Created by zq on 2023/4/3.
//

import UIKit

// MARK: EXViewStateConstant
private struct EXViewStateConstant {}


// MARK: EXHighlightable
public protocol EXHighlightable {
    var isHighlighted: Bool { get set }
    var highlightableUpdater:EXViewStateUpdater? { get set }
}

private extension EXViewStateConstant {
    struct highlightable {
        static var state:UInt8 = 0
        static var updater:UInt8 = 0
    }
}
public extension EXHighlightable where Self:UIView {
    var isHighlighted: Bool {
        get { (objc_getAssociatedObject(self, &EXViewStateConstant.highlightable.state) as? Bool) ?? false }
        set {
            objc_setAssociatedObject(self, &EXViewStateConstant.highlightable.state, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateHighlightedStyle()
        }
    }
    var highlightableUpdater:EXViewStateUpdater? {
        get { objc_getAssociatedObject(self, &EXViewStateConstant.highlightable.updater) as? EXViewStateUpdater }
        set {
            objc_setAssociatedObject(self, &EXViewStateConstant.highlightable.updater, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateHighlightedStyle()
        }
    }
    func updateHighlightedStyle() {
        highlightableUpdater?.invokeWith(target:self, state: isHighlighted)
    }
}


// MARK: EXSelectable
public protocol EXSelectable {
    var isSelected: Bool { get set }
    var selectableUpdater:EXViewStateUpdater? { get set }
}

private extension EXViewStateConstant {
    struct selectable {
        static var state:UInt8 = 0
        static var updater:UInt8 = 0
    }
}

public extension EXSelectable where Self:UIView {
    var isSelected: Bool {
        get { (objc_getAssociatedObject(self, &EXViewStateConstant.selectable.state) as? Bool) ?? false }
        set {
            objc_setAssociatedObject(self, &EXViewStateConstant.selectable.state, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateSelectedStyle()
        }
    }
    var selectableUpdater:EXViewStateUpdater? {
        get { objc_getAssociatedObject(self, &EXViewStateConstant.selectable.updater) as? EXViewStateUpdater }
        set {
            objc_setAssociatedObject(self, &EXViewStateConstant.selectable.updater, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateSelectedStyle()
        }
    }
    func updateSelectedStyle() {
        selectableUpdater?.invokeWith(target:self, state: isSelected)
    }
}

// MARK: EXViewStateUpdater
public class EXViewStateUpdater: NSObject {
    private var dynamicUpdater:((Bool) -> Void?)? = nil
    private var dynamicItems:[EXViewStateConfigurationItem] = []
    public required init(dynamicUpdater: @escaping (Bool) -> Void) {
        self.dynamicUpdater = dynamicUpdater
        super.init()
    }
    public required init(dynamicItems:[EXViewStateConfigurationItem]) {
        self.dynamicItems = dynamicItems
        super.init()
    }
    public func invokeWith(target:NSObject? = nil, state:Bool){
        dynamicItems.forEach { $0.invoke(with: target, state:state) }
        dynamicUpdater?(state)
    }
    public static var `default`: EXViewStateUpdater {
        EXViewStateUpdater(dynamicItems: EXViewStateConfigurationItem.default)
    }
}

// MARK: EXViewStateConfigurationItem
public class EXViewStateConfigurationItem: NSObject {
    internal weak var target:NSObject?
    internal let keypath:String
    internal let dynamicProvider:((Bool) -> Any?)
    public required init(target:NSObject? = nil, keypath: String, dynamicProvider: @escaping (Bool) -> Any?) {
        self.target = target
        self.keypath = keypath
        self.dynamicProvider = dynamicProvider
        super.init()
    }
    
    public convenience init(target:NSObject? = nil, keypath: String, off:Any? = nil, on: Any?) {
        self.init(target:target,keypath: keypath, dynamicProvider: { $0 ? on : off })
    }
    public class func backgroundColor(off:Any? = nil, on: Any?) -> EXViewStateConfigurationItem {
        return EXViewStateConfigurationItem(keypath:#keyPath(UIView.backgroundColor), off: off, on: on)
    }
    public class func borderColor(off:CGColor? = nil, on: CGColor? = UIColor.Ex.main1.cgColor) -> EXViewStateConfigurationItem {
        return EXViewStateConfigurationItem(keypath:#keyPath(UIView.layer.borderColor), off: off, on: on)
    }
    public class func borderWidth(off:Any? = 0, on: Any? = EX_Pixel_One) -> EXViewStateConfigurationItem {
        return EXViewStateConfigurationItem(keypath:#keyPath(UIView.layer.borderWidth), off: off, on: on)
    }
    public static let `default`:[EXViewStateConfigurationItem] = [
        .borderWidth(),
        .borderColor(),
    ]
    public func invoke(with target:NSObject? = nil, state:Bool) {
        (self.target ?? target)?.setValue(dynamicProvider(state), forKeyPath: keypath)
    }
}

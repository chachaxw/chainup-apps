//
//  EXGradientView.swift
//  EXKit
//
//  Created by zq on 2023/3/22.
//

import UIKit
@IBDesignable public class EXGradientView: UIView {
    ///
    public override class var layerClass: AnyClass { CAGradientLayer.self }
    ///
    public var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    // MARK: - Properties of CAGradientLayer
    ///
    @IBInspectable public dynamic var colors: [UIColor]? {
        set {
            gradientLayer.colors = newValue?.compactMap({ $0.cgColor })
        }
        get {
            guard let colors = gradientLayer.colors as? [CGColor] else { return nil }
            return colors.compactMap({ UIColor(cgColor: $0) })
        }
    }
    ///
    @IBInspectable public dynamic var locations: [NSNumber]? {
        set { gradientLayer.locations = newValue }
        get { gradientLayer.locations }
    }
    ///
    @IBInspectable public dynamic var startPoint: CGPoint {
        set { gradientLayer.startPoint = newValue }
        get { gradientLayer.startPoint }
    }
    ///
    @IBInspectable public dynamic var endPoint: CGPoint {
        set { gradientLayer.endPoint = newValue }
        get { gradientLayer.endPoint }
    }
    ///
    @IBInspectable public dynamic var type: CAGradientLayerType {
        set { gradientLayer.type = newValue }
        get { gradientLayer.type }
    }
    
    ///
    public func snapshotColor(afterScreenUpdates: Bool = true) -> UIColor? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return UIColor(patternImage: image)
    }
    
}


extension EXGradientView : EXSwiftLoadProtocol {
    public static func swiftLoad() {
        let appearance = Self.appearance()
        appearance.type = .axial
        appearance.startPoint = .zero
        appearance.endPoint = CGPoint(x: 1, y: 1)
        appearance.colors = UIColor.Ex.defaultColors
    }
}

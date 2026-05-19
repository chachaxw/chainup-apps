//
//  EXThemeImage.swift
//  EXUIKit
//
//  Created by zq on 2023/2/2.
//

import Foundation

public extension UIImage {
    ///
    struct Ex {
        @available(*, unavailable) init() {}
        public static func removeAllImageCache() {
            UTI.removeAllImageCache()
        }
        ///
        public static func named(_ name: String,
                                 color:UIColor.Ex.Color = .global,
                                 bundle:Bundle? = nil,
                                 options:[UIImage.Ex.Key:Any?]? = nil) -> UIImage? {
            let types:UTI = (options?[.uti] as? UTI) ?? .any
            let UTIs = UTI.allCases.filter({ types.contains($0) })
            for uti in UTIs {
                if let image = uti.named(name, color: color, bundle: bundle ?? .main, options: options) { return image }
            }
            return nil
        }
        ///
        public static func svg(named name:String,
                               color:UIColor.Ex.Color = .global,
                               bundle:Bundle? = nil,
                               options:[UIImage.Ex.Key:Any?]? = nil) -> UIImage? {
            var svg_options = options ?? [:]
            if svg_options[.uti] == nil {
                svg_options[.uti] = UIImage.Ex.UTI.svg
            }
            return named(name, color: color, bundle: bundle, options: svg_options)
        }
    }
}

extension EXBundle {
    public class func image(named name:String, color:UIColor.Ex.Color = .global,options:[UIImage.Ex.Key:Any?]? = nil) -> UIImage? {
        return UIImage.Ex.named(name, color: color.resolved, bundle: resource, options: options)
    }
    public class func svgImage(named name:String, color:UIColor.Ex.Color = .global,options:[UIImage.Ex.Key:Any?]? = nil) -> UIImage? {
        return UIImage.Ex.svg(named: name, color: color, bundle: resource, options: options)
    }
}

public extension UIImage.Ex {
    ///
    struct Key : Hashable, Equatable, RawRepresentable {
        public typealias RawValue = String
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let uti:Key = .init(rawValue: "uti")//类型
        public static let size:Key = .init(rawValue: "size")
        public static let scale:Key = .init(rawValue: "scale")
        public static let insets:Key = .init(rawValue: "insets")
    }
    /// UniformTypeIdentifiers
    struct UTI : OptionSet, CaseIterable {
        public typealias RawValue = UInt
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        /// system, e.g. UniformTypeIdentifiers.UTType.png、UTType.jpeg .../
        public static let system:UTI = UTI(rawValue: 1 << 1)
        /// UTType.svg
        public static let svg:UTI = UTI(rawValue: 1 << 0)
        /// any matched
        public static let any:UTI = [.svg, .system]
        ///
        public static var allCases: [UIImage.Ex.UTI] = [.system, .svg]
        ///
        private func cacheable(bundle:Bundle) -> Bool { self != .system || bundle != .main }
        ///
        private var coder: ExImageCoder.Type? {
            switch self {
                case .svg: return SVG.self
                case .system: return System.self
                default: return nil
            }
        }
        private static let cache: NSCache<NSString, UIImage> = NSCache()
        ///
        func named(_ name: String, color:UIColor.Ex.Color, bundle:Bundle, options:[UIImage.Ex.Key:Any?]?) -> UIImage? {
            if let image = cachedImage(for: name, color, bundle) { return image }
            var image:UIImage? = coder?.named(name, color: color, bundle: bundle, options: options)
            if image == nil, bundle != .main {
                image = coder?.named(name, color: color, bundle: .main, options: options)
            }
            cacheIfNeeded(image: image, name: name, color: color, bundle: bundle)
            return image
        }
        ///
        private func cacheKey(for name:String, _ color:UIColor.Ex.Color, _ bundle:Bundle) -> NSString {
            return "\(self)_\(name)_\(color)_\(bundle.bundlePath)" as NSString
        }
        ///
        private func cachedImage(for name:String, _ color:UIColor.Ex.Color, _ bundle:Bundle) -> UIImage? {
            Self.cache.object(forKey: cacheKey(for: name, color, bundle))
        }
        ///
        private func cacheIfNeeded(image:UIImage?, name:String, color:UIColor.Ex.Color, bundle:Bundle) {
            guard let image = image, cacheable(bundle: bundle) else { return }
            Self.cache.setObject(image, forKey: cacheKey(for: name, color, bundle))
        }
        ///
        fileprivate static func removeAllImageCache() {
            cache.removeAllObjects()
        }
    }
}

private protocol ExImageCoder {
    static func named(_ name: String, color:UIColor.Ex.Color, bundle:Bundle, options:[UIImage.Ex.Key:Any?]?) -> UIImage?
}

import SwiftDraw
private extension UIImage.Ex {
    struct SVG : ExImageCoder {
        private static let primary_builtin:String = "2B61FF"
        private static let primary_current:String? = UIColor.Ex.main1.rgbString
        /// get
        static func named(_ name: String, color: UIColor.Ex.Color, bundle: Bundle, options:[UIImage.Ex.Key:Any?]?) -> UIImage? {
            guard let svg = svg(named: name, color: color, bundle: bundle) else { return nil }
            ///
            let size = options?[.size] as? CGSize
            let scale = (options?[.scale] as? CGFloat) ?? UIScreen.main.scale
            let insets = (options?[.insets] as? UIEdgeInsets) ?? .zero
            let image = svg.rasterize(with: size, scale: scale, insets: insets)
            return image
        }
        /// Get svg object with specified info
        private static func svg(named name: String, color: UIColor.Ex.Color, bundle: Bundle) -> SwiftDraw.SVG? {
            ///
            guard let data = data(named: name, color: color, bundle: bundle) else {
                return nil
            }
            guard var string = String(data: data, encoding: .utf8) else { return nil }
            /// update built-in color with current primary color
            if let primary_current = primary_current, primary_current != primary_builtin {
                string = string.replacingOccurrences(of: "\"#\(primary_builtin)\"", with: "\"#\(primary_current)\"")
            }
            ///
            guard let data = string.data(using: .utf8) else { return nil }
            return SwiftDraw.SVG(data: data)
        }
        private static func data(named name: String, color: UIColor.Ex.Color, bundle: Bundle) -> Data? {
            ///
            if name.isEmpty { return nil }
            ///
            let imageName = name + color.resourceSuffix
            ///
            if let url = bundle.url(forResource: imageName, withExtension: "svg"), let data = try? Data(contentsOf: url) {
                return data
            }
            if let url = bundle.url(forResource: name, withExtension: "svg"), let data = try? Data(contentsOf: url) {
                return data
            }
            return nil
        }
    }
}

private extension UIImage.Ex {
    struct System : ExImageCoder {
        static func named(_ name: String, color: UIColor.Ex.Color, bundle: Bundle, options:[UIImage.Ex.Key:Any?]?) -> UIImage? {
            ///
            if name.isEmpty { return nil }
            ///
            let imageName = name + color.resourceSuffix
            ///
            if bundle == .main {
                return UIImage(named: imageName) ?? UIImage(named: name)
            }else {
                var image:UIImage? = UIImage(named: imageName, in: bundle, compatibleWith: nil)
                if image == nil {
                    image = UIImage(named: name, in: bundle, compatibleWith: nil)
                }
                return image
            }
        }
    }
}

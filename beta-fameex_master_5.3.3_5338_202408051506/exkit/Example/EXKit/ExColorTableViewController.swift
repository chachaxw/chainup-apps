//
//  EXColorTableViewController.swift
//  EXKit_Example
//
//  Created by zq on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit

class EXColorTableViewController: UITableViewController {
    var dataSource:[[EXColorPairs]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .Ex.fill2
        tableView.estimatedRowHeight = 70
        tableView.sectionHeaderHeight = 44
        ///
        var colors:[UIColor.Ex.Color:[String:EXColorDescriptor]] = [.light:[:], .dark:[:]]
        var indexes:[String:Int] = [:]
        ///
        UIColor.Ex.Color.allCases.forEach { mode in
            if let path = EXThemeBundle.path(forResource: mode.example_fileName, ofType: "json", inDirectory: "Color"),
               let data = NSData(contentsOfFile: path),
               let configuartion = try? JSONDecoder().decode([EXColorDescriptor].self, from: data as Data) {
                var map:[String:EXColorDescriptor] = [:]
                for (index,descriptor) in configuartion.enumerated() {
                    map[descriptor.name] = descriptor
                    indexes[descriptor.name] = index
                }
                /// 处理老版色值名称重定向到新的色值对
                configuartion.forEach { descriptor in
                    if let redirect = descriptor.redirect, let redirection = map[redirect] {
                        descriptor.redirection = redirection
                        redirection.redirects.append(descriptor.name)
                    }
                }
                colors[mode] = map
            }
        }
        var pairs:[EXColorPairs] = []
        colors[.light]?.forEach({ (name: String, value: EXColorDescriptor) in
            pairs.append(EXColorPairs(name: name, light: value, dark: colors[.dark]![name]!))
        })
        pairs.sort(by: { indexes[$0.name]! < indexes[$1.name]! })
        var new:[EXColorPairs] = []
        var old:[EXColorPairs] = []
        pairs.forEach { pair in
            if pair.name.contains(".") {
                old.append(pair)
            }else{
                new.append(pair)
            }
        }
        dataSource = [new,old]
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " Light   -   Dark       " + (section == 0 ? "(New)" : "(Old)")
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            //
            cell!.selectionStyle = .none
            cell!.backgroundColor = .Ex.fill2
            cell!.textLabel?.numberOfLines = 0
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            cell!.detailTextLabel?.font = .Ex.regular(14)
            cell!.detailTextLabel?.textColor = .Ex.rise2
        }
        let pairs = dataSource[indexPath.section][indexPath.row]
        //
        cell!.imageView?.image = pairs.image
        cell!.textLabel?.attributedText = pairs.text
        cell!.detailTextLabel?.text = pairs.detailText
        return cell!
    }
}














class EXColorPairs:Codable {
    let name:String
    let light:EXColorDescriptor
    let dark:EXColorDescriptor
    lazy var image = UIGraphicsImageRenderer(size: CGSize(width: 50 * 2 + 10, height: 50), format: {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        return format
    }()).image { [weak self] context in
        guard let `self` = self else { return }
        self.light.image.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.dark.image.draw(in: CGRect(x: 60, y: 0, width: 50, height: 50))
    }
    lazy var redirects: String? = {
        guard light.redirects == dark.redirects else {
            fatalError()
        }
        if light.redirects.count > 0 {
            return light.redirects.joined(separator: "、")
        }
        return nil
    }()
    lazy var text: NSAttributedString = {
        let attributedText = name.ex_toNSAttributedString(font: .Ex.medium(14), textColor: .Ex.text1)
        if let redirects = redirects {
            attributedText.append("\n")
                .append(redirects, font: .Ex.regular(10), textColor: .Ex.text2)
        }
        attributedText
            .append("\n")
            .append({
                if let light = light.colorValue ?? light.colorsValue?.joined(separator: "-"),
                   let dark  = dark.colorValue  ?? dark.colorsValue?.joined(separator: "-") {
                    return [light,dark].joined(separator: " ⎟ ")
                }
                return ""
            }(), font: .Ex.medium(10), textColor: .Ex.text1)
            .ex_lineSpacing(4)
        return attributedText
    }()
    lazy var detailText:String? = light.redirect
    //
    init(name: String, light: EXColorDescriptor, dark: EXColorDescriptor) {
        self.name = name
        self.light = light
        self.dark = dark
    }
}


extension UIColor.Ex.Color {
    var example_fileName:String {
        switch self {
            case .light: return "EXThemeColorLight"
            case .dark : return "EXThemeColorDark"
            case .unspecified: return resolved.example_fileName
        }
    }
}

final class EXColorDescriptor : Codable {
    
    lazy var image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50), format: {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        return format
    }()).image { [weak self] context in
        guard let `self` = self else { return }
        let obj = self.redirection ?? self
        let rect = CGRect(x:0, y: 0, width:50, height: 50)
        let cgContext = context.cgContext
        if let color = obj.color {
            cgContext.setFillColor(color.cgColor)
            cgContext.fill([rect])
        }else if let colors = obj.colors {
            let view = EXGradientView(frame: rect)
            view.colors = colors
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        cgContext.setStrokeColor(UIColor.Ex.main1.cgColor)
        cgContext.stroke(rect, width: EX_Pixel_One)
    }
    
    let category: String?
    let name: String
    let redirect: String?
    let desc: String?
    let colorValue: String?
    let colorsValue: [String]?
    let alphaValue: String?
    let version: String?
    var redirects:[String] = []
    ///
    weak var redirection:EXColorDescriptor?
    ///
    enum CodingKeys:String,CodingKey {
        case category
        case name
        case redirect
        case colorValue  = "color"
        case colorsValue = "colors"
        case alphaValue  = "alpha"
        case desc
        case version
    }
    ///
    lazy var alpha: CGFloat? = {
        guard let string = alphaValue, let alpha = Double(string), (0...1.0).contains(alpha) else { return nil }
        return CGFloat(alpha)
    }()
    lazy var color: UIColor? = { Self.color(with: colorValue, alpha: alpha) }()
    lazy var colors: [UIColor]? = { colorsValue?.compactMap({ Self.color(with:$0) }) }()
    ///
    static func color(with value:String?, alpha:CGFloat? = nil) -> UIColor? {
        guard let value = value else { return nil }
        var string = value.components(separatedBy: .whitespacesAndNewlines).joined()
        if string.hasPrefix("#") { string.removeFirst() }
        if string.hasPrefix("0X") || string.hasPrefix("0x") { string.removeFirst(2) }
        if !string.isEmpty {
            string = string.uppercased()
            if string.count == 6 { string = "FF" + string }
            var color:UIColor?
            if string.count == 8, let value = Int(string,radix: 16) {
                let alpha = 0xFF & value >> 24
                let red = 0xFF & value >> 16
                let green = 0xFF & value >> 8
                let blue = 0xFF & value
                color = UIColor(red   : CGFloat(red)   / 255.0,
                                green : CGFloat(green) / 255.0,
                                blue  : CGFloat(blue)  / 255.0,
                                alpha : CGFloat(alpha) / 255.0)
            }
            if let alpha = alpha {
                color = color?.withAlphaComponent(alpha)
            }
            return color
        }
        return nil
    }
}

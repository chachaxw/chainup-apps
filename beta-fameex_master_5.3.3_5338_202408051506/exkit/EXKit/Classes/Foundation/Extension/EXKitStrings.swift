//
//  StringExtensions.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/7.
//

import Foundation
import YYText
//string -> float ,string -> double
//string -> cgsize
//string -> cgsize
//changes????
public extension String {
    
    /**
     specalSubStr : 需要特殊处理的字符
     specailAttri : 特殊字符的样式
     commonAttri  : 全局字符的样式
     
     let attributes: [NSAttributedString.Key: Any] = [
     .font: UIFont.ThemeFont.BodyRegular,
     .foregroundColor: UIColor.exs_ThemeLabel.colorMedium,
     ]
     */
    func attributeString(specalSubStr:String,specailAttri:[NSAttributedString.Key: Any], commonAttri:[NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString.init(string: self, attributes: commonAttri)
        if specalSubStr.count > 0{
            let total = NSString(string: self)
            let rangle = total.range(of: specalSubStr)
            attr.addAttributes(specailAttri, range: rangle)
        }
        return attr
    }
    
    func util_subString(end: Int) -> String{
        if !(end <= count) { return self }
        let sInde = index(startIndex, offsetBy: end)
        return String(self[..<sInde])
    }
    
    func util_characterAtIndex(index:Int) -> Character
    {
        let ch = self[self.index(self.startIndex, offsetBy: index)]
        return ch
    }
    
    // Allows us to use String[index] notation
    subscript(index:Int) -> Character
    {
        return util_characterAtIndex(index: index)
    }
    
    
    func stringToFloat() -> (CGFloat) {
        let string = self
        var cgFloat:CGFloat = 0
        if let doubleValue = Double(string){
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    
    
    //这个计算比较准确
    func textHeightForLabel(font: UIFont, width: CGFloat, numberOfLines: Int = 0,lineHeight: CGFloat = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = self
        label.sizeToFit()
        return label.frame.height
    }
    
    func attributedText(withText text: String, font: UIFont, textColor: UIColor = UIColor.Ex.text1,lineSpacing: CGFloat = 0,lineHeight: CGFloat = 0, calculateHeight: Bool = false, isNeedOffset: Bool = false) -> NSAttributedString{
        
        let breakMode: NSLineBreakMode = calculateHeight ? .byWordWrapping : .byTruncatingTail
        if lineSpacing > 0 {
            let attributedText = NSAttributedString(string: text, attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: textColor,
                    NSAttributedString.Key.paragraphStyle: {
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = lineSpacing
                        paragraphStyle.lineBreakMode = breakMode
                        return paragraphStyle
                    }()
                ])
            return attributedText
        }
        if lineHeight > 0 {
            var baselineOffset:CGFloat = 0
            if isNeedOffset {
                baselineOffset = (lineHeight - font.lineHeight) * 0.3
            }
            let attributedText = NSAttributedString(string: text, attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.baselineOffset: baselineOffset,
                    NSAttributedString.Key.paragraphStyle: {
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.minimumLineHeight = lineHeight
                        paragraphStyle.maximumLineHeight = lineHeight
                        paragraphStyle.lineBreakMode = breakMode
                        return paragraphStyle
                    }()
                ])
            return attributedText
        }
        return NSAttributedString(string: "")
    }
    func getLabelHeight(withText text: String, font: UIFont, width: CGFloat, numberOfLines: Int = 0, lineSpacing: CGFloat = 0, lineHeight: CGFloat = 0) -> CGFloat {
        let attributedText = self.attributedText(withText: text, font: font, lineSpacing: lineSpacing,lineHeight: lineHeight,calculateHeight: true)

        let labelSize = attributedText.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                       context: nil).size
       
        var height = labelSize.height
        if numberOfLines > 0 && lineHeight > 0 {
            var maxH = lineHeight * CGFloat(numberOfLines) //4行的高度
            if height > maxH{
                height = maxH
            }
        }
        return height
        
    }
    //判断字符高度，需传入字符大小和宽度
    //返回的是宽度和高度
    func textSizeWithFont(_ font: UIFont, width:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {
        
        var textSize:CGSize!
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        if size.equalTo(CGSize.zero) {
            
            let attributes = [NSAttributedString.Key.font:font]
            
            textSize = self.size(withAttributes: attributes)
            
        } else {
            
            let attributes = [NSAttributedString.Key.font:font]
            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            textSize = stringRect.size
            textSize.width += 1
        }
        return textSize
    }
    
    func textHeightSizeWithFont(_ font: UIFont, height:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {
        
        var textSize:CGSize!
        
        let size = CGSize(width: 10000, height: height)
        
        if size.equalTo(CGSize.zero) {
            
            let attributes = [NSAttributedString.Key.font:font]
            
            textSize = self.size(withAttributes: attributes)
            
        } else {
            
            let attributes = [NSAttributedString.Key.font:font]
            
            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            
            textSize = stringRect.size
        }
        return textSize
    }
    
    
    
    /**
     string字符串截取
     */
    func extStringSub(_ range : NSRange)->String{
        
        let beforeStr = NSString.init(string: self)
        
        let afterStr = beforeStr.substring(with: range)
        
        return afterStr as String
    }
    
    
    /// 字符串截取(可数的闭区间)例子：
    /// let str = "hello word"
    /// let tmpStr = hp[0 ... 5] tmpStr = hello
    /// - Parameter r: 字符串范围
    subscript (r: CountableClosedRange<Int>) -> String{
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            var endIndex:String.Index?
            if r.upperBound > self.count{
                endIndex = self.index(self.startIndex, offsetBy: self.count)
            }else{
                endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            }
            return String(self[startIndex..<endIndex!])
        }
    }
    
    
    /// 字符串截取(可数的开区间)例子：
    /// let str = "hello word"
    /// let tmpStr = hp[0 ..< 5] tmpStr = hello
    /// - Parameter r: 字符串范围
    subscript (r: CountableRange<Int>) -> String{
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            var endIndex:String.Index?
            if r.upperBound > self.count{
                endIndex = self.index(self.startIndex, offsetBy: self.count)
            }else{
                endIndex = self.index(self.startIndex, offsetBy: r.upperBound-1)
            }
            return String(self[startIndex..<endIndex!])
        }
    }
    
    
    //覆盖
    mutating func coverStringWithString(_ str : String ,startIndex : Int = 0 , endindex : Int){
        if self.count > endindex && startIndex < endindex{
            let index = endindex - startIndex
            var tmpstr = ""
            for _ in 0..<index{
                tmpstr = tmpstr + str
            }
            if let range = Range.init(NSRange.init(location: startIndex, length: index), in: self){
                self.replaceSubrange(range, with: tmpstr)
            }
        }else if self.count > startIndex && startIndex < endindex{
            let index = self.count - startIndex
            var tmpstr = ""
            for _ in 0..<index{
                tmpstr = tmpstr + str
            }
            if let range = Range.init(NSRange.init(location: startIndex, length: index), in: self){
                self.replaceSubrange(range, with: tmpstr)
            }
        }
    }
    
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
}



//MARK: regular Expression
public extension String {
    
    /**
     判断字符串是否为纯数字
     
     - returns: value
     */
    func isNumber() -> Bool{
        if self.count == 0{
            return false
        }else{
            let reg = "[0-9]*"
            let predicate = NSPredicate.init(format: "SELF MATCHES %@", reg)
            let result = predicate.evaluate(with: self)
            return result
        }
    }
    
    //判断是否符合交易密码规则，数字+字母，大于等于8位小于等于20
    func isValidTransactionpPwd() -> Bool {
        let r = "^(?=.*\\d)(?=.*[a-zA-Z]).{8,20}$"
//        let old = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$"
        return isValidRegex(regex: r)
    }
    
    //判断是否符合输入金额、币种数量规则。decimal==0只能输入整数。其余，按decimal规则输入。
    //不能连续输入00，开头不能输入小数点，小数点也只能输入1个
    func isValidInputAmount(decimal:Int = 18) -> Bool {
        if decimal == 0 {
            //只能输入整数
            return isValidRegex(regex: "^\\+?[1-9][0-9]*$")
        }else {
            //通用输入，默认小数点后可输入18位
            let regex = "^[0][0-9]+$"
            let regexDot = "^[.]+$"
            let predicate0 = NSPredicate(format: "SELF MATCHES %@", regex)
            let predicateDot = NSPredicate(format: "SELF MATCHES %@", regexDot)
            
            let isZeroPrefix = predicate0.evaluate(with: self)
            let isDotPrefix = predicateDot.evaluate(with: self)
            
            if  isZeroPrefix || isDotPrefix {
                return false
            }
            
            return isValidRegex(regex: "^([0-9]*)?([\\,\\.])?([0-9]{0,\(decimal)})?$")
        }
    }
    
    /// 邀请奖励链接格式化(前12位,后8位,中间替换为...)
    /// - Returns: 格式化后的字符串(例如:1234567890ABHHHHHHH12345678 ---> 1234567890AB...12345678)
    func inviteUrlStringFormat() -> String {
        if self.isEmpty {
            return self
        }
        if self.trimmingCharacters(in: .whitespacesAndNewlines).count <= 20 {
            return self
        }
        if let regex = try? NSRegularExpression(pattern: #"^(.{12}).*(.{8})$"#, options: []) {
            if let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) {
                let prefixRange = Range(match.range(at: 1), in: self)!
                let suffixRange = Range(match.range(at: 2), in: self)!
                let prefix = self[prefixRange]
                let suffix = self[suffixRange]
                return "\(prefix)...\(suffix)"
            }
        }
        return self
    }
    
    private func isValidRegex(regex: String) -> Bool {
        let regex = regex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let valid = predicate.evaluate(with: self)
        return valid
    }
    
    static func placeholderAttributeString(placeholder:String,fontSize:Int = 12,color:UIColor = UIColor.ThemeLabel.colorLite) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString.init(string: placeholder,
                                                              attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                                                                          NSAttributedString.Key.foregroundColor: color])
        return attributedString
    }
}

//MARK: caculate
public extension String {
    
    func StringToFloat()->(CGFloat){
        let string = self
        var cgFloat:CGFloat = 0
        if let doubleValue = Double(string){
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    
    func greaterThanOrEqualto(_ a:String) ->Bool  {
        return (self as NSString).isBig(a) || (self as NSString).isEqualValue(a)
    }
    
    func lessThanOrEqualto(_ a:String) ->Bool  {
        return (self as NSString).isSmall(a) || (self as NSString).isEqualValue(a)
    }
    
    func isEquals(_ a:String) -> Bool {
        return (self as NSString).isEqualValue(a)
    }
    
    func isSmallerThan(_ a:String) -> Bool {
        return (self as NSString).isSmall(a)
    }
    
    func isBiggerThan(_ a:String) -> Bool {
        return (self as NSString).isBig(a)
    }
    
    func stringByAding(sub:String,decimal:Int) -> String {
        return (self as NSString).adding(sub, decimals: decimal)
    }
    
    func stringBySubtracting(sub:String,decimal:Int,roundDown:Bool = true) -> String {
        if roundDown {
            return (self as NSString).subtractingRoundDown(sub, decimals: decimal)
        }else {
            return (self as NSString).subtracting(sub, decimals: decimal)
        }
    }
    
    func stringByDividing(divide:String,decimal:Int,roundDown:Bool = false) -> String {
        if roundDown {
            return (self as NSString).dividingRoundDown(by: divide, decimals: decimal)
        }else {
            return (self as NSString).dividing(by: divide, decimals: decimal)
        }
    }
    
    func decimalString(value:Int,alwaysRounding:Bool = false,holdZero:Bool = true) -> String {
        if alwaysRounding {
            return (self as NSString).decimalStringAlwaysRounding(value, holdsZero: holdZero)
        }else {
            if holdZero {
                return (self as NSString).decimalString1(value)
            }else {
                return (self as NSString).decimalString(value)
            }
        }
    }
    
    //roundplain 四舍五入
    func stringByMultiplying(multiple:String,decimal:Int,holdZero:Bool = false,useRoundPlain:Bool = false) -> String {
        if useRoundPlain {
            return (self as NSString).multiplyingBy1(multiple, decimals: decimal, holdZero: holdZero)
        }else {
            return (self as NSString).multiplying(by: multiple, decimals: decimal,holdZeor: holdZero)
        }
    }
    
    func removeTrailingZeros() -> String {
        
        if self.contains(".") == false{
            return self
        }
        var result = self
        while result.hasSuffix("0") {
            result = String(result.dropLast())
        }
        if result.hasSuffix(".") {
            result = String(result.dropLast())
        }
        return result
    }
    func formatAmountUseDecimal(_ decimal:String, holdZero:Bool = true) -> String {
        
        if self.isEmpty {
            return ""
        }
        
        if self == "--" {
            return self
        }
        
        if decimal.isEmpty {
            return self
        }
        
        guard let numberDecimal = Int(decimal) else {return self}
        let nsAmount = self as NSString
        if holdZero {
            let rst = nsAmount.decimalString1(numberDecimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }else {
            let rst = nsAmount.decimalString(numberDecimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }
    }
    /*
     rownDown 向下取整
     */
    func newNumberFormat(_ decimal:Int, rownDown: Bool = true, holdZero:Bool = true) -> String {
        if self.isEmpty {
            return ""
        }
        let rst = self.newDecimalString(decimal,rownDown: rownDown,holdZero: holdZero)
        return rst
    }
    
    func newDecimalString(_ decimal:Int, rownDown: Bool = true, holdZero:Bool = true) -> String {
            
        let num_1 = NSDecimalNumber(string: "0")
        let num_2 = NSDecimalNumber(string: self)
        
        var mode: NSDecimalNumber.RoundingMode = .down //不进位直接舍弃
        if rownDown == false {
            mode = .up
        }
        if self.hasPrefix("-"){ //负数需要特殊处理
            mode = .up
            if rownDown == false {
                mode = .down
            }
        }
        
        let handel = NSDecimalNumberHandler(roundingMode: mode, scale: Int16(decimal), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false);
        let num_3 = num_1.adding(num_2, withBehavior: handel)
        var rid = num_3.stringValue
        if holdZero == false {
            return rid
        }
        if (decimal > 0){
            var murid = rid;
            if (!murid.contains(".")){
                murid = murid.appending(".");
            }
            let arr = murid.components(separatedBy: ".");
            if (arr.count > 1){
                let count = decimal - arr[1].count
                if (count > 0){
                    for _ in 0..<count{
                        murid = murid.appending("0");
                    }
                }else{
                    let c = arr[0].count + decimal + 1;
                    murid = (murid as NSString).substring(to: c)
                }
            }
            rid = murid;
        }
        return rid;
    }
}


//MARK: app相关

public extension String {
    
    func decimalNumberWithDouble() -> String{
        if let conversionValue = Double(self){
            let decimalNumberWithDouble = String(conversionValue)
            let decNumber = NSDecimalNumber.init(string: decimalNumberWithDouble as String)
            return "\(decNumber)"
        }
        return self
    }
    
    
    func fmtTimeStr(_ fmt:String = "yyyy-MM-dd HH:mm:ss") -> String {
        var time = TimeInterval.init(0)
        if self.count >= 13{
            if let t = TimeInterval.init(self.prefix(10)){
                time = t
            }
        }else{
            if let t = TimeInterval.init(self){
                time = t
            }
        }
        return DateTools.dateToString(time ,dateFormat:fmt)
    }
    

    func copyToPasteBoard() {
        UIPasteboard.general.string = self
    }
    
    static func privacyString() -> String{
        return "*****"
    }
    
    //小额限制，展示最小btc的资产配置
    static func limitSatoshi() -> String {
        return "0.0001"
    }
    
    func md5PngFileName() ->String {
        return AppService.md5(self) + "@2x"
    }
    
    func isChinese() -> Bool{
        let match: String = "(^[\\u4e00-\\u9fa5]+$)"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: self)
    }
    
    func isEmail() -> Bool {
        return isValidRegex(regex: "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+")
    }
    func isPhone() -> Bool {
        return isValidRegex(regex: "^[0-9]{5,11}$")
    }
    func isChinaPhone() -> Bool {
        return isValidRegex(regex: "^1[0-9]{10}$")
    }
    
    func getValueColor() ->UIColor {
        if self.isBiggerThan("0") {
            return UIColor.ThemekLine.up
        }else if self.isEquals("0") {
            return .Ex.text2
        }else {
            return UIColor.ThemekLine.down
        }
    }
    
    func plusSymbolStr() ->String {
        if self.isBiggerThan("0") {
            return "+" + self
        }else {
            return self
        }
    }
    
    func desensitizedPhone() -> String {
        if count < 4 {
            return self
        }else if count < 11 {
            return "**" + self[index(startIndex, offsetBy: 4)..<endIndex]
        }else{
            return self[startIndex..<index(startIndex, offsetBy: 3)] + "****" + self[index(endIndex, offsetBy: -4)..<endIndex]
        }
    }
    
    func desensitizedMail() -> String {
        if count < 4 {
            return self
        }
        let index = firstIndex(of: "@")
        guard let index = firstIndex(of: "@"), index > startIndex else {
            return self
        }
        //
        let array = self.components(separatedBy: "@")
        let username = self[startIndex..<index]
        let domain = self[index..<endIndex]
        if username.count <= 3 {
            return String(username[username.startIndex]) + "***" + domain
        }else{
            return String(username[username.startIndex..<username.index(username.startIndex, offsetBy: 3)]) + "***" + domain
        }
    }
    
    
    static func makeTipsAttributedString(content: String,
                                         actionContent: String,
                                         action: @escaping (() -> ())) -> NSMutableAttributedString {
        let accatt = NSMutableAttributedString.init().add(string: content, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.Ex.text1 , NSAttributedString.Key.font : UIFont.Ex.regular(12)]).add(string: actionContent, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.Ex.main4 , NSAttributedString.Key.font : UIFont.Ex.medium(12)])
        accatt.highLightTap((accatt.string as NSString).range(of: actionContent), { (view, attstr, range, rect) in
            action()
        })
        return accatt
    }
    
    //带下滑线的
    static func actionTipsAttributedString(content: String,
                                         actionContent: String) -> NSMutableAttributedString {
        
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .left
        paraph.lineSpacing = 6
        let comAttr:  [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle:paraph,
                                                        NSAttributedString.Key.foregroundColor : UIColor.Ex.text2,
                       NSAttributedString.Key.font: UIFont.Ex.regular(14)]
       
        let specAttr:  [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorHighlight,
                        NSAttributedString.Key.font : UIFont.Ex.regular(14),
                        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        
        
        let total = content + actionContent
        let result = total.attributeString(specalSubStr: actionContent, specailAttri: specAttr, commonAttri: comAttr)
        return result
    }
    
    func lineSpacingString(font: UIFont, color: UIColor, lineSpacing: CGFloat, textAligment: NSTextAlignment = NSTextAlignment.center) -> NSAttributedString {
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = textAligment
        paraph.lineSpacing = lineSpacing
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.paragraphStyle: paraph]
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    static func getCoinMapAttr(_ name:String ,
                         leftColor:UIColor = UIColor.ThemeLabel.colorLite,
                               leftFont: UIFont = UIFont.ThemeFont.HeadRegular,
                         rightColor:UIColor = UIColor.ThemeLabel.colorMedium,
                         rightFont:UIFont = UIFont.ThemeFont.SecondaryRegular) -> NSMutableAttributedString
     {
         let array = name.components(separatedBy: "/")
         if array.count >= 2{
             return self.getCoinMapWith(array[0], leftColor: leftColor, leftFont: leftFont, rightStr: array[1], rightColor: rightColor, rightFont: rightFont)
         }else{
             return self.getCoinMapWith(name, leftColor: leftColor, leftFont: leftFont, rightStr: "", rightColor: rightColor, rightFont: rightFont)
         }
     }
    static func getSwapCoinMapAttr(_ name:String ,
                         leftColor:UIColor = UIColor.ThemeLabel.colorLite,
                               leftFont: UIFont = UIFont.ThemeFont.HeadRegular,
                         rightColor:UIColor = UIColor.ThemeLabel.colorMedium,
                         rightFont:UIFont = UIFont.ThemeFont.SecondaryRegular) -> NSMutableAttributedString
     {
         
         var array = name.components(separatedBy: "-")
         if array.count >= 2{
             let right = array.last!
             var left = array[0]
             if array.count > 2 {
                 array.removeLast()
                 left = array.joined(separator: "-")
             }
             return self.getCoinMapWith(left, leftColor: leftColor, leftFont: leftFont, rightStr: right, rightColor: rightColor, rightFont: rightFont,joinStr: "-")
         }else{
             return self.getCoinMapWith(name, leftColor: leftColor, leftFont: leftFont, rightStr: "", rightColor: rightColor, rightFont: rightFont,joinStr: "-")
         }
     }
     static func getCoinMapWith(_ leftStr : String ,
                         leftColor : UIColor = UIColor.ThemeLabel.colorLite,
                         leftFont : UIFont = UIFont.ThemeFont.HeadBold,
                         rightStr : String , rightColor : UIColor = UIColor.ThemeLabel.colorMedium,
                         rightFont : UIFont = UIFont.ThemeFont.SecondaryRegular,
                                joinStr: String? = "/"
     ) -> NSMutableAttributedString{
         var att = NSMutableAttributedString().add(string: leftStr, attrDic: [NSAttributedString.Key.foregroundColor : leftColor,NSAttributedString.Key.font : leftFont])
         if rightStr != ""{
             att = att.add(string: "\(joinStr!)\(rightStr)", attrDic: [NSAttributedString.Key.foregroundColor : rightColor,NSAttributedString.Key.font : rightFont])
         }
         return att
     }
    
}

//MARK: RANGE
public extension String {
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    func ranges(of searchString: String,
                options mask: NSString.CompareOptions = [],
                locale: Locale? = nil) -> [Range<String.Index>]
    {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString, options: mask, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    func nsRanges(of searchString: String,
                  options mask: NSString.CompareOptions = [],
                  locale: Locale? = nil) -> [NSRange]
    {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
}

//MARK: handle Domains
public extension String {
    
    func hostStr() -> String {
        if let url = URL.init(string: self),let host = url.host {
            var paths = host.components(separatedBy: ".")
            if paths.count == 3 {
                paths.remove(at: 0)
            }
            let domain = paths.joined(separator: ".")
            return domain
        }
        return self
    }
    
    func fullDomain() -> String {
        if let url = URL.init(string: self),let host = url.host {
            return host
        }
        return self
    }
    
    //从ip链接取appapi000xxxx还是从正常连接取appapi000xxx
    func hostCompany(_ fromIpAddress:Bool = false) -> String {
        if let url = URL.init(string: self),let host = url.host {
            if fromIpAddress {
                var path = url.path
                if path.hasPrefix("/") {
                    path.removeFirst()
                }
                let paths = path.components(separatedBy: "/")
                if paths.count > 0 {
                    return paths[0]
                }
            }else {
                let paths = host.components(separatedBy: ".")
                if paths.count > 0 {
                    return paths[0]
                }
            }
        }
        return self
    }
}


public extension NSMutableAttributedString{
    
    func highLightTap(_ range : NSRange , _ tapAction : @escaping ((UIView, NSAttributedString, NSRange, CGRect) -> ())){
        let highLightOfReplyUser = YYTextHighlight()
        highLightOfReplyUser.tapAction = tapAction
        self.yy_setTextHighlight(highLightOfReplyUser, range:range)
    }
    
    func add(attString : NSAttributedString) -> NSMutableAttributedString{
        self.append(attString)
        return self
    }
    
    func add(string : String, attrDic : [NSAttributedString.Key : Any])-> NSMutableAttributedString{
        self.append(NSAttributedString.init(string: string, attributes: attrDic))
        return self
    }
    
    func appendAttributedString(_  att : NSAttributedString) -> NSMutableAttributedString{
        self.append(att)
        return self
    }
}
public extension String {
    
    var urlStr: String{
        var charSet = CharacterSet.urlQueryAllowed
        charSet.insert(charactersIn: "#")
        let encodingURL = self.addingPercentEncoding(withAllowedCharacters: charSet )
        return encodingURL ?? ""
    }
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
     *去掉首尾空格 后 指定开头空格数
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }
}

public extension String {
    func getHeightlineH(width: CGFloat, font: CGFloat, lineH: CGFloat) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //样式属性集合
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: font),
                          NSAttributedString.Key.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
         return rect.size.height + 1
     }
    func getHeightline(width: CGFloat, font: CGFloat, lineH: CGFloat) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //样式属性集合
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: font),
                          NSAttributedString.Key.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
         return rect.size.height + 1
     }
    func getTextWidth(width: CGFloat = Device_W, font: CGFloat, lineH: CGFloat = 0) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //样式属性集合
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: font),
                          NSAttributedString.Key.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.width
     }
    
    
    func getTextWidth(width: CGFloat = Device_W, font: UIFont, lineH: CGFloat = 0) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //样式属性集合
        let attributes = [NSAttributedString.Key.font:font,
                          NSAttributedString.Key.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.width
     }
}

public extension String {
    func replaceString() -> String{
        return self.newReplaceString()
   }

    func isZero() -> Bool {

        let d = NSDecimalNumber.init(string: self);
        if ( d.compare(NSDecimalNumber.zero).rawValue == 0) {
            return true;
        }
        return false;
    }
    func lessThan(_ right:String) -> Bool {
        if let l = Double(self),let r = Double(right){
            if l < r {
                return true
            }
        }

        let leftM = NSDecimalNumber(string: self) ;
        let rightM = NSDecimalNumber(string: right);
        if ( leftM.compare(rightM).rawValue < 0) {
            return true;
        }
        return false;
    }
    func lessThanOrEqual(_ right:String) -> Bool {
        if let l = Double(self),let r = Double(right){
            if l <= r {
                return true
            }
        }
        let leftM = NSDecimalNumber(string: self) ;
        let rightM = NSDecimalNumber(string: right);
        if ( leftM.compare(rightM).rawValue <= 0) {
            return true;
        }
        return false;
    }
    func greaterThan(_ right:String) -> Bool {
        if let l = Double(self),let r = Double(right){
            if l > r {
                return true
            }
        }

        let leftM = NSDecimalNumber(string: self) ;
        let rightM = NSDecimalNumber(string: right);
        if ( leftM.compare(rightM).rawValue > 0) {
            return true;
        }
        return false;
    }

    func greaterThanOrEqual(_ right:String) -> Bool {

        if let l = Double(self),let r = Double(right){
            if l >= r {
                return true
            }
        }
        let leftM = NSDecimalNumber(string: self) ;
        let rightM = NSDecimalNumber(string: right);
        if ( leftM.compare(rightM).rawValue >= 0) {
            return true;
        }
        return false;
    }
}

public extension String {
    ///科学计数器问题处理    2.5 * e -4   -> 0.00025
     func newString() -> String {
        return bigAdd("0")
    }
    func toPercentString(_ pointCount:Int,isCalculated:Bool = false) -> String {

        if (self.isEmpty) {
            return "0.00%";
        }
        if (Double(self) == 0) {
            return "0.00%";
        }
        var format = "";
        if (pointCount < 0) {
            format = "%f%%%%";
        }else{
            format = String(format: "%%.%df",pointCount+1);
        }
        if let num = Double(self) {
            var res = String(format: format, num * 100)
            if isCalculated {
                res = String(format: format, num)
            }
            res = String(format: "%@%%", (res as NSString).substring(to: res.count - 1));
            return res;
        }
        return self
    }
    /*字符串保留几位*/
    func toString(_ pointCount:Int, holdZero:Bool = false) -> String {
        let leftM = NSDecimalNumber(string: self)
        let newStr = leftM.stringValue
        return newStr.exs_decimalString1(pointCount,holdZero:holdZero)
    }

    /*字符串保留几位*/
    func decimalString() -> String {
        let leftM = NSDecimalNumber(string: self)
        let newStr = leftM.stringValue
        return newStr
    }
}
public extension String {

    func exs_decimalNumberWithDouble() -> String{
        if let conversionValue = Double(self){
            let decimalNumberWithDouble = String(conversionValue)
            let decNumber = NSDecimalNumber.init(string: decimalNumberWithDouble as String)
            return "\(decNumber)"
        }
        return self
    }
    //判断字符高度，需传入字符大小和宽度
    //返回的是宽度和高度
    func ext_textSizeWithFont(_ font: UIFont, width:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {

        var textSize:CGSize!

        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

        if size.equalTo(CGSize.zero) {

            let attributes = [NSAttributedString.Key.font:font]

            textSize = self.size(withAttributes: attributes)

        } else {

            let attributes = [NSAttributedString.Key.font:font]

            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)

            textSize = stringRect.size
        }
        return textSize
    }

    func exs_textHeightSizeWithFont(_ font: UIFont, height:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {

        var textSize:CGSize!

        let size = CGSize(width: 10000, height: height)

        if size.equalTo(CGSize.zero) {

            let attributes = [NSAttributedString.Key.font:font]

            textSize = self.size(withAttributes: attributes)

        } else {

            let attributes = [NSAttributedString.Key.font:font]

            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)

            textSize = stringRect.size
        }
        return textSize
    }
    func ext_stringSub(_ range : NSRange)->String{

        let beforeStr = NSString.init(string: self)

        let afterStr = beforeStr.substring(with: range)

        return afterStr as String
    }
}
public extension NSMutableAttributedString{

    func exs_add(string : String, attrDic : [NSAttributedString.Key : Any])-> NSMutableAttributedString{
        self.append(NSAttributedString.init(string: string, attributes: attrDic))
        return self
    }

}
public extension String {
    func exs_lineSpacingString(font: UIFont, color: UIColor, lineSpacing: CGFloat, textAligment: NSTextAlignment = NSTextAlignment.center) -> NSAttributedString {
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = textAligment
        paraph.lineSpacing = lineSpacing
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.paragraphStyle: paraph]
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    
    //数字每隔三位添加一个逗号 千分位逗号分隔符
    func showInComma(gap: Int=3, seperator: Character=",") -> String {
        var temp = self
        /* 获取目标字符串的长度 */
        let count = temp.count
        /* 计算需要插入的【分割符】数 */
        let sepNum = count / gap
        /* 若计算得出的【分割符】数小于1，则无需插入 */
        guard sepNum >= 1 else {
            return temp
        }
        /* 插入【分割符】 */
        for i in 1...sepNum {
            /* 计算【分割符】插入的位置 */
            let index = count - gap * i
            /* 若计算得出的【分隔符】的位置等于0，则说明目标字符串的长度为【分割位】的整数倍，如将【123456】分割成【123,456】，此时如果再插入【分割符】，则会变成【,123,456】 */
            guard index != 0 else {
                break
            }
            /* 执行插入【分割符】 */
            temp.insert(seperator, at: temp.index(temp.startIndex, offsetBy: index))
        }
        return temp
    }
    func specailShow() -> NSMutableAttributedString {
        let arr = self.components(separatedBy: "/")
        if arr.count < 2 {
            return NSMutableAttributedString(string: self)
        }
        let comAttr: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.ThemeLabel.colorMedium]
        let specialAttr: [NSAttributedString.Key : Any] =  [.foregroundColor: UIColor.ThemeLabel.colorLite]
        return attributedString(commonAttr: comAttr, specailStringlist: [arr[0]], specailAttrs: [specialAttr])
    }
    
    func attributedString(commonAttr: [NSAttributedString.Key: Any],
                          specailStringlist: [String],
                          specailAttrs: [[NSAttributedString.Key: Any]] ) -> NSMutableAttributedString {
        
        let attrStr = NSMutableAttributedString.init(string: self, attributes: commonAttr)
        let nsString = NSString(string: self)
        for (index,item) in specailStringlist.enumerated() {
            let range = nsString.range(of: item)
            let style = specailAttrs[index]
            attrStr.addAttributes(style, range: range)
        }
        return attrStr
    }
    
    // precision = 4   1 => 0.0001
    func mapPrecision(_ precision:String) -> String {
        
        if precision == "0" {
            return "1"
        }
        let length = Int(precision) ?? 0
        
        if (length > 0) {
            
            var ret = "0."
            for i in 0..<length {
                if (i == length - 1) {
                    ret.append("1")
                }else {
                    ret.append("0")
                }
            }
            
            return ret;
        }
        return "";
    }
    // 0.0001 = > 4
    func to_Precision() -> Int{
        var limetValue: Int = 0
        let px_unit = self
        if px_unit.count > 0 {
            if px_unit.contains("."){
                let pointRange = (px_unit as NSString).range(of: ".")
                let subSting = (px_unit as NSString).substring(from: pointRange.location)
                limetValue = subSting.count - 1
                if limetValue <= 0 {
                    limetValue = 1
                }
            }
        }
        return limetValue
    }
    func bigMul(_ right:String, decimals:Int16 = 12,up: Bool = false) -> String {
        if (self.isEmpty || right.isEmpty) {
            return "0";
        }
        if (Double(self) == 0 || Double(right) == 0) {
            return "0";
        }
        let leftM = NSDecimalNumber(string: self)
        let rightM = NSDecimalNumber(string: right)
        let roundUp = self.getNumberHandler(right: right,decimal: decimals,up:up)
        //        NSDecimalNumberHandler(roundingMode: .down,
        //                                             scale: decimals,
        //                                             raiseOnExactness: false,
        //                                             raiseOnOverflow: false,
        //                                             raiseOnUnderflow: false,
        //                                             raiseOnDivideByZero: true) ;
        let mulRes = leftM.multiplying(by: rightM, withBehavior: roundUp)
        
        return  mulRes.stringValue;
    }
    
    func bigDiv(_ right:String, decimals:Int16 = 12,up: Bool = false) -> String {
        if (self.isEmpty || right.isEmpty) {
            return "0";
        }
        if (Double(self) == 0 || Double(right) == 0) {
            return self;
        }
        let leftM = NSDecimalNumber(string: self)
        let rightM = NSDecimalNumber(string: right)
        let roundUp = self.getNumberHandler(right: right,decimal: decimals,up:up)
        //NSDecimalNumberHandler(roundingMode: .down, scale: decimals, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true) ;
        let mulRes = leftM.dividing(by: rightM, withBehavior: roundUp)
        
        return  mulRes.stringValue;
    }
    
    func bigAdd(_ right:String, decimals:Int16 = 12,up: Bool = false) -> String {
        if (self.isEmpty || right.isEmpty) {
            return "0";
        }
        
        let leftM = NSDecimalNumber(string: self)
        let rightM = NSDecimalNumber(string: right)
        let roundUp = self.getNumberHandler(right: right,decimal: decimals,up:up)
        let mulRes = leftM.adding(rightM, withBehavior: roundUp)
        
        return  mulRes.stringValue;
    }
    
    func bigSub(_ right:String, decimals:Int16 = 12,up: Bool = false) -> String {
        if (self.isEmpty || right.isEmpty) {
            return "0";
        }
        
        let leftM = NSDecimalNumber(string: self)
        let rightM = NSDecimalNumber(string: right)
        let roundUp = self.getNumberHandler(right: right,decimal: decimals,up:up)
        let mulRes = leftM.subtracting(rightM, withBehavior: roundUp)
        
        return  mulRes.stringValue;
    }
    
    func exs_formatAmountUseDecimal(_ decimal:String, holdZero:Bool = true) -> String {
        
        if self.isEmpty {
            return ""
        }
        let newStr = self.decimalString()
        if decimal.isEmpty {
            return newStr
        }
        
        guard let numberDecimal = Int(decimal) else {return newStr}
        return newStr.exs_decimalString1(numberDecimal,holdZero:holdZero)
    }
    func exs_decimalString(_ decimal:Int) -> String
    {
        let num_1 = NSDecimalNumber(string: "0")
        let num_2 = NSDecimalNumber(string: self)
        let handel = self.getNumberHandler(decimal: Int16(decimal))
        let num_3 = num_1.adding(num_2, withBehavior: handel);
        return num_3.stringValue;
    }
    /*
     默认: down
     up:是否向上取整
     */
    func getNumberHandler(right: String? = "0",decimal:Int16, up: Bool = false) -> NSDecimalNumberHandler {
        
        if up{ //向上取整
            var handel = NSDecimalNumberHandler(roundingMode: .up, scale: decimal, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false);
            if self.hasPrefix("-") || (right != nil && right!.hasPrefix("-")){
                //当是负数的时 .up 是向下取整
                handel = NSDecimalNumberHandler(roundingMode: .down, scale: Int16(decimal), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            }
            return handel
        }
        //向下取整
        var handel = NSDecimalNumberHandler(roundingMode: .down, scale: decimal, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false);
        if self.hasPrefix("-") || (right != nil && right!.hasPrefix("-")){
            //当是负数的时 .up 是向下取整
            handel = NSDecimalNumberHandler(roundingMode: .up, scale: Int16(decimal), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        }
        return handel
    }
    /**
     对计算的小数来处理
     holdZero: 要不要0
     */
    public func exs_decimalString1(_ decimal:Int, holdZero: Bool = false) -> String {
        if holdZero == false{
            return self.exs_decimalString(decimal)
        }
        
        let components = self.split(separator: ".")
        var integerPart = components.first ?? "0"
        if decimal == 0 {
            return "\(integerPart)"
        }
        var decimalPart = components.count > 1 ? components[1] : ""
        while decimalPart.count < decimal {
            decimalPart.append("0")
        }
        return "\(integerPart).\(decimalPart.prefix(decimal))"
        
//        var rid = self
//        if (decimal >= 0){
//            var murid = rid;
//            if (!murid.contains(".")){ // 小数点
//                murid = murid.appending(".");
//            }
//            let arr = murid.components(separatedBy: ".");
//            if (arr.count > 1){ //小数点后的处理
//                let count = decimal - arr[1].count //小数差几位
//                if (count > 0){ //
//                    if holdZero{ //需要0 补0
//                        for _ in 0..<count{ //补几位
//                            murid = murid.appending("0");
//                        }
//                    }
//                }else{ //小数位截取
//                    let c = arr[0].count + decimal + 1
//                    murid = (murid as NSString).substring(to: c)
//                }
//            }
//            if murid.hasSuffix("."){ //第一步拼了.,处理掉
//                murid = (murid as NSString).substring(to: murid.count - 1)
//            }
//            rid = murid
//        }
//        return rid;
    }
    
    
    func upAndDownText() -> String {
        if self.greaterThan("0") {
            return "+" + self
        }else {
            return self
        }
    }
    
     
}


public extension String {
    func newReplaceString() -> String{
        var newStr = self
        if newStr.contains("%s") {
            newStr = newStr.replacingOccurrences(of: "%s", with: "%@")
        }
        if newStr.contains("\\n"){
            newStr = newStr.replacingOccurrences(of: "\\n", with: "\n")
        }
        if newStr.contains("$s") {
            do {
                var input = newStr
                let regex = try NSRegularExpression(pattern: #"%(\d+\$)?s"#)
                for result in regex.matches(in: input, range: NSRange(location: 0, length: input.count)).reversed() {
                    let startIndex = input.index(input.startIndex, offsetBy: result.range.lowerBound)
                    let endIndex = input.index(input.startIndex, offsetBy: result.range.upperBound)
                    let ranage = startIndex..<endIndex
                    let substring = input[ranage]
                    let replacement = substring.replacingOccurrences(of: "s", with: "@")
                    input.replaceSubrange(ranage, with: replacement)
                }
                return input
            } catch {
                return newStr
            }
        }
        return newStr
    }
}
public extension String {
    func formatWithArguments(arguments: [String]) -> String{
        if arguments.count == 0 {
            return self
        }
        let placeholderCount = self.findPlaceholders(in: self)
        if placeholderCount != arguments.count {
            return self
        }
        let newStr = String(format: self, arguments: arguments)
        return newStr
    }
    func findPlaceholders(in text: String) -> Int {
        var pattern = "%@"  //%1$@%2$@
        if text.contains("$@"){
            pattern = "$@"
        }
        let arr = text.components(separatedBy: pattern)
        return arr.count - 1
    }
}

public extension String {
    
    /// english string formatting, adding blank string
    /// - Parameters:
    ///   - format: string
    ///   - arguments: arguments
    ///   - isEnglishBlank: In English mode, whether to add blank string
    /// - Returns: Formatted string
    static func format(_ format: String?, arguments: [Any], _ isEnglishBlank: Bool = false) -> String {
        var string = format ?? ""
        let blankString = (isEnglishBlank && LanguageHandler.phoneLanguage == "en_US") ? " " : ""
        for argument in arguments {
            string += String(format: "\(blankString)\(argument)")
        }
        return string
    }
}


public extension String {
    ///
    private var ex_nsString:NSString { (self as NSString) }
    ///
    var isAbsolutePath: Bool { ex_nsString.isAbsolutePath }
    var pathComponents: [String] { ex_nsString.pathComponents }
    var lastPathComponent: String { ex_nsString.lastPathComponent }
    var deletingLastPathComponent: String { ex_nsString.deletingLastPathComponent }
    var pathExtension: String { ex_nsString.pathExtension }
    var deletingPathExtension: String { ex_nsString.deletingPathExtension }
    
    var abbreviatingWithTildeInPath: String { ex_nsString.abbreviatingWithTildeInPath }
    var expandingTildeInPath: String { ex_nsString.expandingTildeInPath }
    var standardizingPath: String { ex_nsString.standardizingPath }
    var resolvingSymlinksInPath: String { ex_nsString.resolvingSymlinksInPath }
    ///
    static func path(withComponents components: [String]) -> String { NSString.path(withComponents: components) }
    func appendingPathComponent(_ str: String) -> String { ex_nsString.appendingPathComponent(str) }
    func appendingPathExtension(_ str: String) -> String? { ex_nsString.appendingPathExtension(str) }
    func strings(byAppendingPaths paths: [String]) -> [String] { ex_nsString.strings(byAppendingPaths: paths) }
}

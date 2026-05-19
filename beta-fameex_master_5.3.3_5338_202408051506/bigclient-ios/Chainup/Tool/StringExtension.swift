//
//  NSStringExtension.swift
//  SDJG
//
//  Created by wangzewu on 16/5/31.
//Modify by Wang Jun on 17/6/5 Swift3.0
//  Copyright © 2016年 sunland. All rights reserved.
//

import Foundation
import UIKit

/*
 "👌🏿".isSingleEmoji // true
 "🙎🏼‍♂️".isSingleEmoji // true
 "👨‍👩‍👧‍👧".isSingleEmoji // true
 "👨‍👩‍👧‍👧".containsOnlyEmoji // true
 "Hello 👨‍👩‍👧‍👧".containsOnlyEmoji // false
 "Hello 👨‍👩‍👧‍👧".containsEmoji // true
 "👫 Héllo 👨‍👩‍👧‍👧".emojiString // "👫👨‍👩‍👧‍👧"
 "👨‍👩‍👧‍👧".glyphCount // 1
 "👨‍👩‍👧‍👧".characters.count // 4
 
 "👫 Héllœ 👨‍👩‍👧‍👧".emojiScalars // [128107, 128104, 8205, 128105, 8205, 128103, 8205, 128103]
 "👫 Héllœ 👨‍👩‍👧‍👧".emojis // ["👫", "👨‍👩‍👧‍👧"]
 
 "👫👨‍👩‍👧‍👧👨‍👨‍👦".isSingleEmoji // false
 "👫👨‍👩‍👧‍👧👨‍👨‍👦".containsOnlyEmoji // true
 "👫👨‍👩‍👧‍👧👨‍👨‍👦".glyphCount // 3
 "👫👨‍👩‍👧‍👧👨‍👨‍👦".characters.count // 8
 */

extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}

extension String{
    func StringToFloat()->(CGFloat){
        let string = self
        var cgFloat:CGFloat = 0
        if let doubleValue = Double(string){
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    var glyphCount: Int {
        
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        
        return !isEmpty
            && !unicodeScalars.contains(where: {
                !$0.isEmoji
                    && !$0.isZeroWidthJoiner
            })
    }
    
    // The next tricks are mostly to demonstrate how tricky it can be to determine emoji's
    // If anyone has suggestions how to improve this, please let me know
    var emojiString: String {
        
        return emojiScalars.map { String($0) }.reduce("", +)
    }
    
    var emojis: [String] {
        
        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                
                scalars.append(currentScalarSet)
                currentScalarSet = []
            }
            currentScalarSet.append(scalar)
            
            previousScalar = scalar
        }
        
        scalars.append(currentScalarSet)
        
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }
    
    fileprivate var emojiScalars: [UnicodeScalar] {
        
        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            
            if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
                chars.append(previous)
                chars.append(cur)
                
            } else if cur.isEmoji {
                chars.append(cur)
            }
            
            previous = cur
        }
        
        return chars
    }
    
    //Does it include emoji? The new version recommends using containsEmoji
    public func isContainsEmoji(_ text:String?) -> Bool {
        guard text != nil else{
            return false
        }
        
        let string = text! as NSString
        var returnValue: Bool = false
        
        string.enumerateSubstrings(in: NSMakeRange(0, (string as NSString).length), options: NSString.EnumerationOptions.byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) -> () in
            
            let objCString:NSString = NSString(string:substring!)
            let hs: unichar = objCString.character(at: 0)
            if 0xd800 <= hs && hs <= 0xdbff
            {
                if objCString.length > 1
                {
                    let ls: unichar = objCString.character(at: 1)
                    let step1: Int = Int((hs - 0xd800) * 0x400)
                    let step2: Int = Int(ls - 0xdc00)
                    let uc: Int = Int(step1 + step2 + 0x10000)
                    
                    if 0x1d000 <= uc && uc <= 0x1f77f
                    {
                        returnValue = true
                    }
                }
            }
            else if objCString.length > 1
            {
                let ls: unichar = objCString.character(at: 1)
                if ls == 0x20e3
                {
                    returnValue = true
                }
            }
            else
            {
                if 0x2100 <= hs && hs <= 0x27ff
                {
                    returnValue = true
                }
                else if 0x2b05 <= hs && hs <= 0x2b07
                {
                    returnValue = true
                }
                else if 0x2934 <= hs && hs <= 0x2935
                {
                    returnValue = true
                }
                else if 0x3297 <= hs && hs <= 0x3299
                {
                    returnValue = true
                }
                else if hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50
                {
                    returnValue = true
                }
            }
        }
        
        return returnValue;
    }
    
    //http%3A%2F%2F172.16.13.30%3A8999%2Findex.html%3Fuid%3D705981%23exam
    //: //# Will be escaped
    public func wk_URLEncodedString3() -> String{
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted)
        if let escapedString = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString
        }
        return ""
    }
    
    //Returns the number of characters in the incoming string, calculated as 0.5 in English. For example, a is 0.5, and ab is 1 Chinese character, calculated as 1 character
    public func convert(toInt:String) -> Int {
        var number = 0
        for character in toInt {
            let characterString = String(character)
            let characterBytes = characterString.cString(using: .utf8)
            if characterBytes?.count == 2 {
                number += 1
            }else if characterBytes?.count == 4 {
                number += 2
            }
        }
        return (number+1)/2
    }
    
    
    
    //MARK: URL Add Request Parameter URL Address Request Parameter Append Time Stamp
    public func appendRequestParam(_ params :[String:String] , isAppendRandowm : Bool = false) -> String{
        
        //New URL
        var newUrl = ""
        
        //Splice request parameters
        var paramStr = ""
        params.keys.forEach { (key :String) in
            paramStr = paramStr.appending("&\(key)=\(params[key] == nil ? "" : params[key]! )")
        }
        if paramStr.count > 0{
            paramStr = String(paramStr.suffix(from: paramStr.index(paramStr.startIndex, offsetBy: 1)))
        }
        
        //If it is a legal URL
        if let url = NSURL(string: self){
            
            if let scheme = url.scheme {
                newUrl = newUrl.appending(scheme + "://")
            }
            
            if let host = url.host {
                newUrl = newUrl.appending(host)
            }
            
            if let port = url.port {
                newUrl = newUrl.appending(":\(port)")
            }
            
            if let path = url.path {
                newUrl = newUrl.appending(path)
            }
            
            var joinStr = "?"
            if let query = url.query ,  query != "" {
                newUrl = newUrl.appending(joinStr + query)
                joinStr = "&"
            }
            
            if paramStr.count > 0 {
                newUrl = newUrl.appending(joinStr + paramStr + "\(isAppendRandowm ? "&random=\(arc4random()%10)" : "")")
            }
            
            if let fragment = url.fragment {
                newUrl = newUrl.appending("#"+fragment)
            }
        }
        
        return newUrl
    }
    
    //To determine the height of a character, you need to pass in the character size and width
    //Returns width and height
    public  func textSizeWithFont(_ font: UIFont, width:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {
        
        var textSize:CGSize!
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        if size.equalTo(CGSize.zero) {
            
            let attributes = [NSAttributedStringKey.font:font]
            
            textSize = self.size(withAttributes: attributes)
            
        } else {
            
            let attributes = [NSAttributedStringKey.font:font]
            
            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            
            textSize = stringRect.size
        }
        return textSize
    }
    
    public func textHeightSizeWithFont(_ font: UIFont, height:CGFloat,option : NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {
        
        var textSize:CGSize!
        
        let size = CGSize(width: 10000, height: height)
        
        if size.equalTo(CGSize.zero) {
            
            let attributes = [NSAttributedStringKey.font:font]
            
            textSize = self.size(withAttributes: attributes)
            
        } else {
            
            let attributes = [NSAttributedStringKey.font:font]
            
            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            
            textSize = stringRect.size
        }
        return textSize
    }
    
    /**
String string truncation
     */
    public  func extStringSub(_ range : NSRange)->String{
        
        let beforeStr = NSString.init(string: self)
        
        let afterStr = beforeStr.substring(with: range)
        
        return afterStr as String
    }
    
    /**
Regular search forms such as the name=value value section
     
     - returns: value
     */
    public func regexStringUrlValueOfParam(paramName p :String) -> String {
        let reg = "(?<="+p+"\\=)[^&]+"
        
        let decodeStrUrl = self.removingPercentEncoding!
        let range =  decodeStrUrl.range(of: reg, options: String.CompareOptions.regularExpression, range: nil, locale: nil)
        if range  != nil {
            return String(decodeStrUrl[range!])
        }
        return ""
    }
    /**
Determine whether a string is a pure number
     
     - returns: value
     */
    public func isNumber() -> Bool{
        if self.count == 0{
            return false
        }else{
            let reg = "[0-9]*"
            let predicate = NSPredicate.init(format: "SELF MATCHES %@", reg)
            let result = predicate.evaluate(with: self)
            return result
        }
    }
    
    ///Example of string truncation (countable closed interval):
    /// let str = "hello word"
    /// let tmpStr = hp[0 ... 5] tmpStr = hello
    ///- Parameter r: String range
    public subscript (r: CountableClosedRange<Int>) -> String{
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
    
    ///Example of string truncation (countable open interval):
    /// let str = "hello word"
    /// let tmpStr = hp[0 ..< 5] tmpStr = hello
    ///- Parameter r: String range
    public subscript (r: CountableRange<Int>) -> String{
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
    
    ///String replacement (countable closed interval)
    ///Usage str.sd_ ReplaceSubrange (r: 0..<5, with: "hahahah")
    /// - Parameters:
    ///- r: range (countable closed interval)
    ///- with: String for alternate replacement
    public mutating func sd_replaceSubrange(r: CountableClosedRange<Int>,with:String){
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        var endIndex:String.Index?
        if r.upperBound > self.count{
            endIndex = self.index(self.startIndex, offsetBy: self.count)
        }else{
            endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        }
        //        self.replaceSubrange(Range<String.Index>(startIndex..<endIndex!), with: with)
    }
}

extension String{
    
    //Returns the index of the first occurrence of a specified substring in this string
    //(If the backwards parameter is set to true, the last occurrence position is returned)
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    //cover
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
    
}

//regular Expression
extension String {
    
    //Determine whether it complies with the transaction password rules, with numbers and letters greater than or equal to 8 digits but less than or equal to 20
    func isValidTransactionpPwd() -> Bool {
        return isValidRegex(regex: "^(?![0-9]+$)(?![a-zA-Z]+$).*[0-9A-Za-z]{8,20}$")
    }
    
    //Determine whether the input amount and currency quantity rules are met. Decimal==0 can only enter integers. For the rest, enter according to the decimal rule.
    //00 cannot be entered consecutively, Decimal separator cannot be entered at the beginning, and only one Decimal separator can be entered
    func isValidInputAmount(decimal:Int = 18) -> Bool {
        if decimal == 0 {
            //Only integers can be entered
            return isValidRegex(regex: "^\\+?[1-9][0-9]*$")
        }else {
            //General input, 18 digits can be input after the default Decimal separator
            let regex = "^[0][0-9]+$"
            let regexDot = "^[.]+$"
            let predicate0 = NSPredicate(format: "SELF MATCHES %@", regex)
            let predicateDot = NSPredicate(format: "SELF MATCHES %@", regexDot)
            
            let isZeroPrefix = predicate0.evaluate(with: self)
            let isDotPrefix = predicateDot.evaluate(with: self)
            
            if  isZeroPrefix || isDotPrefix {
                return false
            }
            
            return isValidRegex(regex: "^([0-9]*)?(\\.)?([0-9]{0,\(decimal)})?$")
        }
    }
    
    private func isValidRegex(regex: String) -> Bool {
        let regex = regex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let valid = predicate.evaluate(with: self)
        return valid
    }
    
    static func placeholderAttributeString(placeholder:String,fontSize:Int = 12,color:UIColor = UIColor.ThemeLabel.colorLite) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString.init(string: placeholder,
                                                              attributes:[NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                                                                          NSAttributedStringKey.foregroundColor: color])
        return attributedString
    }
    
}

enum EXCurrencyUnitFormat {
    case coinFormat
    case fiatFormat
}

extension String {
    
    func localized() -> String{
        return LanguageTools.getString(key: self)
    }
    
    func copyToPasteBoard() {
        UIPasteboard.general.string = self
    }
    
    static func privacyString() -> String{
        return "*****"
    }
    
    //Small limit, displaying asset allocation with minimum btc
    static func limitSatoshi() -> String {
        return "0.0001"
    }
    
    func getCaculatePrice(forSymbol:String,withUnit:Bool = false)->String {
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(forSymbol)
        let unit = currency.0
        let rate = currency.1
        let decimal = currency.2
        let balance = self as NSString
        if let rst =  balance.multiplying(by: rate, decimals: decimal) {
            if withUnit {
                return "≈" + unit + rst
            }else {
                return rst
            }
        }else {
            if withUnit {
                return "≈" + unit + "0"
            }else {
                return "0"
            }
        }
    }
    
    func formatCurrencyMoney(_ symbol:String,holdZero:Bool = true, format:EXCurrencyUnitFormat = .coinFormat) ->String {
        if self.isEmpty {
            return ""
        }
        //Currency and fiat currency accuracy
        if format == .coinFormat {
            let currencyModel = EXAppMarketManager.sharedInstance.getCurrencyModel(symbol)
            let precion = Int(currencyModel.coin_precision)
            
            let nsAmount = self as NSString
            if holdZero {
                let rst = nsAmount.decimalString1(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }else {
                let rst = nsAmount.decimalString(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }
        }
            //Legal currency accuracy, independent configuration of legal currency
        else if format == .fiatFormat {
            let currencyModel = EXAppMarketManager.sharedInstance.getCurrencyModel(symbol)
            let precion = Int(currencyModel.coin_fiat_precision)
            
            let nsAmount = self as NSString
            if holdZero {
                let rst = nsAmount.decimalString1(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }else {
                let rst = nsAmount.decimalString(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }
        }else  {
            //Format failed, return directly
            return self
        }
    }
    
    func formatAmount(_ forSymbol:String, holdZero:Bool = true,isLeverage : Bool = false) -> String {
        if self.isEmpty {
            return ""
        }

        var decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(forSymbol)

        if isLeverage {
            decimal = 8
        }
        let nsAmount = self as NSString
        if holdZero {
            let rst = nsAmount.decimalString1(decimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }else {
            let rst = nsAmount.decimalString(decimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }
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
    
    //Directly calling symbol to obtain alias
    func aliasName() -> String {
        if self.isEmpty {
            return self
        }
        if let coinModel = EXAppMarketManager.sharedInstance.getCoinEntity(self) {
            //TODO: showname
            if coinModel.name.isEmpty {
                return self
            }
            //TODO: return showname
            return coinModel.showName
        }
        return self
    }
    
    //Directly call name to obtain alias
    func aliasCoinMapName() -> String{
        if self.isEmpty {
            return self
        }
        let coinMapModel = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(self)
        if coinMapModel.name.isEmpty{
            return self
        }else{
            return coinMapModel.showName
        }
    }
    
    func decimalNumberWithDouble() -> String{
        if let conversionValue = Double(self){
            let decimalNumberWithDouble = String(conversionValue)
            let decNumber = NSDecimalNumber.init(string: decimalNumberWithDouble as String)
            return "\(decNumber)"
        }
        return self
    }
    
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
    
    //Do you want to retrieve appapi000xxxx from the IP link or from the normal connection
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
    
    func lineSpacingString(font: UIFont, color: UIColor, lineSpacing: CGFloat, textAligment: NSTextAlignment = NSTextAlignment.center) -> NSAttributedString {
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = textAligment
        paraph.lineSpacing = lineSpacing
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.paragraphStyle: paraph]
        return NSAttributedString(string: self, attributes: attributes)
    }

}

extension String {
    func getHeightlineH(width: CGFloat, font: CGFloat, lineH: CGFloat) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //Style Attribute Collection
         let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: font),
                           NSAttributedStringKey.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
         return rect.size.height + 1
     }
    func getHeightline(width: CGFloat, font: CGFloat, lineH: CGFloat) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //Style Attribute Collection
         let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: font),
                           NSAttributedStringKey.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
         return rect.size.height + 1
     }
    func getTextWidth(width: CGFloat = SCREEN_WIDTH, font: CGFloat, lineH: CGFloat = 0) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //Style Attribute Collection
         let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: font),
                           NSAttributedStringKey.paragraphStyle: paraph]
         let rect = self.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.width
     }

    
    func md5PngFileName() ->String {
        return AppService.md5(self) + "@2x"
    }
}


extension String {
    func isEmail() -> Bool {
        return isValidRegex(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,30}")
    }
    func isPhone() -> Bool {
        return isValidRegex(regex: "^[0-9]{5,11}$")
    }
    func isChinaPhone() -> Bool {
        return isValidRegex(regex: "^1[0-9]{10}$")
    }
    
    func desensitizedPhone() -> String {
        if self.count < 7 {
            return self
        }
        var start = ""
        for _ in 0..<self.count - 5 {
            start += "*"
        }
        let range = Range.init(NSRange.init(location: 3, length: self.count - 5), in: self)
        return self.replacingCharacters(in:range!, with: start)
    }
    func desensitizedMail() -> String {
        
        let array = self.components(separatedBy: "@")
        
        if array.count == 0 {
            return self
        }
        
        if let name = array.first {
            if name.count == 1 {
                return self
            }
            if name.count >= 4 {
                let range = Range.init(NSRange.init(location: 3, length: name.count - 3), in: self)
                return self.replacingCharacters(in:range!, with: "****")
            }
            else {
                let range = Range.init(NSRange.init(location: 1, length: name.count - 1), in: self)
                return self.replacingCharacters(in:range!, with: "****")
            }
        }
        
        return self
    }
    
    static func makeTipsAttributedString(content: String, actionContent: String, action: @escaping (() -> ())) -> NSMutableAttributedString {
        let accatt = NSMutableAttributedString.init().add(string: content, attrDic: [NSAttributedStringKey.foregroundColor : UIColor.ThemeLabel.colorDark , NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: .medium)]).add(string: actionContent, attrDic: [NSAttributedStringKey.foregroundColor : UIColor.ThemeLabel.colorHighlight , NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: .medium)])
        accatt.highLightTap((accatt.string as NSString).range(of: actionContent), { (view, attstr, range, rect) in
            action()
        })
        return accatt
    }
}


extension String {

    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    func ranges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString, options: mask, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }

    func nsRanges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [NSRange] {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
}


//Calculated
extension String {
    
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
    
    //Roundplain rounding
    func stringByMultiplying(multiple:String,decimal:Int,holdZero:Bool = false,useRoundPlain:Bool = false) -> String {
        if useRoundPlain {
            return (self as NSString).multiplyingBy1(multiple, decimals: decimal, holdZero: holdZero)
        }else {
            return (self as NSString).multiplying(by: multiple, decimals: decimal,holdZeor: holdZero)
        }
    }
}

extension String {
    
    func getValueColor() ->UIColor {
        if self.isBiggerThan("0") {
            return UIColor.ThemekLine.up
        }else if self.isEquals("0") {
            return UIColor.ThemeLabel.colorLite
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
}

extension String
{
    public func util_subString(end: Int) -> String{
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
}

extension NSAttributedString{
    
}


extension String {
    
    var urlStr: String{
        var charSet = CharacterSet.urlQueryAllowed
        charSet.insert(charactersIn: "#")
        let encodingURL = self.addingPercentEncoding(withAllowedCharacters: charSet )
        return encodingURL ?? ""
    }
    /*
*Remove first and last spaces
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
*Remove the first and last spaces, including the following line breaks  n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
*Remove all spaces
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
*Specify the number of starting and ending spaces after removing the first and last spaces
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }
    
    func attributeString(specalSubStr:String,specailAttri:[NSAttributedString.Key: Any], commonAttri:[NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString.init(string: self, attributes: commonAttri)
        if specalSubStr.count > 0{
            let total = NSString(string: self)
            let rangle = total.range(of: specalSubStr)
            attr.addAttributes(specailAttri, range: rangle)
        }
        return attr
    }
}



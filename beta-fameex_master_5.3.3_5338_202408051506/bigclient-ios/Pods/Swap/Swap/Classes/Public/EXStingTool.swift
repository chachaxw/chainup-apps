//
//  EXStingTool.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/6/17.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXStingTool: NSObject {

    //数字每隔三位添加一个逗号 千分位逗号分隔符 English: Add a comma every three digits to the number, with a comma separator in the thousandth place
   class func showInComma(source: String, gap: Int=3, seperator: Character=",") -> String {
            var temp = source
            /* 获取目标字符串的长度 Get the length of the target string*/
            let count = temp.count
            /* 计算需要插入的【分割符】数 Calculate the number of separators to be inserted*/
            let sepNum = count / gap
            /* 若计算得出的【分割符】数小于1，则无需插入 If the calculated number of separators is less than 1, there is no need to insert*/
            guard sepNum >= 1 else {
                return temp
            }
            /* 插入【分割符】 */ English: /*Insert [Splitter]*/
            for i in 1...sepNum {
                /* 计算【分割符】插入的位置  Calculate the insertion position of the separator*/
                let index = count - gap * i
                /* 若计算得出的【分隔符】的位置等于0，则说明目标字符串的长度为【分割位】的整数倍，如将【123456】分割成【123,456】，此时如果再插入【分割符】，则会变成【,123,456】If the position of the calculated 【 separator 】 is equal to 0, it indicates that the length of the target string is an integer multiple of 【 separator 】. For example, if 【 123456 】 is divided into 【 123456 】, if 【 separator 】 is inserted again, it will become 【, 123456 】*/
                guard index != 0 else {
                    break
                }
                /* 执行插入【分割符】 Execute Insert [Splitter]*/
                temp.insert(seperator, at: temp.index(temp.startIndex, offsetBy: index))
            }
            return temp
    }
    /*
     let regex = "tom"
     var code = "tom asked me if I would go fishing with him tomorrow."
     print(replaceWhenRegularExpressionMatch(regex, code, with: "Jerry"))
     */
    class func replaceWhenRegularExpressionMatch(_ regex: String, _ validateString: String, with template: String) -> String{
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let temp = regex.stringByReplacingMatches( in: validateString , options: [], range: NSMakeRange(0, validateString.count),withTemplate: template)
            return temp
        } catch {
            return validateString
        }
    }
    
    class func replaceDateWithTimeStamp(targetString: String,repalceStr: String) -> String{
        if repalceStr == "" || targetString == ""{
            return targetString
        }
        /*
         这个正则表达式是用来匹配日期时间格式的，包括年月日和时分秒，格式为YYYY-MM-DD HH:MM:SS。其中，YYYY表示四位数的年份，MM表示两位数的月份，DD表示两位数的日期，HH表示两位数的小时，MM表示两位数的分钟，SS表示两位数的秒钟。这个正则表达式可以用于验证用户输入的日期时间格式是否正确。 English: This regular expression is used to match date and time formats, including year, month, day, hour, minute, and second, in the format YYYY-MM-DD HH: MM: SS. Among them, YYYY represents a four digit year, MM represents a two digit month, DD represents a two digit date, HH represents a two digit hour, MM represents a two digit minute, and SS represents a two digit second. This regular expression can be used to verify whether the date and time format entered by the user is correct.
         
         找到旧的日期，用新的日期替换 English: Find the old date and replace it with the new one
         */
        
    
        let regex = "([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8])))([ ])([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])"
        let result = replaceWhenRegularExpressionMatch(regex, targetString, with: repalceStr)
//        //print("result = \(result)")
        return result
        
    }
}


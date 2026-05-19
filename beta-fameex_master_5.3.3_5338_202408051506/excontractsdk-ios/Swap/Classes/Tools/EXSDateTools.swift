//
//  EXSDateTools.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSDateTools: NSObject {
    
    //获取当前时间戳 English: Get the current timestamp
    public class func getNowTimeInterval(date: Date? = nil) -> Int{
        var newDate = Date()
        if date != nil {
            newDate = date!
        }
        
        let timeInterval = Int(newDate.timeIntervalSince1970)
        return timeInterval
    }
    
    public class func getMillTimeInterval() -> (Double, String){
        let date = Date()
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let millisecond = Double(CLongLong(round(timeInterval*1000)))
        
        return (millisecond,"\(millisecond)")
    }
    
    //字符串类型转成时间 English: Convert string type to time
    public class func strToTimeString(_ string : String , dateFormat : String = "yyyy-MM-dd HH:mm:ss") -> String{
        var time = TimeInterval.init(0)
        if string.count >= 13{
            if let t = TimeInterval.init(string.prefix(10)){
                time = t
            }
        }else{
            if let t = TimeInterval.init(string){
                time = t
            }
        }
        return dateToString(time ,dateFormat:dateFormat)
    }
    
    //数字类型转时间 English: Number type conversion time
    public class func dateToString(_ time : TimeInterval, dateFormat : String = "yyyy-MM-dd HH:mm:ss") -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = Date.init(timeIntervalSince1970: time)
        let timestr = formatter.string(from: date)
        
        return timestr
    }
    
    public class func bool12() -> Bool{
        let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) ?? ""
//        //print("formatStringForHours = \(formatStringForHours)")
        if formatStringForHours.contains("a") {
            return true
        }
        return false
    }
    
    //转成时分秒 English: Convert to hours, minutes, and seconds
    public class func stringToHourMinSec(_ str : String) -> (Int , Int , Int){
        if let intStr = Int(str){
            let hour = intStr / 3600
            let min = (intStr - hour * 3600) / 60
            let sec = intStr % 60
            return (hour , min , sec)
        }
        return (0,0,0)
    }
    //specal 将12小时制的处理 English: Special will handle the 12 hour schedule
    public class func stringWithInterval(_ interval : TimeInterval) -> String {
        
        let intValue = Int(interval)
        let hour = intValue / 3600
        let min = (intValue - hour * 3600) / 60
        let sec = intValue % 60
        if let str = dateFor(hour: hour, minute: min, second: sec) {
            return dateToString(str,dateFormat: "HH:mm:ss")
        }
        return ""
    }
    
    
    //日期类型转成时间 English: Convert date type to time
    public class func dateToString(_ date : Date, dateFormat : String = "yyyy-MM-dd") -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: date)
    }
    
    
    //日期类型转成时间 English: Convert date type to time
    public class func nowTime(dateFormat: String? = "YYYY-MM-dd HH:mm:ss SSS") -> String{
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat// 自定义时间格式q1 English: Custom time format q1
        return dateformatter.string(from: date)
    }
    
    
    public class func getNextMonth(timeStamp:String) -> Date?{
        let date = self.timeStampToDate(timeString: timeStamp)
        if date == nil{
            return nil
        }
        var c = Calendar(identifier: .gregorian)
        c.timeZone = NSTimeZone.system
        let nextMonth = c.date(byAdding: .month, value: 1, to: date!)
//        //print("nextMo = \(nextMonth)") //时间差8小时 比当前慢8小时,转成时间戳 English: Time difference of 8 hours is 8 hours slower than the current time, converted to a timestamp
        return nextMonth
    }
    
    public class func getNow() -> Date {
        let today = Date()
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT()
        let now = today.addingTimeInterval(TimeInterval(interval))
        return now
    }
    
    public class func timeStampToString(_ timestamp:TimeInterval,dateFormat: String? = "YYYY-MM-dd HH:mm:ss") -> String{
        let date = Date(timeIntervalSince1970: timestamp)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat// 自定义时间格式q1 English: Custom time format q1
        return dateformatter.string(from: date)
    }
    public class func dataToString(timeString time:String, dateFormat : String = "yyyy-MM-dd") -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"// 自定义时间格式q1 English: Custom time format q1
        return dateformatter.date(from: time)
    }
    public class func timeStampToDate(timeString time:String) -> Date? {
        let interval = TimeInterval(time) ?? 0
        let date = Date(timeIntervalSince1970: interval)
        return date
    }
    
    public class  func dateFor(hour:Int, minute:Int, second:Int) -> Date? {
        
        let calendar:Calendar = Calendar.current
        
        var componets = calendar.dateComponents([
            .year,.month,.day,.hour,.minute,.second
        ], from: Date())

        if hour < 24 {
            componets.hour = hour
        }
        componets.minute = minute
        componets.second = second
//        if let year = componets.year, let month = componets.month, let day = componets.day, let hour = componets.hour
//           , let minute = componets.minute, let sec = componets.second {
//
//            let dateString = "\(year)-\(month)-\(day) \(hour):\(minute):\(sec)"
//            let date = dataToString(dateString)
//        }
        return calendar.date(from: componets)
//        if let date = calendar.date(from: componets) {
//            return date.addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
//        }
        
//        return nil
        
//        return nil
    }
    //标准的yyyy-mm-dd 才可以使用 English: Standard yyyy mm dd can only be used
    public class func getMouth(_ time : String) -> String{
        let substr = time
        var mouth = ""
        let array = substr.components(separatedBy: "-")
        if array.count > 1{
            mouth = array[1]
        }
        return mouth
    }
    
    //标准的yyyy-mm-dd 才可以使用 English: Standard yyyy mm dd can only be used
    public class func getDay(_ time : String) -> String{
        let substr = time
        var day = ""
        let array = substr.components(separatedBy: "-")
        if array.count > 2{
            day = array[2]
            let arr = day.components(separatedBy: " ")
            if arr.count > 0{
                day = arr[0]
            }
        }
        return day
    }
}


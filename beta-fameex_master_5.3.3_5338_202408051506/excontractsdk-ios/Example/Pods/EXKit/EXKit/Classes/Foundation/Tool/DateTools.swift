//
//  DateTools.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/16.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

public class DateTools: NSObject {
    
    //获取当前时间戳
    public class func getNowTimeInterval() -> Int{
        let date = Date()
        let timeInterval = Int(date.timeIntervalSince1970)
        return timeInterval
    }
    
    public class func getMillTimeInterval() -> String{
        let date = Date()
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    //字符串类型转成时间
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
        return DateTools.dateToString(time ,dateFormat:dateFormat)
    }
    
    //数字类型转时间
    public class func dateToString(_ time : TimeInterval, dateFormat : String = "yyyy-MM-dd HH:mm:ss") -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = dateFormat
        
//        if let timeZone = TimeZone.init(identifier: "Asia/Beijing"){
//            formatter.timeZone = timeZone
//        }
//
        let date = Date.init(timeIntervalSince1970: time)
        let timestr = formatter.string(from: date)
        
        return timestr
    }
    
    //转成时分秒
    public class func stringToHourMinSec(_ str : String) -> (Int , Int , Int){
        if let intStr = Int(str){
            let hour = intStr / 3600
            let min = (intStr - hour * 3600) / 60
            let sec = intStr % 60
            return (hour , min , sec)
        }
        return (0,0,0)
    }
    
    public class func stringWithInterval(_ interval : TimeInterval) -> String {
        
        let intValue = Int(interval)
        let hour = intValue / 3600
        let min = (intValue - hour * 3600) / 60
        let sec = intValue % 60
        if let str = dateFor(hour: hour, minute: min, second: sec) {
            
            return DateTools.dateToString(str,dateFormat: "HH:mm:ss")
        }
        return ""
    }
    
    //距离现在多少秒
    public class func nowSubTime(_ time : String) -> String{
        let date = Date().timeIntervalSince1970
        if let diff = NSString.init(string: "\(date)").subtracting(time, decimals: 0){
            return "\(diff)"
        }
        return "0"
    }
    
    //日期类型转成时间
    public class func dateToString(_ date : Date, dateFormat : String = "yyyy-MM-dd") -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    public class func getNow() -> Date {
        let today = Date()
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT()
        let now = today.addingTimeInterval(TimeInterval(interval))
        return now
    }
    public class func timeStampToString(_ timestamp:TimeInterval,dateFormat: String = "yyyy-MM-dd") -> String{
        let date = Date(timeIntervalSince1970: timestamp)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat //"YYYY-MM-dd HH:mm:ss"// 自定义时间格式q1
        return dateformatter.string(from: date)
    }
    public class func dataFromString(timeString time:String, dateFormat : String = "yyyy-MM-dd") -> Date? {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat
        return dateformatter.date(from: time)
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
        if let date = calendar.date(from: componets) {
            return date.addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
        }
        
//        return nil
        
//        return nil
    }
    //标准的yyyy-mm-dd 才可以使用
    public class func getMouth(_ time : String) -> String{
        let substr = time
        var mouth = ""
        let array = substr.components(separatedBy: "-")
        if array.count > 1{
            mouth = array[1]
        }
        return mouth
    }
    
    //标准的yyyy-mm-dd 才可以使用
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
    
    public class func isBeforeToday(from interval : TimeInterval) -> Bool
    {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        if let day = components.day,day < 0 {
            return true
        }else {
            return false
        }
    }
    
    
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    public class func updateTimeToCurrennTime(timeStamp: Double,isMillisecond:Bool = true,endTimeStamp:Double) -> String {
        //获取当前的时间戳
        if timeStamp == 0 {
            return "0\(EXUIDatasource.shared.noun_date_day)0\(EXUIDatasource.shared.noun_date_hour)0\(EXUIDatasource.shared.noun_date_minute)"
        }
        var end = Date().timeIntervalSince1970
        if endTimeStamp > 0 {
            end = (endTimeStamp / (isMillisecond ? 1000 : 1))
        }
        let currentTime = end
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / (isMillisecond ? 1000 : 1))
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta
        
        
        let days = Int(reduceTime / (60 * 60 * 24))
        let hours = Int((reduceTime.truncatingRemainder(dividingBy: 60 * 60 * 24)) / (60 * 60))
        let minutes = Int((reduceTime.truncatingRemainder(dividingBy: 60 * 60)) / (60))
//        let seconds = (reduceTime .truncatingRemainder(dividingBy:60))
        
        //时间差小于60秒
        /*
         "noun_date_day"="日";
         "noun_date_hour"="时";
         "noun_date_minute"="分";
         */
        return "\(days)\(EXUIDatasource.shared.noun_date_day)\(hours)\(EXUIDatasource.shared.noun_date_hour)\(minutes)\(EXUIDatasource.shared.noun_date_minute)"

    }
}

public extension Date {
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    var dayBefore180: Date {
        return Calendar.current.date(byAdding: .day, value: -180, to: self)!
    }
}

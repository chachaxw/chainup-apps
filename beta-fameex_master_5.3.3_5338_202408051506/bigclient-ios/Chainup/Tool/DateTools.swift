//
//  DateTools.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/16.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

class DateTools: NSObject {
    
    //Get the current timestamp
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
    
    //Convert string type to time
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
    
    //Number type conversion time
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
    
    //Convert to hours, minutes, and seconds
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
    
    //How many seconds is it from now
    public class func nowSubTime(_ time : String) -> String{
        let date = Date().timeIntervalSince1970
        if let diff = NSString.init(string: "\(date)").subtracting(time, decimals: 0){
            return "\(diff)"
        }
        return "0"
    }
    
    //Convert date type to time
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
        dateformatter.dateFormat = dateFormat //"YYYY-MM-dd HH:mm:ss"//Custom time format q1
        return dateformatter.string(from: date)
    }
    public class func dataToString(timeString time:String, dateFormat : String = "yyyy-MM-dd") -> Date? {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"//Custom time format q1
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
    //Standard yyyy mm dd can only be used
    public class func getMouth(_ time : String) -> String{
        let substr = time
        var mouth = ""
        let array = substr.components(separatedBy: "-")
        if array.count > 1{
            mouth = array[1]
        }
        return mouth
    }
    
    //Standard yyyy mm dd can only be used
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
    
    
    
    //MARK: - Returns a few minutes ago, a few hours ago, a few days ago based on the backend timestamp
    class func updateTimeToCurrennTime(timeStamp: Double,isMillisecond:Bool = true,endTimeStamp:Double) -> String {
        //Get the current timestamp
        if timeStamp == 0 {
            return "0\("noun_date_day".localized())0\("noun_date_hour".localized())0\("noun_date_minute".localized())"
        }
        var end = Date().timeIntervalSince1970
        if endTimeStamp > 0 {
            end = (endTimeStamp / (isMillisecond ? 1000 : 1))
        }
        let currentTime = end
        //If the timestamp is on the millisecond level, it needs to be divided by 1000, so there is no need to divide the second by 1000. Is the parameter with or without 000
        let timeSta:TimeInterval = TimeInterval(timeStamp / (isMillisecond ? 1000 : 1))
        //time difference
        let reduceTime : TimeInterval = currentTime - timeSta
        
        
        let days = Int(reduceTime / (60 * 60 * 24))
        let hours = Int((reduceTime.truncatingRemainder(dividingBy: 60 * 60 * 24)) / (60 * 60))
        let minutes = Int((reduceTime.truncatingRemainder(dividingBy: 60 * 60)) / (60))
//        let seconds = (reduceTime .truncatingRemainder(dividingBy:60))
        
        //Time difference less than 60 seconds
        /*
'nound_date_day'='Day';
'nound_date_hour'='hour';
Nound_date_minute "=" minutes ";
         */
        return "\(days)\("noun_date_day".localized())\(hours)\("noun_date_hour".localized())\(minutes)\("noun_date_minute".localized())"

    }
}


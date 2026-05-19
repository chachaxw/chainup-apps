//
//  EXLogManager.swift
//  EXKit
//
//  Created by cwd on 2023/9/6.
//

import UIKit


public class EXSwapLogManger {
    

    static public let shareInstance = EXSwapLogManger()
    public var maxSize:  Double = 0.5
    let fileManger = FileManager.default
    public var fileSuxName: String = ""
    public var filePath: String {
        var fileName = fileSuxName
        let date = DateTools.dateToString(Date())
        if fileName == "" {
            fileName = date
        }else{
            fileName = fileName + "_" + date
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + fileName + ".txt"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        return path
    }
    
//    public func readFile(){
//        let path = self.filePath
//        if !fileManger.fileExists(atPath: path) {
//
//        }
//        do{
//            let contents = try String(contentsOfFile: path)
//            let lines = contents.components(separatedBy: "\n")
//            for line in lines {
//                let words = line.components(separatedBy: " ")
//                print("\(words[0]) is \(words[1]) and likes \(words[4])")
//            }
//        }
//        catch
//        {
//            // contents could not be loaded
//        }
//
//    }
    
    
    
    public func readFile() -> Data?{
        let fileManager = self.fileManger
        if fileManager.fileExists(atPath: filePath) {
            do {
                if let fileData = fileManager.contents(atPath: filePath),
                   let fileContent = String(data: fileData, encoding: .utf8) {
                    return fileData
                } else {
                    print("readFile error ")
                    return nil
                }
            } catch {
                
                print("readFile error：\(error.localizedDescription)")
                return nil
            }
        }

        return nil
        
    }
    
    func getCurrentFileSizeOverLoad() -> Bool{
        let fileManager = fileManger
        if fileManager.fileExists(atPath: filePath) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                
                if let fileSize = attributes[.size] as? Int64 {
                    let fileSizeInMB = Double(fileSize) / (1024 * 1024)
                    
                    if fileSizeInMB > maxSize {
//                        print("grather than  \(maxSize) current size (\(fileSizeInMB) MB)")
//                        let fileContent = ""
//                        try fileContent.write(toFile: filePath, atomically: false, encoding: .utf8)
//                        print("remove all")
                        return true
                    } else {
                        return false
                    }
                }
            } catch {
                print("fail：\(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
        return false
    }
    
    public func deleteFile(){
        if fileManger.fileExists(atPath: filePath) {
            do {
                try? fileManger.removeItem(atPath: filePath)
            }catch  {
                print("delete error =、\(error)")
            }
        }
    }
   
    
    
    public func writeLog(content: String){
        if  getCurrentFileSizeOverLoad(){
            return
        }
        let fileHandle = FileHandle(forWritingAtPath: filePath)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(content.data(using: .utf8)!)
        if #available(iOS 13.0, *) {
            try? fileHandle.close()
        } else {
            // Fallback on earlier versions
            fileHandle.closeFile()
        }

    }
    
    

}

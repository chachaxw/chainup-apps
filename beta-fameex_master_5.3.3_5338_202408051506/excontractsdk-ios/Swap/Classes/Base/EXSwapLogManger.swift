//
//  EXSwapLogManger.swift
//  Swap
//
//  Created by cwd on 2023/8/1.
//

import UIKit

public class EXSwapLogManger {
    static public let shareInstance = EXSwapLogManger()
    let fileManger = FileManager.default
    public var fileSuxName: String = ""
    public var filePath: String {
        var fileName = fileSuxName
        if fileName == "" {
            fileName = "test"
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + fileName + ".txt"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        return path
    }
    public func deleteFile(){
        if fileManger.fileExists(atPath: filePath) {
            do {
                try? fileManger.removeItem(atPath: filePath)
            }catch  {
//                //print("文件删除失败 =、\(error)" )
              }
          
        }
    }
    
    public func writeLog(content: String){
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

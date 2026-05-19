//
//  FileTools.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/1.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class FileTools: NSObject {
    
    //MARK: Single Example
    public static var sharedInstance : FileTools{
        struct Static {
            static let instance : FileTools = FileTools()
        }
        return Static.instance
    }
    
    private let fileManager = FileManager.default
    
/*Get file path*/
    private func getFile(fileName : String , path : String) -> String{
        if fileName == ""{
            return path
        }
        return path + "/" + fileName
    }
    
/*Get sandbox home directory path*/
    public func homeDir() -> String{
        return NSHomeDirectory()
    }
    
/*App Path*/
    public func  appDir() -> String{
        let arrays = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return arrays[0]
    }
    
/*Obtain Documents directory path*/
    public func  docDir() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    /*Library*/
    public func  libraryDir() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
/*Get Caches directory path*/
    public func  cachesDir() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
/*Obtain tmp directory path*/
    public func  tmpDir() -> String{
        return NSTemporaryDirectory()
    }
    
/*Does the file exist*/
    public func  isFileExisted(fileName : String = "", path : String) -> Bool{
        return fileManager.fileExists(atPath: getFile(fileName : fileName , path : path))
    }
    
/*Create a file with the specified name*/
    public func  createFile(fileName : String = "", path : String , contents : Data? = nil , attributes : [FileAttributeKey : Any]? = nil) -> Bool{
        if fileManager.fileExists(atPath: path) == false{
            return fileManager.createFile(atPath: getFile(fileName : fileName , path : path), contents: contents, attributes: attributes)
        }
        return false
    }
    
/*Create a folder with the specified name*/
    public func  createDirectory(folderName : String = "", path : String ,withIntermediateDirectories : Bool = true, attributes : [FileAttributeKey : Any]? = nil) -> Bool{
        if fileManager.fileExists(atPath: path) == false{
            do {
                try fileManager.createDirectory(atPath: getFile(fileName : folderName , path : path), withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
            }catch{
                return false
            }
            return true
        }
        return false
    }
    
/*Obtain all file paths under a certain directory*/
    public func  filePathsWithDirPath(path : String) -> [String]{
        do{
            let tmpFiles = try fileManager.contentsOfDirectory(atPath: path)
            var files = [String]()
            for fileName in tmpFiles{
                files.append(path + "/" + fileName)
            }
            return files
        }catch{
            return []
        }
    }
    
/*Obtain all file names in a certain directory*/
    public func  fileWithDirPath(path : String) -> [String]{
        do{
            let tmpFiles = try fileManager.contentsOfDirectory(atPath: path)
            return tmpFiles
        }catch{
            return []
        }
    }
    
/*Delete all files in the directory*/
    public func  deleteFilesWithDirPath(path : String) -> Bool{
        let fileList = filePathsWithDirPath(path: path)
        for file in fileList{
            if deleteFile(path: file) == false{
                return false
            }
        }
        return true
    }
    
/*Delete files*/
    public func  deleteFile(fileName : String = "", path : String) -> Bool{
        if fileManager.fileExists(atPath: getFile(fileName: fileName, path: path)){
            do{
                try fileManager.removeItem(atPath: getFile(fileName : fileName , path : path))
            }catch{
                return false
            }
            return true
        }
        return false
    }
    
/*Delete files based on URL*/
    public func  deleteFileWithUrl(url : URL) -> Bool{
        do{
            try fileManager.removeItem(at: url)
        }catch{
            return false
        }
        return true
    }
    
/*Moving Files*/
    public func  moveFile(atName : String = "" , atPath : String , toName : String = "" ,toPath : String) -> Bool{
        do{
            try fileManager.moveItem(atPath: getFile(fileName: atName, path: atPath), toPath: getFile(fileName: toName, path: toPath))
        }catch{
            return false
        }
        return true
    }
    
/*Move files based on URLs*/
    public func  moveFile(atUrl : URL , toUrl : URL) -> Bool{
        do{
            try fileManager.moveItem(at: atUrl, to: toUrl)
        }catch{
            return false
        }
        return true
    }
    
/*Copying Files*/
    public func  copyFile(atName : String = "" , atPath : String , toName : String = "" ,toPath : String) -> Bool{
        do{
            try fileManager.copyItem(atPath: getFile(fileName: atName, path: atPath), toPath: getFile(fileName: toName, path: toPath))
        }catch{
            return false
        }
        return true
    }
    
/*Copy file based on URL*/
    public func  copyFile(atUrl : URL , toUrl : URL) -> Bool{
        do{
            try fileManager.copyItem(at: atUrl, to: toUrl)
        }catch{
            return false
        }
        return true
    }
    
}


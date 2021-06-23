//
//  Directory.swift
//  
//
//  Created by joser on 2021/6/23.
//

import Foundation
import ArgumentParser

struct Directory {
    let path:String
    var isExit:Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let isExit = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return isExit && isDirectory.boolValue
    }
    
    func create() throws {
        guard !self.isExit else {
            throw CleanExit.message("\(path)文件夹已经存在")
        }
        try FileManager.default.createDirectory(atPath: path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
}

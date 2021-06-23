//
//  OpenBranch.swift
//  
//
//  Created by 张行 on 2019/12/27.
//

import Foundation
import ArgumentParser
import SwiftShell

//struct OpenBranch {
//    let configuration:Configuration
//    func open() throws {
//        let namePath = try File(name: configuration.name).create()
//        main.currentdirectory = "\(namePath)/Head/source/"
//        try runAndPrint("git", "reset", "--hard")
//        try runAndPrint("git", "pull", "origin")
//        let branchsString = run("git", "branch", "-a").stdout
//        let branchContents = branchsString .components(separatedBy: "\n")
//        var branchSet:Set<String> = []
//        for branch in branchContents.enumerated() {
//            var branchContent = branch.element
//            if branchContent.contains("remotes/origin"), let last = branchContent.components(separatedBy: "/").last {
//               branchContent = last
//            }
//            branchContent = filterBranchContent(branchContent)
//            if branchContent.count > 0 {
//                branchSet.insert(branchContent)
//            }
//        }
//        for branch in try localBranchs().enumerated() {
//            let branchContent = filterBranchContent(branch.element)
//            if branchContent.count > 0 {
//                branchSet.insert(branchContent)
//            }
//        }
//        var branchList = Array(branchSet)
//        branchList = branchList.sorted()
//        let chooseBranch = choose("请选择对应的分支\n".f.Blue, type: String.self) { (setting) in
//            for set in branchList.enumerated() {
//                setting.addChoice(set.element) { () -> String in
//                    return set.element
//                }
//            }
//        }
//        let localBranch = "\(branchsPath())/\(chooseBranch)"
//        if !FileManager.default.fileExists(atPath: localBranch) {
//            try createPath(localBranch)
//            main.currentdirectory = "\(localBranch)"
//            try runAndPrint("git", "clone", Configuration.gitSource)
//            main.currentdirectory = "\(localBranch)/\(projectPath)"
//            try runAndPrint("git", "checkout", chooseBranch)
//        }
//        guard let workSpacePath = workSpacePath(local: "\(localBranch)/\(projectPath)") else {
//            throw OpenBranchError.message(".xcodeproj or .xcworkspace not exit")
//        }
//        try runAndPrint("open", workSpacePath, "-a", "Xcode")
//    }
//    
//    func workSpacePath(local:String) -> String? {
//        if let path = local.components(separatedBy: ".").last, path == "xcodeproj", !local.contains(".swiftpm") {
//            let xcworkspance = local.replacingOccurrences(of: "xcodeproj", with: "xcworkspace")
//            if FileManager.default.fileExists(atPath: xcworkspance) {
//                return xcworkspance
//            }
//            return local
//        }
//        var isDirectory:ObjCBool = ObjCBool(false)
//        guard FileManager.default.fileExists(atPath: local, isDirectory: &isDirectory) else {
//            return nil
//        }
//        if isDirectory.boolValue {
//            guard let contents:[String] = try? FileManager.default.contentsOfDirectory(atPath: local) else {
//                return nil
//            }
//            var file:String?
//            for item in contents {
//                let itemPath = "\(local)/\(item)"
//                if let path = workSpacePath(local: itemPath) {
//                    file = path
//                    break
//                }
//            }
//            return file
//        } else {
//            return nil
//        }
//    }
//    
//    func filterBranchContent(_ content:String) -> String {
//        if content.contains("* ") {
//            return content.replacingOccurrences(of: "* ", with: "")
//        }
//        if content.contains(".DS_Store") {
//            return ""
//        }
//        return content
//    }
//    
//    func localBranchs() throws -> [String] {
//        return try FileManager.default.contentsOfDirectory(atPath: branchsPath())
//    }
//}

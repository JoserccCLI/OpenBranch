//
//  OpenBranch.swift
//  
//
//  Created by 张行 on 2019/12/27.
//

import Foundation
import Swiftline
import SwiftShell

var projectPath:String = ""


struct OpenBranch {
    let sdk:Bool
    func open() throws {
        try self.setup()
        main.currentdirectory = "\(sourcePath())/\(projectPath)"
        try runAndPrint("git", "reset", "--hard")
        try runAndPrint("git", "pull", "origin")
        let branchsString = run("git", "branch", "-a").stdout
        let branchContents = branchsString .components(separatedBy: "\n")
        var branchSet:Set<String> = []
        for branch in branchContents.enumerated() {
            var branchContent = branch.element
            if branchContent.contains("remotes/origin"), let last = branchContent.components(separatedBy: "/").last {
               branchContent = last
            }
            branchContent = filterBranchContent(branchContent)
            if branchContent.count > 0 {
                branchSet.insert(branchContent)
            }
        }
        for branch in try localBranchs().enumerated() {
            let branchContent = filterBranchContent(branch.element)
            if branchContent.count > 0 {
                branchSet.insert(branchContent)
            }
        }
        var branchList = Array(branchSet)
        branchList = branchList.sorted()
        let chooseBranch = choose("请选择对应的分支\n".f.Blue, type: String.self) { (setting) in
            for set in branchList.enumerated() {
                setting.addChoice(set.element) { () -> String in
                    return set.element
                }
            }
        }
        let localBranch = "\(branchsPath())/\(chooseBranch)"
        if !FileManager.default.fileExists(atPath: localBranch) {
            try createPath(localBranch)
            main.currentdirectory = "\(localBranch)"
            try runAndPrint("git", "clone", Configuration.gitSource)
            main.currentdirectory = "\(localBranch)/\(projectPath)"
            try runAndPrint("git", "checkout", chooseBranch)
        }
        guard let workSpacePath = workSpacePath(local: "\(localBranch)/\(projectPath)") else {
            assert(false)
        }
        try runAndPrint("open", workSpacePath, "-a", "Xcode")
    }
    
    func workSpacePath(local:String) -> String? {
        if let path = local.components(separatedBy: ".").last, path == "xcodeproj", !local.contains(".swiftpm") {
            let xcworkspance = local.replacingOccurrences(of: "xcodeproj", with: "xcworkspace")
            if FileManager.default.fileExists(atPath: xcworkspance) {
                return xcworkspance
            }
            return local
        }
        var isDirectory:ObjCBool = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: local, isDirectory: &isDirectory) else {
            return nil
        }
        if isDirectory.boolValue {
            guard let contents:[String] = try? FileManager.default.contentsOfDirectory(atPath: local) else {
                return nil
            }
            var file:String?
            for item in contents {
                let itemPath = "\(local)/\(item)"
                if let path = workSpacePath(local: itemPath) {
                    file = path
                    break
                }
            }
            return file
        } else {
            return nil
        }
    }
    
    func filterBranchContent(_ content:String) -> String {
        if content.contains("* ") {
            return content.replacingOccurrences(of: "* ", with: "")
        }
        if content.contains(".DS_Store") {
            return ""
        }
        return content
    }
    
    func setup() throws {
        if Configuration.gitSource.count == 0 {
            let url = ask("Please enter the project Git repository address".f.Blue)
            assert(url.contains(".git") && url.contains("ssh://"), "请输入ssh://前缀.git后缀的地址")
            Configuration.gitSource = url
        }
        guard let urlComponment = URLComponents(string: "ssh://git@pineal.ai:30001/pineal-ios/pineal.git") else {
            assert(false)
        }
        let urlPath = urlComponment.path
        guard let lastPath = urlPath.components(separatedBy: "/").last else {
            assert(false)
        }
        /// 获取到工程名称
        projectPath = lastPath.replacingOccurrences(of: ".git", with: "")
        try createPath(projectCachePath())
        try createPath("\(projectCachePath())/\(projectPath)")
        try createPath(branchsPath())
        try createPath(sourcePath())
        main.currentdirectory = sourcePath()
        if !FileManager.default.fileExists(atPath: "\(sourcePath())/\(projectPath)") {
            try runAndPrint("git", "clone", Configuration.gitSource, "--verbose")
        }
    }
    
    func user() -> String {
        return main.env["USER"] ?? ""
    }
    
    func projectCachePath() -> String {
        return "/Users/\(user())/Library/Caches/OpenBranch"
    }
    
    func branchsPath() -> String {
        return "\(projectCachePath())/\(projectPath)/Branchs"
    }
    
    func sourcePath() -> String {
        return "\(projectCachePath())/\(projectPath)/Source"
    }
    
    func createPath(_ path:String) throws {
        guard !FileManager.default.fileExists(atPath: path) else {
            return
        }
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    func localBranchs() throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: branchsPath())
    }
}

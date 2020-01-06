//
//  OpenBranch.swift
//  
//
//  Created by 张行 on 2019/12/27.
//

import Foundation
import Swiftline
import SwiftShell


struct OpenBranch {
    let sdk:Bool
    func open() throws {
        try self.setup()
        main.currentdirectory = sourcePath()
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
            main.currentdirectory = localBranch
            try runAndPrint("git", "clone", Configuration.gitSource)
        }
        let workSpacePath:String
        if !self.sdk {
            workSpacePath = "\(localBranch)/GearBest2.6.0_9287/GearBest/GearBest.xcworkspace"
        } else {
            workSpacePath = "\(localBranch)/GearBest2.6.0_9287/GearBest/PrivatePods/PodLib/GGPaySDK/GGPaySDK-developer/GGPaySDK-developer.xcworkspace"
        }
        try runAndPrint("open", workSpacePath, "-a", "Xcode")
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
        if FileManager.default.fileExists(atPath: "\(gearbestPath())/GearBest2.6.0_9287") {
            return
        }
        print("First run? Please perform initial configuration".f.Red)
        let url = ask("Please enter the project Git repository address".f.Blue)
        Configuration.gitSource = url
        try createPath(gearbestPath())
        try createPath(branchsPath())
        main.currentdirectory = gearbestPath()
        try runAndPrint("git", "clone", url, "--verbose")
    }
    
    func user() -> String {
        return main.env["USER"] ?? ""
    }
    
    func gearbestPath() -> String {
        return "/Users/\(user())/Library/Caches/GearBest"
    }
    
    func branchsPath() -> String {
        return "\(gearbestPath())/Branchs"
    }
    
    func sourcePath() -> String {
        return "\(gearbestPath())/GearBest2.6.0_9287"
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

import Foundation
import ArgumentParser
import SwiftShell

struct OpenBranch:ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(commandName:"openb", subcommands:[Add.self, Remove.self])
    func run() throws {
        let configurations = ConfigurationManager.manager.get()
        guard configurations.count > 0 else {
            print("未发现任何配置,请先运行[openb add]命令进行添加一个配置")
            throw ExitCode.failure
        }
        print("请选择一个项目输入对应数字")
        for element in configurations.enumerated() {
            print("\(element.offset)")
            print("- url: \(element.element.sourceURL)")
            print("- name: \(element.element.name)")
        }

        guard let readline = readLine(strippingNewline: true), let index = Int(readline), index >= 0, index < configurations.count else {
            print("必须输入[0..<\(configurations.count)]之间的数字")
            throw ExitCode.failure
        }
        let configuration = configurations[index]
        let cachePath = try cachePath()
        let openBranchPath = "\(cachePath)/OpenBranch"
        if !Directory(path: openBranchPath).isExit {
            try Directory(path: openBranchPath).create()
        }
        let projectNamePath = "\(openBranchPath)/\(configuration.name)"
        if !Directory(path: projectNamePath).isExit {
            try Directory(path: projectNamePath).create()
        }
        let HEADBranchPath = "\(projectNamePath)/HEAD"
        if !Directory(path: HEADBranchPath).isExit {
            SwiftShell.main.currentdirectory = projectNamePath
            try runAndPrint("git", "clone", configuration.sourceURL, "HEAD")
        } else {
            SwiftShell.main.currentdirectory = HEADBranchPath
            try runAndPrint("git", "reset", "--hard")
            try runAndPrint("git", "pull", "--ff-only")
        }
        if SwiftShell.main.currentdirectory != HEADBranchPath {
            SwiftShell.main.currentdirectory = HEADBranchPath
        }
        /// 删除远程已经不存在的分支
        try SwiftShell.runAndPrint("git", "remote","prune","origin")
        let allBranch:[String] = SwiftShell.run("git", "branch", "-a").stdout.components(separatedBy: "\n").compactMap({ element in
            let paths = element.components(separatedBy: "/")
            guard paths.count == 3 else {
                return nil
            }
            return paths.last
        })
        print("请输入分支序号")
        for element in allBranch.enumerated() {
            print("\(element.offset): \(element.element)")
        }
        guard let readline = readLine(strippingNewline: true), let index = Int(readline), index >= 0, index < allBranch.count else {
            throw CleanExit.message("\(index)必须在[0..<\(allBranch.count)]之间")
        }
        let branchName = allBranch[index]
        let branchPath = "\(projectNamePath)/\(branchName)"
        var isFromInit:Bool = false
        if !Directory(path: branchPath).isExit {
            isFromInit = true
            SwiftShell.main.currentdirectory = projectNamePath
            try runAndPrint("git", "clone", configuration.sourceURL, branchName)
            SwiftShell.main.currentdirectory = branchPath
            try runAndPrint("git", "checkout", branchName)
        }
        let shellFile = "\(branchPath)/open_branch.sh"
        if !FileManager.default.fileExists(atPath: shellFile) {
            throw CleanExit.message("\(shellFile)文件不存在")
        }
        if SwiftShell.main.currentdirectory != branchPath {
            SwiftShell.main.currentdirectory = branchPath
        }
        try runAndPrint("sh", shellFile, isFromInit)
    }
    
    func cachePath() throws -> String {
        guard let home = ProcessInfo.processInfo.environment["HOME"] else {
            throw CleanExit.message("$HOME 变量不存在")
        }
        return "\(home)/Library/Caches"
    }
    
    
}

OpenBranch.main()


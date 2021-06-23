//
//  Add.swift
//  
//
//  Created by joser on 2021/6/18.
//

import ArgumentParser
import Foundation
struct Add: ParsableCommand {
    func run() throws {
        print("请输入项目SSH地址")
        guard let sshURL = readLine(), sshURL.count > 0 else {
            throw CleanExit.message("没有输入任何文本")
        }
        guard sshURL.contains("git@"), sshURL.contains(".git") else {
            throw CleanExit.message("\(sshURL)不是一个合法的SSH地址")
        }
        let name = inputName()
        var configurations = ConfigurationManager.manager.get()
        configurations.append(.init(sourceURL: sshURL, name: name))
        try ConfigurationManager.manager.set(configurations: configurations)
    }
    
    func inputName() -> String {
        print("请输入项目名称（必须设置英文名称 不允许有空格）")
        guard let name = readLine(), name.count != 0 else {
            print("项目名称不允许为空")
            return inputName()
        }
        guard ConfigurationManager.manager.get().first(where: {$0.name == name}) == nil else {
            print("\(name)已经存在")
            return inputName()
        }
        return name
    }
}

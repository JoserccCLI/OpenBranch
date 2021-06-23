//
//  Remove.swift
//  
//
//  Created by joser on 2021/6/23.
//

import Foundation
import ArgumentParser

struct Remove: ParsableCommand {
    func run() throws {
        var configurations = ConfigurationManager.manager.get()
        guard configurations.count > 0 else {
            throw CleanExit.message("不存在任何配置")
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
        configurations.remove(at: index)
        try ConfigurationManager.manager.set(configurations: configurations)
    }
}

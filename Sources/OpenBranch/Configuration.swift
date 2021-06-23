//
//  Configuration.swift
//  
//
//  Created by 张行 on 2019/12/27.
//

import Foundation
/// 工程配置
struct Configuration: Codable {
    let sourceURL:String
    let name:String
}

class ConfigurationManager {
    @UserDefaultValue(key: "open_branch_configuration")
    var data:Data?
    static let manager = ConfigurationManager()
    
    func get() -> [Configuration] {
        guard let data = self.data,
              let configurations = try? JSONDecoder().decode([Configuration].self, from: data) else {
            return []
        }
        return configurations
    }
    
    func set(configurations:[Configuration]) throws {
        let data = try JSONEncoder().encode(configurations)
        self.data = data
    }
}

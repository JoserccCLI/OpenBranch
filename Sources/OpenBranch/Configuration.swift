//
//  Configuration.swift
//  
//
//  Created by 张行 on 2019/12/27.
//

import Foundation

struct Configuration {
    static var gitSource:String {
        get {
            UserDefaults.standard.string(forKey: "gitSource") ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: "gitSource")
            UserDefaults.standard.synchronize()
        }
    }
    static var isInitSuccess:Bool {
        get {
            UserDefaults.standard.bool(forKey: "isInitSuccess")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isInitSuccess")
            UserDefaults.standard.synchronize()
        }
    }
}

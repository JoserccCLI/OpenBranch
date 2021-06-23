//
//  UserDefaultValue.swift
//  
//
//  Created by joser on 2021/6/22.
//

import Foundation

@propertyWrapper
struct UserDefaultValue<T:Any> {
    let key:String
    init(key:String) {
        self.key = key
    }
    var wrappedValue:T? {
        get {
            return UserDefaults.standard.object(forKey:self.key) as? T
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: self.key)
        }
    }
}


//
//  defaultsDatabse.swift
//  BluIDSDK
//
//  Created by developer on 16/06/21.
//

import Foundation
import BluIDSDK
protocol UserDefaultsDBProtocol {
    func saveData<T: Codable>(_ data:T)
    func removeData()
    func readData<T: Codable>()->T?
}
class UserDefaultsDBInterface:UserDefaultsDBProtocol {
    var m_defaults: UserDefaults
    var m_dbKey:String
    
    init(dbKey:String) {
        m_defaults = UserDefaults.standard
        self.m_dbKey = dbKey
    }
    
    func saveData<T: Codable>(_ data:T){
        let encoder = JSONEncoder()
        if let encodedData:Data = try? encoder.encode(data) {
            m_defaults.set(encodedData, forKey: m_dbKey)
        }
    }
    func removeData(){
        m_defaults.removeObject(forKey: m_dbKey)
    }
    func readData<T: Codable>()->T?{
        guard let data:Data = (m_defaults.object(forKey: m_dbKey) as? Data) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }catch{
            print(error)
            return nil
        }
    }
}

class UserLoginDB:UserDefaultsDBInterface {
    init() {
        super.init(dbKey: "BluIDSDK_SampleApp")
    }
    
    func save(userDetails:UserLoginDetails){
        saveData(userDetails)
    }
    
    func getUserDetails() -> UserLoginDetails? {
        return readData()
    }
    
    func clear() {
        removeData()
    }
}

class AutoTransferSettings: UserDefaultsDBInterface {
    init() {
        super.init(dbKey: "BluIDSDK_SampleApp_AutoTransfer")
    }
    
    func save(on:Bool){
        saveData(on)
    }
    
    func isOn() -> Bool {
        return readData() ?? false
    }
    
    func clear() {
        removeData()
    }
}

class BluIDSDKEnvironmentDB:UserDefaultsDBInterface {
    init() {
        super.init(dbKey: "BluIDSDK_SampleApp_Environment")
    }
    func save(env:BluIDSDK_Environment){
        saveData(env)
    }
    
    func getEnvironment() -> BluIDSDK_Environment {
        return readData() ?? .production
    }
    
    func clear() {
        removeData()
    }
}

//
//  user_login_details.swift
//  BluIDSDK Sample App
//
//  Created by Akhil Kumar on 08/07/21.
//

import Foundation

class UserLoginDetails:Codable {
    let userName:String
    let password:String
    let remember:Bool
    
    init(userName:String, password:String, remember:Bool) {
        self.userName = userName
        self.password = password
        self.remember = remember
    }
}

enum BleRole{
    case Login
    case Scan
    case AutoTransfer
}

//
//  allow_modes.swift
//  BluIDSDK Sample App
//
//  Created by Akhil Kumar on 15/07/21.
//

import Foundation
import BluIDSDK

extension AllowAccessType {
    func toString()->String{
        switch self {
        case .phoneUnlocked:
            return "Phone unlocked"
        case .always:
            return "Always"
        default:
            return "Foreground"
        }
    }
    
    func toEnum(_ accessText: String) -> AllowAccessType{
        switch accessText {
        case "Phone unlocked":
            return .phoneUnlocked
        case "Always":
            return .always
        default:
            return .foreground
        }
    }
}

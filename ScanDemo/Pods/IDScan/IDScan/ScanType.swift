//
//  ScanType.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/18/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit

public enum ScanType {
    case frontLicense, backLicense, passport
    
    var docType: String {
        switch self {
        case .frontLicense, .backLicense: return "driverLicense"
        case .passport:                   return "passport"
        }
    }
    
    var instructions: String {
        switch self {
        case .frontLicense: return "Scan front of ID"
        case .backLicense:  return "Scan back of ID"
        case .passport:     return "Scan passport"
        }
    }
    
    var docHeightRatio: CGFloat {
        switch self {
        case .frontLicense, .backLicense: return 3/2
        case .passport:                   return 4.921/3.456
        }
    }
}

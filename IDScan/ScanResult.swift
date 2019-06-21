//
//  ScanResult.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/19/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit

public struct ScanResult {
    public let docType: String
    public let frontImage: UIImage?
    public let backImage: UIImage?
    public let frontImageJpegDataString: String?
    public let backImageJpegDataString: String?
}

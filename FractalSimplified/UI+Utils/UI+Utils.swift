//
//  UI+Utils.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var error: UIColor {
        return UIColor(hex: 0xf62459)
    }
    
    static var primary: UIColor {
        return UIColor(hex: 0x5856d6)
    }
    
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((hex & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat((hex & 0x0000FF) >> 0) / 0xFF
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

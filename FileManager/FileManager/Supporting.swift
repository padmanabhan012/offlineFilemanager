//
//  Supporting.swift
//  FileManager
//
//  Created by Rahul P John on 19/01/25.
//

import UIKit

extension UIColor {
    
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            
            let redInt = Int(red * 255)
            let greenInt = Int(green * 255)
            let blueInt = Int(blue * 255)
            
            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        }
        return nil
    }
    
    convenience init?(hex: String) {
        
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        guard hexSanitized.count == 6 || hexSanitized.count == 8 else {
            return nil
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        let alpha: CGFloat
        if hexSanitized.count == 8 {
            alpha = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
        } else {
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

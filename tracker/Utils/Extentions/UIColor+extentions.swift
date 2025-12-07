//
//  UIColor+extentions.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 02.12.2025.
//

import UIKit

extension UIColor {
    var hexString: String? {
        guard let components = self.cgColor.components else { return nil }

        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
    
    static func color(from hex: String) -> UIColor {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
            )
    }
}

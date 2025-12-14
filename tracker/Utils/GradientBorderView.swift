//
//  GradientView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 13.12.2025.
//

import UIKit

final class GradientBorderView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true

        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)

        
        gradientLayer.colors = [
            UIColor.systemGreen.cgColor,
            UIColor.systemRed.cgColor,
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemGreen.cgColor,
        ]
        gradientLayer.locations = [0.00, 0.14, 0.36, 0.50, 0.64, 0.86, 1.00] as [NSNumber]
        layer.addSublayer(gradientLayer)

        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: 16)
        shapeLayer.path = path.cgPath
    }
}

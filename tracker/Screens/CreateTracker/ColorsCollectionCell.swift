//
//  ColorCell.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 18.10.2025.
//
import UIKit

class ColorsCollectionCell: UICollectionViewCell {
    private lazy var selectedBackground: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(selectedBackground)
        contentView.addSubview(colorView)
        
        setupConstraints()
        
        // layer.cornerRadius = 8
    }
    
    private func setupConstraints() {
        
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        backgroundColor = UIColor(named: colorName)
        if isSelected {
            
        } else {
            
        }
    }
}

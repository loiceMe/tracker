//
//  ColorCell.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 18.10.2025.
//
import UIKit

class ColorsCollectionCell: UICollectionViewCell {
    private lazy var selectedBackground = UIView()
    private lazy var colorView = UIView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        selectedBackground.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedBackground)
        contentView.addSubview(colorView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
        
        selectedBackground.layer.cornerRadius = 10
        colorView.layer.cornerRadius = 8
        selectedBackground.layer.borderWidth = 3
        selectedBackground.alpha = 0.3
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            
            selectedBackground.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectedBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectedBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            colorView.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: selectedBackground.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: selectedBackground.trailingAnchor, constant: -6),
        ])
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        colorView.backgroundColor = UIColor(named: colorName)
        if isSelected {
            selectedBackground.layer.borderColor = UIColor(named: colorName)?.withAlphaComponent(0.7).cgColor
        } else {
            selectedBackground.layer.borderColor = UIColor.white.cgColor
        }
    }
}

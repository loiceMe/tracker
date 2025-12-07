//
//  EmojiCell.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 18.10.2025.
//
import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    private lazy var emojiLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.layer.cornerRadius = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiLabel)
        setupConstraints()
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? UIColor(named: "Light Gray") : UIColor.white
    }
}


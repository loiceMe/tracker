//
//  EmojiCell.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 18.10.2025.
//
import UIKit

class EmojiCollectionCell: UICollectionViewCell {
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
        
        addSubview(emojiLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        if isSelected {
            
        } else {
            
        }
    }
}


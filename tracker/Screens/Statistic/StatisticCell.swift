//
//  StatisticCellView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 13.12.2025.
//

import UIKit

final class StatisticCell: UITableViewCell {
    static let identifier = "StatisticCell"
    
    private lazy var valueLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "6"
        
        return label
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .ypBlack
        label.text = "Лучший период"
        
        return label
    }()
    
    private lazy var gradientBorder = {
        let view = GradientBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        view.addSubview(valueLabel)
        view.addSubview(titleLabel)
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
    }
    
    func configure(title: String, value: Int) {
        titleLabel.text = title
        valueLabel.text = "\(value)"
    }
    
    private func configure() {
        gradientBorder.backgroundColor = .ypWhite
        backgroundColor = .ypWhite
        contentView.addSubview(gradientBorder)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            gradientBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: gradientBorder.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: gradientBorder.topAnchor, constant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: gradientBorder.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 15),
            titleLabel.bottomAnchor.constraint(equalTo: gradientBorder.bottomAnchor, constant: -12),
        ])
    }
}

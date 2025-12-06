//
//  TrackerCell.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 18.11.2025.
//
import UIKit

final class TrackerCell: UICollectionViewCell {
    // - MARK: Elements
    static let reuseIdentifier = "trackerCell"
    
    var addDay: (() -> Void)?
    
    private lazy var emojiBackground = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(named: "Emoji Background")
        view.addSubview(emojiLabel)
        return view
    }()
    
    private lazy var emojiLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "😪"
        return label
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Поливать цветы"
        return label
    }()
    
    private lazy var daysCounterLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    private lazy var addDayButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = .white
        return button
    }()
    
    private lazy var topView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor(named: "Color selection 18")
        view.addSubview(emojiBackground)
        view.addSubview(titleLabel)
        return view
    }()
    
    private lazy var bottomView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(daysCounterLabel)
        view.addSubview(addDayButton)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(tracker: Tracker, isCompleted: Bool, count: Int) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        topView.backgroundColor = tracker.color
        let iconName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(
            systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        daysCounterLabel.text = "\(count) \(pluralizeDay(count))"
        addDayButton.setImage(image, for: .normal)
        addDayButton.tintColor = .white
        addDayButton.backgroundColor =  tracker.color
        addDayButton.addTarget(self, action: #selector(addDayButtonTapped), for: .touchUpInside)
        addDayButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
    }
    
    private func configure() {
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiBackground.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiBackground.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            titleLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -12),
            
            daysCounterLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            daysCounterLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -24),
            daysCounterLabel.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 12),
            
            addDayButton.centerYAnchor.constraint(equalTo: daysCounterLabel.centerYAnchor),
            addDayButton.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -12),
            addDayButton.widthAnchor.constraint(equalToConstant: 34),
            addDayButton.heightAnchor.constraint(equalToConstant: 34),
            
            topView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            topView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            topView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            topView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: 0),
            
            bottomView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            bottomView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
    }
    
    private func pluralizeDay(_ count: Int) -> String {
        let rem10 = count % 10
        let rem100 = count % 100
        if rem100 >= 11 && rem100 <= 14 { return "дней" }
        switch rem10 {
            case 1: return "день"
            case 2...4: return "дня"
            default: return "дней"
        }
    }
    
    @objc
    func addDayButtonTapped() {
        addDay?()
    }
}

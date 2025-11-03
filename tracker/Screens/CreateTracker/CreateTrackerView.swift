//
//  CreateTrackerView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 01.10.2025.
//
import UIKit

class CreateTrackerView: UIViewController {
    
    // - MARK: UI Elements
    
    private lazy var nameTextField = {
        let textField = UITextField()
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: "Background")
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = padding
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var separator = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Grey")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    private lazy var parametersView = {
        let view = UIView()
        
        view.addSubview(selectCategoryButton)
        view.addSubview(separator)
        view.addSubview(setScheduleButton)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "Background")
        
        return view
    }()
    
    private lazy var selectCategoryButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Категория", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor(named: "Black"), for: .normal)
        
        let detailTextLabel = UILabel()
        detailTextLabel.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel.textColor = UIColor(named: "Grey")
        detailTextLabel.text = "Важное"
        
        button.addSubview(detailTextLabel)
        
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        button.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -6).isActive = true
        imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        imageView.tintColor = UIColor(named: "Grey")
        
        button.titleLabel?.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        button.contentHorizontalAlignment = .fill

        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var setScheduleButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Расписание", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor(named: "Black"), for: .normal)
        
        let detailTextLabel = UILabel()
        detailTextLabel.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel.textColor = UIColor(named: "Grey")
        detailTextLabel.text = "Расписание"
        
        button.addSubview(detailTextLabel)
        
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        button.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -6).isActive = true
        imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        imageView.tintColor = UIColor(named: "Grey")
        
        button.titleLabel?.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(setScheduleTapped), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var cancelCreateTracker = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = UIColor(named: "White")
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor(named: "Red")?.cgColor
        button.layer.borderWidth = 1
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createTrackerButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = UIColor(named: "Grey")
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }()
    
    // - MARK: Stacks

    private lazy var rootStack = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [nameTextField, parametersView, spacer, buttonsStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private lazy var buttonsStack = {
        let stack = UIStackView(arrangedSubviews: [cancelCreateTracker, createTrackerButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.backgroundColor = UIColor(named: "White")
        navigationItem.title = "Новая привычка"
        view.addSubview(rootStack)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            rootStack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -34),
            rootStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            nameTextField.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            parametersView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            parametersView.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
            selectCategoryButton.heightAnchor.constraint(equalToConstant: 75),
            setScheduleButton.heightAnchor.constraint(equalToConstant: 75),
            selectCategoryButton.widthAnchor.constraint(equalTo: parametersView.widthAnchor, constant: -32),
            selectCategoryButton.centerXAnchor.constraint(equalTo: parametersView.centerXAnchor),
            selectCategoryButton.topAnchor.constraint(equalTo: parametersView.topAnchor),
            separator.widthAnchor.constraint(equalTo: parametersView.widthAnchor, constant: -32),
            separator.centerXAnchor.constraint(equalTo: parametersView.centerXAnchor),
            separator.topAnchor.constraint(equalTo: selectCategoryButton.bottomAnchor),
            setScheduleButton.centerXAnchor.constraint(equalTo: parametersView.centerXAnchor),
            setScheduleButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            setScheduleButton.bottomAnchor.constraint(equalTo: parametersView.bottomAnchor),
            setScheduleButton.widthAnchor.constraint(equalTo: parametersView.widthAnchor, constant: -32),
        ])
    }
    
    @objc
    private func setScheduleTapped() {
        let createVC = ScheduleView()
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc
    private func cancelTapped() {
        dismiss(animated: true)
    }
}

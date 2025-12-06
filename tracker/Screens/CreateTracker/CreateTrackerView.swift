//
//  CreateTrackerView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 01.10.2025.
//
import UIKit

protocol CreateTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

class CreateTrackerView: UIViewController {
    
    weak var createViewDelegate: CreateTrackerDelegate?
    
    // - MARK: New tracker props
    
    private var trackerTitle = ""
    private var trackerCategory: TrackerCategory? {
        didSet {
            selectCategoryButton.configuration?.subtitle = trackerCategory?.title
            updateCreateButton()
        }
    }
    private var trackerSchedule = [Int]() {
        didSet {
            if (trackerSchedule.count == 7) {
                setScheduleButton.configuration?.subtitle = "Каждый день"
            } else {
                setScheduleButton.configuration?.subtitle = WeekDay.allCases.filter({ weekDay in
                    return trackerSchedule.contains(weekDay.number)
                }).map{ $0.shortName }
                .joined(separator: ", ")
            }
            updateCreateButton()
            
        }
    }
    
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
        
        textField.addTarget(self, action: #selector(didNameEdit(_:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var separator = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Gray")
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
        let button = getButton()
        button.configuration?.attributedTitle = .init("Категория",
                                                      attributes: AttributeContainer()
                           .font(UIFont.systemFont(ofSize: 17))
                           .foregroundColor(UIColor(named: "Black") ?? UIColor.black))
        // button.addTarget(self, action: #selector(setCategoryTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var setScheduleButton = {
        let button = getButton()
        
        button.configuration?.attributedTitle = .init("Расписание",
                                                      attributes: AttributeContainer()
                           .font(UIFont.systemFont(ofSize: 17))
                           .foregroundColor(UIColor(named: "Black") ?? UIColor.black))
        button.addTarget(self, action: #selector(setScheduleTapped), for: .touchUpInside)

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
        button.backgroundColor = UIColor(named: "Gray")
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
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
        stack.spacing = 24
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
        self.hideKeyboardWhenTappedAround()
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
    
    private func getButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        let image = UIImage(named: "Chevron")
        config.image = image
        config.imagePlacement = .trailing
        config.titleAlignment = .leading
        config.baseForegroundColor = UIColor(named: "Gray")
        config.attributedSubtitle = .init("",
                                       attributes: AttributeContainer()
            .font(UIFont.systemFont(ofSize: 17))
            .foregroundColor(UIColor(named: "Gray") ?? UIColor.black))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.buttonSize = .large
        config.imagePadding = 16
        
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .fill
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    private func updateCreateButton() {
        // if trackerTitle != "" && trackerCategory != nil && trackerSchedule.count > 0 {
        if trackerTitle != "" && trackerSchedule.count > 0 {
            createTrackerButton.isEnabled = true
            createTrackerButton.backgroundColor = UIColor(named: "Black")
        } else {
            createTrackerButton.isEnabled = false
            createTrackerButton.backgroundColor = UIColor(named: "Gray")
        }
    }
    
    @objc
    private func setScheduleTapped() {
        let scheduleVC = ScheduleView()
        scheduleVC.setScheduleDelegate = self
        scheduleVC.selectedDays = trackerSchedule
        let nav = UINavigationController(rootViewController: scheduleVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc
    private func setCategoryTapped() {
        let scheduleVC = CategoriesView()
        scheduleVC.setCategoryDelegate = self
        
        let nav = UINavigationController(rootViewController: scheduleVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc
    private func didTapCreate() {
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: UIColor(named: "Color selection \(Int.random(in: 1..<18))") ?? .gray,
                              emoji: "🤏",
                              schedule: trackerSchedule)
        createViewDelegate?.didCreateTracker(tracker)
        dismiss(animated: true)
    }
    
    @objc
    private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func didNameEdit(_ textField: UITextField) {
        trackerTitle = textField.text ?? ""
        updateCreateButton()
    }
}

extension CreateTrackerView: SetScheduleDelegate {
    func onSetSchedule(days: [Int]) {
        trackerSchedule = days
    }
}

extension CreateTrackerView: SetCategoryDelegate {
    func onSetCategory(category: TrackerCategory) {
        trackerCategory = category
    }
}

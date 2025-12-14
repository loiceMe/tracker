//
//  CreateTrackerView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 01.10.2025.
//
import UIKit

protocol CreateTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String?)
}

final class CreateTrackerView: UIViewController {
    weak var delegate: CreateTrackerDelegate?
    private let emojis = MockData.emojis
    
    weak var createViewDelegate: CreateTrackerDelegate?
    private var isAllowCreation: Bool {
        trackerTitle != "" && trackerSchedule.count > 0 && trackerEmoji != "" && trackerColor != "" && trackerCategory != nil
    }
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
    private var trackerEmoji = ""
    private var trackerColor = ""
    
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
        button.addTarget(self, action: #selector(setCategoryTapped), for: .touchUpInside)
        
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
    
    private lazy var emojisTitleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "  Emoji"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()
    
    private lazy var emojiCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2.5, bottom: 0, right: 2.5)
        let collection = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        return collection
    }()
    
    private lazy var colorsTitleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "  Цвет"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()
    
    private lazy var colorsCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collection = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
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
    
    private lazy var contentScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        return scrollView
    }()
    
    // - MARK: Stacks

    private lazy var contentStack = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [nameTextField, parametersView, emojisStack, colorsStack, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 36
        stack.setCustomSpacing(24.0, after: nameTextField)
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private lazy var emojisStack = {
        let stack = UIStackView(arrangedSubviews: [emojisTitleLabel, emojiCollection])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.setCustomSpacing(20.0, after: emojisTitleLabel)
        return stack
    }()
    
    private lazy var colorsStack = {
        let stack = UIStackView(arrangedSubviews: [colorsTitleLabel, colorsCollection])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.setCustomSpacing(20.0, after: colorsTitleLabel)
        colorsTitleLabel.layoutMargins = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
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
        view.addSubview(contentScrollView)
        view.addSubview(buttonsStack)
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        colorsCollection.dataSource = self
        colorsCollection.delegate = self

        emojiCollection.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "emojiCell")
        colorsCollection.register(ColorsCollectionCell.self, forCellWithReuseIdentifier: "colorCell")
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            
            contentStack.heightAnchor.constraint(greaterThanOrEqualTo: contentScrollView.heightAnchor),
            
            buttonsStack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonsStack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -34),
            
            nameTextField.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            parametersView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            parametersView.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
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
        if isAllowCreation {
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
        guard let categoriesStore = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(TrackerCategoryStore.self) else {
            return
        }
        let viewModel = CategoriesViewModel(store: categoriesStore)
        viewModel.setCategoryDelegate = self
        let categoriesView = CategoriesView(viewModel: viewModel)
        
        let nav = UINavigationController(rootViewController: categoriesView)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc
    private func didTapCreate() {
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: UIColor(named: trackerColor) ?? .white,
                              emoji: trackerEmoji,
                              schedule: trackerSchedule)
        delegate?.didCreateTracker(tracker, categoryTitle: trackerCategory?.title)
        createViewDelegate?.didCreateTracker(tracker, categoryTitle: trackerCategory?.title)
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
    func onSetCategory(category: TrackerCategory?) {
        trackerCategory = category
    }
}

extension CreateTrackerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let emoji = emojis[indexPath.row]
            let isSelected = emoji == trackerEmoji
            (cell as? EmojiCollectionCell)?.configure(with: emoji, isSelected: isSelected)
            return cell
        case colorsCollection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            let colorName = "Color selection \(indexPath.row + 1)"
            let isSelected = colorName == trackerColor
            (cell as? ColorsCollectionCell)?.configure(with: colorName, isSelected: isSelected)
            return cell
        default:
            break
        }
        
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension CreateTrackerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollection:
            trackerEmoji = emojis[indexPath.row]
            emojiCollection.reloadData()
            updateCreateButton()
        case colorsCollection:
            trackerColor = "Color selection \(indexPath.row + 1)"
            colorsCollection.reloadData()
            updateCreateButton()
        default:
            break
        }
    }
}

extension CreateTrackerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.bounds.width - 30) / 6
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5
    }
}

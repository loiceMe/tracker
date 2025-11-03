//
//  TrackersView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 07.09.2025.
//
import UIKit

final class TrackersView: UIViewController {
    
    private let datePicker = UIDatePicker()
    private let searchController = UISearchController(searchResultsController: nil)
    private var selectedDate: Date = Date()
    
    // - MARK: Elements
    
    private lazy var noTrackersImageView = {
        let imageView = UIImageView(image: UIImage(named: "Empty Trackers"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var noTrackersLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    // - MARK: Stacks
    
    private lazy var rootStack = {
        let stack = UIStackView(arrangedSubviews: [noTrackersView])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    private lazy var noTrackersView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        definesPresentationContext = true
        
        configureNavigationBar()
        configureSearchController()
        view.addSubview(rootStack)
        noTrackersView.addSubview(noTrackersImageView)
        noTrackersView.addSubview(noTrackersLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            noTrackersImageView.centerYAnchor.constraint(equalTo: noTrackersView.centerYAnchor, constant: -(18 + 8)),
            noTrackersImageView.centerXAnchor.constraint(equalTo: noTrackersView.centerXAnchor),
            
            noTrackersLabel.topAnchor.constraint(equalTo: noTrackersImageView.bottomAnchor, constant: 8),
            noTrackersLabel.centerXAnchor.constraint(equalTo: noTrackersImageView.centerXAnchor),
        ])
    }
    
    private func configureNavigationBar() {
        let addButton = UIButton(type: .system)
        var plusConfig = UIButton.Configuration.plain()
        plusConfig.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        plusConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        addButton.configuration = plusConfig
        addButton.tintColor = UIColor(named: "Black")
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addButton)
        
        configureDatePicker()
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = UIColor(named: "Black")
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.date = selectedDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchTextField.font = .systemFont(ofSize: 17, weight: .regular)
        searchController.searchBar.layer.cornerRadius = 10
        
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func updateVisibleCategoriesAndUI() {
        //visibleCategories = filterVisibleCategories(for: selectedDate)
        // collectionView.reloadData()
        // updateEmptyState()
        // scrollListToTopIfNeeded()
    }
    
    @objc
    private func addTrackerButtonTapped() {
        let createVC = CreateTrackerView()
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateVisibleCategoriesAndUI()
    }
}

extension TrackersView: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
//        let top = -collectionView.adjustedContentInset.top
//        if collectionView.contentOffset.y > top {
//            collectionView.setContentOffset(CGPoint(x: 0, y: top), animated: true)
//        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        let scrollToTop = { [weak self] in
            guard let self = self else { return }
            // let top = -self.collectionView.adjustedContentInset.top
//            self.collectionView.setContentOffset(CGPoint(x: 0, y: top), animated: false)
//            self.navigationController?.navigationBar.setNeedsLayout()
//            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        
        if let coordinator = navigationController?.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                scrollToTop()
            }, completion: { _ in
                scrollToTop()
            })
        } else {
            DispatchQueue.main.async { scrollToTop() }
        }
    }
}

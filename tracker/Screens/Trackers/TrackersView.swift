//
//  TrackersView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 07.09.2025.
//
import UIKit

final class TrackersView: UIViewController {
    let trackerCategoryStore = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(TrackerCategoryStore.self)
    let trackerRecordStore = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(TrackerRecordStore.self)
    let trackerStore = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(TrackerStore.self)
    
    private var completedTrackers: Set<TrackerRecord> = [] {
        didSet {
            trackersCollectionView.reloadData()
        }
    }
    
    var categories: [TrackerCategory] = [] {
        didSet {
            filterTrackers()
        }
    }
    
    private var filteredCategories: [TrackerCategory] = [] {
        didSet {
            toggleNoTrackers()
        }
    }
    
    private let datePicker = UIDatePicker()
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentDate: Date = Date() {
        didSet {
            filterTrackers()
        }
    }
    
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
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    // - MARK: Stacks
    
    private lazy var noTrackersView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noTrackersImageView)
        view.addSubview(noTrackersLabel)
        return view
    }()
    
    private lazy var trackersCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(TrackersSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        categories = (try? trackerCategoryStore?.fetchAll()) ?? []
        completedTrackers = Set((try? trackerRecordStore?.fetchAll()) ?? [])
    }
    
    private func configure() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        definesPresentationContext = true
        
        configureNavigationBar()
        configureSearchController()
        view.addSubview(noTrackersView)
        view.addSubview(trackersCollectionView)
        
        trackerStore?.delegate = self
        trackerCategoryStore?.delegate = self
        trackerRecordStore?.delegate = self
        
        trackerStore?.startObserving()
        trackerCategoryStore?.startObserving()
        trackerRecordStore?.startObserving()
        
        setupConstraints()
        toggleNoTrackers()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            noTrackersView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            noTrackersView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            noTrackersView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noTrackersView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
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
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.layer.cornerRadius = 10
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func toggleNoTrackers() {
        if filteredCategories.count > 0 {
            trackersCollectionView.isHidden = false
            noTrackersView.isHidden = true
        } else {
            noTrackersView.isHidden = false
            trackersCollectionView.isHidden = true
        }
    }
    
    private func filterTrackers() {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let day = calendar?.component(.weekday, from: currentDate as Date)
        
        let neededCategories = categories.filter { category in
            category.trackers.contains { tracker in
                return tracker.schedule.contains(day ?? 1)
            }
        }
        
        filteredCategories = neededCategories.map({ category in
            let filteredTrackers = category.trackers.filter({ tracker in
                return tracker.schedule.contains(day ?? 1)
            })
            return TrackerCategory(title: category.title,
                                   trackers: filteredTrackers)
        })

        trackersCollectionView.reloadData()
    }
    
    @objc
    private func addTrackerButtonTapped() {
        let createVC = CreateTrackerView()
        createVC.createViewDelegate = self
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
}

extension TrackersView: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String?) {
        try? trackerStore?.create(tracker, in: categoryTitle ?? "Без категории")
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
            guard self != nil else { return }
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

extension TrackersView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionViewLayout.collectionView?.layer.frame.width ?? 0) / 2) - 4
        let height = 148.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 32)
    }
}

extension TrackersView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCell
        else { return UICollectionViewCell() }
        
        let tracker   = filteredCategories[indexPath.section].trackers[indexPath.item]
        let startOfSelectedDay = Calendar.current.startOfDay(for: currentDate)
        let todayRecord = TrackerRecord(trackerId: tracker.id, date: startOfSelectedDay)
        let isCompleted = completedTrackers.contains(todayRecord)
        let completedCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.configureWith(tracker: tracker, isCompleted: isCompleted, count: completedCount)
        
        cell.addDay = { [weak self] in
            guard let self else { return }
            let record = TrackerRecord(trackerId: tracker.id, date: startOfSelectedDay)
            if Calendar.current.compare(
                self.currentDate,
                to: Date(),
                toGranularity: .day
            ) == .orderedDescending { return }

            if self.completedTrackers.contains(record) {
                try? trackerRecordStore?.delete(record)
            } else {
                try? trackerRecordStore?.add(record)
            }
            trackersCollectionView.reloadData()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryElement = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersSectionHeader.reuseIdentifier,
                for: indexPath
        ) as? TrackersSectionHeader else {
            return UICollectionReusableView()
        }
        
        supplementaryElement.titleLabel.text = filteredCategories[indexPath.section].title
        return supplementaryElement
    }
}

extension TrackersView: TrackerStoreDelegate {
    func trackerStoreDidChange(_ store: TrackerStore) {
        categories = (try? trackerCategoryStore?.fetchAll()) ?? []
        completedTrackers = Set((try? trackerRecordStore?.fetchAll()) ?? [])
    }
}

extension TrackersView: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore) {
        categories = (try? store.fetchAll()) ?? []
    }
}


extension TrackersView: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        completedTrackers = Set((try? store.fetchAll()) ?? [])
    }
}

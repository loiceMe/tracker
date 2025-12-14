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
    
    private let analytics = AnalyticsService()
    
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
    
    private var searchQuery = "" {
        didSet {
            filterTrackers()
        }
    }
    
    private let datePicker = UIDatePicker()
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentDate: Date = Date() {
        didSet {
            if !Calendar.current.isDateInToday(currentDate) && selectedFilter == .today {
                selectedFilter = .all
            } else {
                filterTrackers()
            }
        }
    }
    private var selectedFilter: TrackersFilter = .all {
        didSet {
            let filterButtonTitle = selectedFilter == .all ? 
                NSLocalizedString("filters", comment: "")
                : "\(NSLocalizedString("filters", comment: ""))(1)"
            
            filterButton.setTitle(filterButtonTitle,
                                  for: .normal)
            switch selectedFilter {
            case .all:
                filterTrackers()
                break
            case .completed:
                filterTrackers()
                break
            case .uncompleted:
                filterTrackers()
                break
            case .today:
                datePicker.setDate(Date.now, animated: false)
                currentDate = Date.now
                break
            }

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
        label.text = NSLocalizedString("what_will_track", comment: "")
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var filterButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.baseBackgroundColor = .ypBlue
        config.baseForegroundColor = .white
        config.title = NSLocalizedString("filters", comment: "")
        config.background.cornerRadius = 16
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
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
        collectionView.backgroundColor = .ypWhite
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(TrackersSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let collectionViewBottomInset: CGFloat = 60
        collectionView.contentInset.bottom = collectionViewBottomInset
        
        return collectionView
    }()
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        categories = (try? trackerCategoryStore?.fetchAll()) ?? []
        completedTrackers = Set((try? trackerRecordStore?.fetchAll()) ?? [])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report("open_trackers")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        report("close_trackers")
    }
    
    private func configure() {
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        definesPresentationContext = true
        
        configureNavigationBar()
        configureSearchController()
        view.addSubview(noTrackersView)
        view.addSubview(trackersCollectionView)
        view.addSubview(filterButton)
        
        trackerStore?.delegate = self
        trackerCategoryStore?.delegate = self
        trackerRecordStore?.delegate = self
        
        trackerStore?.startObserving()
        trackerCategoryStore?.startObserving()
        trackerRecordStore?.startObserving()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        trackersCollectionView.addGestureRecognizer(longPress)
        
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
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func configureNavigationBar() {
        let addButton = UIButton(type: .system)
        var plusConfig = UIButton.Configuration.plain()
        plusConfig.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        plusConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        addButton.configuration = plusConfig
        addButton.tintColor = .ypBlack
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addButton)
        
        configureDatePicker()
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .ypBlack
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search", comment: ""),
                                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypSecondaryText])
        searchController.searchBar.searchTextField.leftView?.tintColor = .ypSecondaryText
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchController.searchBar.layer.cornerRadius = 10
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.searchTextField.addTarget(self,
                                                             action: #selector(searchTextChanged(_:)),
                                                             for: .editingChanged)
        searchController.searchBar.searchTextField.delegate = self
    }
    
    private func toggleNoTrackers() {
        if filteredCategories.count > 0 {
            trackersCollectionView.isHidden = false
            noTrackersView.isHidden = true
        } else {
            let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if trimmedQuery.isEmpty && filterButton.isHidden {
                noTrackersLabel.text = NSLocalizedString("what_will_track", comment: "")
                noTrackersImageView.image = UIImage(named: "Empty Trackers")
            } else {                
                noTrackersLabel.text = NSLocalizedString("not_found", comment: "")
                noTrackersImageView.image = UIImage(named: "Not Found")
            }
            noTrackersView.isHidden = false
            trackersCollectionView.isHidden = true
        }
    }
    
    private func filterTrackers() {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let day = calendar?.component(.weekday, from: currentDate as Date)
        let startDate = Calendar.current.startOfDay(for: currentDate)
        
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hasQuery = !trimmedQuery.isEmpty
        
        let isNoTrackersForCurrentDate = categories.filter({ $0.trackers.contains { $0.schedule.contains(day ?? 1) }}).isEmpty
        filterButton.isHidden = isNoTrackersForCurrentDate
        
        
        let neededCategories = categories.filter { category in
            category.trackers.contains { tracker in
                var isNeed = tracker.schedule.contains(day ?? 1)
                if isNeed {
                    if selectedFilter == .completed {
                        isNeed = completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: startDate))
                    }
                    if selectedFilter == .uncompleted {
                        isNeed = !completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: startDate))
                    }
                    if hasQuery, !tracker.title.lowercased().contains(trimmedQuery) { isNeed = false }
                }
                return isNeed
            }
        }
        
        filteredCategories = neededCategories.map({ category in
            let filteredTrackers = category.trackers.filter({ tracker in
                var isNeed = tracker.schedule.contains(day ?? 1)
                if isNeed {
                    if selectedFilter == .completed {
                        isNeed = completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: startDate))
                    }
                    if selectedFilter == .uncompleted {
                        isNeed = !completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: startDate))
                    }
                    if hasQuery, !tracker.title.lowercased().contains(trimmedQuery) { isNeed = false }
                }
                return isNeed
            })
            return TrackerCategory(title: category.title,
                                   trackers: filteredTrackers)
        })

        trackersCollectionView.reloadData()
    }
    
    private func presentDeleteConfirmation(for tracker: Tracker) {
        let message = NSLocalizedString("delete_tracker_confirm", comment: "")
        
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(
            title: NSLocalizedString("delete_button", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            try? self.trackerRecordStore?.delete(by: tracker.id)
            try? self.trackerStore?.delete(tracker)
            self.categories = (try? self.trackerCategoryStore?.fetchAll()) ?? []
            self.completedTrackers = Set((try? self.trackerRecordStore?.fetchAll()) ?? [])
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString("cancel_button", comment: ""),
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func report(_ event: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": "Main"
        ]
        if let item { params["item"] = item }
        analytics.report(event: "ui_event", params: params)
        print("[ANALYTICS] \(params)")
    }
    
    @objc
    private func addTrackerButtonTapped() {
        report("click", item: "add_tracker")
        let createVC = TrackerView.init(mode: .create)
        createVC.createDelegate = self
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    @objc
    private func searchTextChanged(_ sender: UISearchTextField) {
        searchQuery = sender.text ?? ""
    }
    
    @objc
    private func filterButtonTapped() {
        report("click", item: "filter")
        let vc = FiltersView()
        vc.modalPresentationStyle = .formSheet
        vc.selectedFilter = selectedFilter
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc
    private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let point = gestureRecognizer.location(in: trackersCollectionView)
        guard let indexPath = trackersCollectionView.indexPathForItem(at: point) else { return }
        
        guard let cell = trackersCollectionView.cellForItem(at: indexPath) as? TrackerCell else { return }
        let frameInWindow = cell.topView.convert(cell.topView.bounds, to: nil)
        
        let snapshot = cell.topView.snapshotView(afterScreenUpdates: false)
        ?? cell.topView.resizableSnapshotView(from: cell.topView.bounds,
                                               afterScreenUpdates: false,
                                               withCapInsets: .zero)!
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let category = filteredCategories[indexPath.section]
        
        let menu = ContextMenuController.init(title: category.title,
                                              mode: .tracker,
                                              anchorFrameInWindow: frameInWindow,
                                              previewView: snapshot)
        
        menu.onEdit = { [weak self] in
            guard let self else { return }
            self.report("click", item: "edit_tracker")
            
            let editVC = TrackerView.init(mode: .edit)
            let completedCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
            editVC.configure(tracker: tracker, category: category, completedCount: completedCount)
            editVC.updateDelegate = self
            let nav = UINavigationController(rootViewController: editVC)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }
        
        menu.onDelete = { [weak self] in
            self?.report("click", item: "delete")
            self?.presentDeleteConfirmation(for: tracker)
        }
        
        present(menu, animated: false)
    }
}

extension TrackersView: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String?) {
        try? trackerStore?.create(tracker, in: categoryTitle ?? NSLocalizedString("uncategorized", comment: ""))
    }
}

extension TrackersView: UpdateTrackerDelegate {
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String?) {
        try? trackerStore?.update(tracker, toCategoryTitle: categoryTitle ?? NSLocalizedString("uncategorized", comment: ""))
    }
}

extension TrackersView: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {

    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        let scrollToTop = { [weak self] in
            guard self != nil else { return }
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

extension TrackersView: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchQuery = ""
        return true
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
            self.report("click", item: "tracker")
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
            filterTrackers()
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

extension TrackersView: FiltersViewDelegate {
    func onSetFilters(filter: TrackersFilter) {
        selectedFilter = filter
    }
}

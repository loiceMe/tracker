//
//  FiltersView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 13.12.2025.
//

import UIKit

protocol FiltersViewDelegate: AnyObject {
    func onSetFilters(filter: TrackersFilter)
}

final class FiltersView: UIViewController {
    var selectedFilter: TrackersFilter = .all
    weak var delegate: FiltersViewDelegate?
    
    // - MARK: Elements

    private lazy var filtersTable = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bouncesVertically = false
        tableView.showsVerticalScrollIndicator = false
        tableView.clipsToBounds = true
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        view.addSubview(filtersTable)
        
        navigationItem.title = "Фильтры"
        view.backgroundColor = .ypWhite
        
        filtersTable.dataSource = self
        filtersTable.delegate = self
        filtersTable.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filtersTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filtersTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func title(for filter: TrackersFilter) -> String {
        switch filter {
        case .all: return NSLocalizedString("all_trackers", comment: "Все трекеры")
        case .today: return NSLocalizedString("today_trackers", comment: "Трекеры на сегодня")
        case .completed: return NSLocalizedString("completed", comment: "Завершённые")
        case .uncompleted: return NSLocalizedString("uncompleted", comment: "Незавершённые")
        }
    }
}

extension FiltersView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = TrackersFilter.allCases[indexPath.row]
        delegate?.onSetFilters(filter: TrackersFilter.allCases[indexPath.row])
        tableView.reloadData()
        dismiss(animated: true)
    }
}

extension FiltersView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackersFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FilterCell.init(style: .default, reuseIdentifier: FilterCell.identifier)
        let filter = TrackersFilter.allCases[indexPath.row]
        let isSelected = filter == selectedFilter && (filter == .completed || filter == .uncompleted)
        cell.configure(title: title(for: filter), isSelected: isSelected)
        cell.backgroundColor = .ypBackground
        
        if (indexPath.row == 0) {
            cell.separatorInset = .zero
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if (indexPath.row == TrackersFilter.allCases.count - 1) {
            cell.separatorInset = .zero
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset.left = UIScreen.main.bounds.width
        }
        
        return cell
    }
}

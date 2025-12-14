//
//  StatisticsView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 07.09.2025.
//
import UIKit

final class StatisticView: UIViewController {
    let trackerRecordStore = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(TrackerRecordStore.self)
    private var data: [(String, Int)] = [] {
        didSet{
            statisticTable.reloadData()
            statisticTable.isHidden = data.isEmpty
            emptyStateStack.isHidden = !data.isEmpty
        }
    }
    
    // - MARK: UI elements
    
    private lazy var emptyStateImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Crying Face")
        imageView.image = image
        
        return imageView
    }()
    
    private lazy var emptyStateTitleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .ypBlack
        label.text = "Анализировать пока нечего"
        
        return label
    }()

    // - MARK: Stacks
    
    private lazy var emptyStateStack = {
        let stack = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateTitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var statisticTable = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.backgroundColor = .ypWhite
        table.separatorStyle = .none
        table.allowsSelection = false
        table.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        title = NSLocalizedString("statistic", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        definesPresentationContext = true
        view.backgroundColor = .ypWhite
        
        view.addSubview(emptyStateStack)
        view.addSubview(statisticTable)
        
        setupConstraints()
        trackerRecordStore?.delegate = self
        trackerRecordStore?.startObserving()
        updateData()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            statisticTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statisticTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func updateData() {
        let completedCount = (try? trackerRecordStore?.totalCompletedCount()) ?? 0
        data = [
            (NSLocalizedString("trackers_completed", comment: ""), completedCount)
        ]
    }
}

extension StatisticView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = StatisticCell.init(style: .default, reuseIdentifier: StatisticCell.identifier)
        cell.configure(title: data[indexPath.row].0, value: data[indexPath.row].1)
        
        return cell
    }
}

extension StatisticView: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        updateData()
    }
}

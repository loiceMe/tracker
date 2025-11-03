//
//  ScheduleView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 03.10.2025.
//
import UIKit

final class ScheduleView: UIViewController {
    
    // - MARK: Elements

    private lazy var scheduleTable = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bouncesVertically = false
        tableView.showsVerticalScrollIndicator = false
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // A small height is sufficient
        tableView.tableFooterView = footerView
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    private lazy var readyButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.addSubview(scheduleTable)
        view.addSubview(readyButton)
        
        navigationItem.title = "Расписание"
        view.backgroundColor = UIColor(named: "White")
        
        scheduleTable.dataSource = self
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scheduleTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scheduleTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scheduleTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scheduleTable.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -39),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func readyButtonTapped() {
        dismiss(animated: true)
    }
}

extension ScheduleView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScheduleTableCell.init(style: .default, reuseIdentifier: "scheduleCell")
        if (indexPath.row == 0) {
            cell.layer.cornerRadius = 16
            let sublayer = CALayer()
            sublayer.frame = CGRect(x: 0, y: cell.frame.maxY + 16, width: tableView.frame.width, height: 16)
            sublayer.backgroundColor = UIColor(named: "Background Solid")?.cgColor
            cell.layer.addSublayer(sublayer)
        }
        
        if (indexPath.row == daysOfWeek.count - 1) {
            cell.layer.cornerRadius = 16
            let sublayer = CALayer()
            sublayer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16)
            sublayer.backgroundColor = UIColor(named: "Background Solid")?.cgColor
            cell.layer.addSublayer(sublayer)
        }
        cell.titleLabel.text = daysOfWeek[indexPath.row]
        cell.backgroundColor = .background
        
        return cell
    }
}

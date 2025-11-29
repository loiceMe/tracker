//
//  ScheduleView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 03.10.2025.
//
import UIKit

protocol SetScheduleDelegate: AnyObject {
    func onSetSchedule(days: [Int])
}

final class ScheduleView: UIViewController {
    
    weak var setScheduleDelegate: SetScheduleDelegate?
    
    var selectedDays: [Int] = []
    
    // - MARK: Elements

    private lazy var scheduleTable = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bouncesVertically = false
        tableView.showsVerticalScrollIndicator = false
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // A small height is sufficient
        tableView.tableFooterView = footerView
        tableView.layer.cornerRadius = 16
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
    
    private var selectedDaysOfWeek = [String]()
    
    private var daysOfWeek = WeekDay.allCases
    
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
    private func switchChanged(_ sender: UISwitch) {
        let day = sender.tag
        if sender.isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
            }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
    
    @objc
    private func readyButtonTapped() {
        setScheduleDelegate?.onSetSchedule(days: selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScheduleTableCell.init(style: .default, reuseIdentifier: "scheduleCell")
        cell.titleLabel.text = WeekDay.name(calendarWeekday: WeekDay.allCases[indexPath.row].number)?.rawValue
        cell.switcher.tag = WeekDay.allCases[indexPath.row].number
        cell.switcher.isOn = selectedDays.contains(WeekDay.allCases[indexPath.row].number)
        cell.switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.backgroundColor = .background
        
        return cell
    }
}

//
//  CategoriesView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 26.11.2025.
//
import UIKit

protocol SetCategoryDelegate: AnyObject {
    func onSetCategory(category: TrackerCategory)
}

final class CategoriesView: UIViewController {
    
    weak var setCategoryDelegate: SetCategoryDelegate?
    
    var selectedCategory: TrackerCategory?
    
    // - MARK: Elements

    private lazy var categoriesTable = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bouncesVertically = false
        tableView.showsVerticalScrollIndicator = false
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.layer.cornerRadius = 16
        tableView.tableFooterView = footerView
        
        return tableView
    }()

    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.addSubview(categoriesTable)
        
        navigationItem.title = "Категория"
        view.backgroundColor = UIColor(named: "White")
        
        categoriesTable.dataSource = self
        categoriesTable.delegate = self
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoriesTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}

extension CategoriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setCategoryDelegate?.onSetCategory(category: FakeCategories[indexPath.row])
        dismiss(animated: true)
    }
}

extension CategoriesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FakeCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CategoriesTableCell.init(style: .default, reuseIdentifier: "categoryCell")
        cell.titleLabel.text = FakeCategories[indexPath.row].title
        cell.backgroundColor = .background
        
        return cell
    }
}

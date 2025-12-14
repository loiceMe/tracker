//
//  CategoriesView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 26.11.2025.
//
import UIKit

protocol SetCategoryDelegate: AnyObject {
    func onSetCategory(category: TrackerCategory?)
}

final class CategoriesView: UIViewController {
    private var viewModel: CategoriesViewModel?
    
    init(viewModel: CategoriesViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // - MARK: Elements

    private lazy var categoriesTable = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bouncesVertically = false
        tableView.showsVerticalScrollIndicator = false
        tableView.clipsToBounds = true
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private lazy var addCategoryButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onCategoriesChanged = { [weak self] in
            // self.updateContainerAndEmptyState()
            self?.categoriesTable.reloadData()
        }
        
        viewModel.onSelectedCategoryChanged = { [weak self] _ in
            self?.categoriesTable.reloadData()
        }
    }

    // - MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        viewModel?.start()
    }
    
    func configure() {
        view.addSubview(categoriesTable)
        view.addSubview(addCategoryButton)
        
        navigationItem.title = "Категория"
        view.backgroundColor = UIColor(named: "White")
        
        categoriesTable.dataSource = self
        categoriesTable.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        categoriesTable.addGestureRecognizer(longPress)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoriesTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTable.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -39),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func presentDeleteConfirmation(for title: String, sourceRect: CGRect, in sourceView: UIView) {
        let alert = UIAlertController(title: nil,
                                      message: "Эта категория точно не нужна?",
                                      preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel?.delete(title: title)
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc
    private func addCategoryButtonTapped() {
        let vc = CategoryView(mode: .create)
        vc.onDidCreate = { [weak self] title in
            self?.viewModel?.create(title: title)
        }
        self.present(vc, animated: true)
    }
    
    @objc
    private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        let point = recognizer.location(in: categoriesTable)
        guard let indexPath = categoriesTable.indexPathForRow(at: point) else { return }

        let category = viewModel?.category(by: indexPath.row)
        let title = category?.title ?? ""

        let cellRect = categoriesTable.rectForRow(at: indexPath)
        let cellRectInTable = categoriesTable.convert(cellRect, to: view)
        let cellRectInWindow = view.convert(cellRectInTable, to: nil)

        let menu = CategoryContextMenuController(categoryTitle: title, anchorFrameInWindow: cellRectInWindow)

        menu.onEdit = { [weak self] in
            let vc = CategoryView(mode: .edit(originalTitle: title))
            vc.onDidRename = { [weak self] oldTitle, newTitle in
                self?.viewModel?.update(from: oldTitle, to: newTitle)
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            self?.present(nav, animated: true)
        }

        menu.onDelete = { [weak self] in
            guard let self = self else { return }
            self.presentDeleteConfirmation(for: title,
                                           sourceRect: categoriesTable.rectForRow(at: indexPath),
                                           in: categoriesTable)
        }

        present(menu, animated: false)
    }
}

extension CategoriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.onChangedSelectedCategory(newRowIndex: indexPath.row)
        tableView.reloadData()
        dismiss(animated: true)
    }
}

extension CategoriesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categoriesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CategoriesTableCell.init(style: .default, reuseIdentifier: "categoryCell")
        guard
            let category = viewModel?.category(by: indexPath.row),
            let isSelected = viewModel?.isSelected(index: indexPath.row)
        else { return cell }
        cell.configure(with: category, isSelected: isSelected)
        cell.backgroundColor = .background
        
        if (indexPath.row == 0) {
            cell.separatorInset = .zero
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if (indexPath.row == viewModel?.categoriesCount) {
            cell.separatorInset = .zero
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset.left = UIScreen.main.bounds.width
        }
        
        return cell
    }
}

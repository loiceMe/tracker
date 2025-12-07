//
//  CategoriesViewModel.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 06.12.2025.
//
import Foundation

typealias Binding<T> = (T) -> Void

final class CategoriesViewModel {
    var onCategoriesChanged: (() -> Void)?
    var onSelectedCategoryChanged: ((Int?) -> Void)?
    
    var categories = [TrackerCategory]() {
        didSet {
            selectedRowIndex = nil
            onCategoriesChanged?()
        }
    }
    
    weak var setCategoryDelegate: SetCategoryDelegate?
    
    private var selectedRowIndex: Int?
    
    var categoriesCount: Int {
        get { categories.count }
    }
    
    private let categoriesStore: TrackerCategoryStore
    
    init(store: TrackerCategoryStore) {
        self.categoriesStore = store
        self.categoriesStore.delegate = self
    }
    
    func isSelected(index: Int) -> Bool {
        selectedRowIndex == index
    }
    
    func start() {
        categories = (try? categoriesStore.fetchAll()) ?? []
    }
    
    func category(by index: Int) -> TrackerCategory? {
        categories[index]
    }

    func onChangedSelectedCategory(newRowIndex: Int) {
        selectedRowIndex = newRowIndex
        onSelectedCategoryChanged?(selectedRowIndex)
        guard let selectedRowIndex = selectedRowIndex else { return }
        setCategoryDelegate?.onSetCategory(category: categories[selectedRowIndex])
    }
    
    func delete(title: String) {
        try? categoriesStore.delete(title: title)
        categories = (try? categoriesStore.fetchAll()) ?? []
    }
    
    func update(from oldTitle: String, to newTitle: String) {
        try? categoriesStore.update(oldTitle: oldTitle, newTitle: newTitle)
        categories = (try? categoriesStore.fetchAll()) ?? []
    }
    
    func create(title: String) {
        try? categoriesStore.createCategory(category: TrackerCategory(title: title, trackers: []))
        categories = (try? categoriesStore.fetchAll()) ?? []
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore) {
        categories = (try? store.fetchAll()) ?? []
    }
}

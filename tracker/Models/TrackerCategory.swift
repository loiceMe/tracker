//
//  TrackerCatrgory.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 19.11.2025.
//
import Foundation

struct TrackerCategory {
    let id: UUID
    let title: String
    let trackers: [Tracker]
}

let FakeCategories = [
    TrackerCategory(id: UUID(), title: "Категория 1", trackers: []),
    TrackerCategory(id: UUID(), title: "Категория 2", trackers: []),
    TrackerCategory(id: UUID(), title: "Категория 3", trackers: []),
    TrackerCategory(id: UUID(), title: "Категория 4", trackers: []),
    TrackerCategory(id: UUID(), title: "Категория 5", trackers: []),
]

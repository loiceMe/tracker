//
//  TrackerStore.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 01.12.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(_ store: TrackerStore)
}

enum TrackerStoreError: Error {
    case notFound
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    func startObserving() {
        _ = fetchedResultsController
        _ = try? fetchedResultsController.performFetch()
    }

    func create(_ tracker: Tracker, in categoryTitle: String) throws {
        let categoryCoreData = try fetchOrCreateCategory(with: categoryTitle)

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = categoryCoreData

        try context.save()
    }
    
    func update(_ tracker: Tracker, toCategoryTitle newCategoryTitle: String) throws {
        try context.performAndWait {
            guard let cd = try fetchTracker(by: tracker.id) else {
                throw TrackerStoreError.notFound
            }

            cd.title = tracker.title
            cd.emoji = tracker.emoji
            cd.color = tracker.color.hexString
            cd.schedule = tracker.schedule as NSObject
            
            if cd.category?.title != newCategoryTitle {
                let newCategory = try fetchOrCreateCategory(with: newCategoryTitle)
                cd.category = newCategory
            }
            try context.save()
        }
    }
    
    func delete(_ tracker: Tracker) throws {
        try context.performAndWait {
            guard let cd = try fetchTracker(by: tracker.id) else { throw TrackerStoreError.notFound }
            context.delete(cd)
            try context.save()
        }
    }

    func fetchAll() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        let trackerCoreDataObjects = try context.fetch(fetchRequest)

        return trackerCoreDataObjects.compactMap { trackerCoreData in
            guard
                let id = trackerCoreData.id,
                let title = trackerCoreData.title,
                let emoji = trackerCoreData.emoji,
                let schedule = trackerCoreData.schedule as? [Int]
            else {
                return nil
            }

            let color = UIColor.color(from: trackerCoreData.color ?? "")
            return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
        }
    }


    private func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1

        if let existing = try context.fetch(fetchRequest).first { return existing }

        let created = TrackerCategoryCoreData(context: context)
        created.title = title
        return created
    }


    private func daysMask(from days: [WeekDay]) -> Int16 {
        var resultMask: Int16 = 0
        for (index, day) in WeekDay.allCases.enumerated() {
            if days.contains(day) { resultMask |= (1 << Int16(index)) }
        }
        return resultMask
    }

    private func days(from mask: Int16) -> [WeekDay] {
        WeekDay.allCases.enumerated().compactMap { index, day in
            (mask & (1 << Int16(index))) != 0 ? day : nil
        }
    }
    
    private func fetchTracker(by id: UUID) throws -> TrackerCoreData? {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try context.fetch(req).first
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChange(self)
    }
}

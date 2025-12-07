//
//  TrackerCategoryStore.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 01.12.2025.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(
        _ store: TrackerCategoryStore
    )
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: "title",
            ascending: true
        )]
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
        _ = try? fetchedResultsController
            .performFetch()
    }

    func fetchAll() throws -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        let categoryCoreDataObjects = try context.fetch(fetchRequest)

        return categoryCoreDataObjects.compactMap { categoryCoreData in
            guard
                let title = categoryCoreData.title
            else {
                return nil
            }
            
            let trackerSet = (categoryCoreData.trackers as? Set<TrackerCoreData>) ?? []

            let sortedTrackersCoreData = trackerSet.sorted {
                let leftKey  = (($0.title ?? ""), ($0.id?.uuidString ?? ""))
                let rightKey = (($1.title ?? ""), ($1.id?.uuidString ?? ""))
                return leftKey < rightKey
            }

            let trackers: [Tracker] = sortedTrackersCoreData.compactMap { trackerCoreData in
                guard
                    let id = trackerCoreData.id,
                    let title = trackerCoreData.title,
                    let emoji = trackerCoreData.emoji,
                    let schedule = trackerCoreData.schedule as? [Int]
                else { return nil }

                let color = UIColor.color(from: trackerCoreData.color ?? "")
                
                return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
            }

            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange(self)
    }
}


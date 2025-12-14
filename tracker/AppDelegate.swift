//
//  AppDelegate.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 05.09.2025.
//

import UIKit
import Swinject
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let container: Container = {
        ScheduleTransformer.register()
        var persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Error loading Database: \(error.description)")
            }
        }
        
        let container = Container()
        
        container.register(NSPersistentContainer.self) { _ in
            return persistentContainer
        }
        container.register(TrackerStore.self) { _ in
            return TrackerStore(context: persistentContainer.viewContext)
        }
        container.register(TrackerCategoryStore.self) { _ in
            return TrackerCategoryStore(context: persistentContainer.viewContext)
        }
        container.register(TrackerRecordStore.self) { _ in
            return TrackerRecordStore(context: persistentContainer.viewContext)
        }

        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func saveContext() {
        guard let persistentContainer = container.resolve(NSPersistentContainer.self) else {
            return
        }
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do { try context.save() }
        catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
}


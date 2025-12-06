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
                fatalError("Unresolved error \(error), \(error.userInfo)")
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

        // window!.rootViewController = TabBar()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
}


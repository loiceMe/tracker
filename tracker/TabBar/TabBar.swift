//
//  TabBar.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 07.09.2025.
//
import UIKit

final class TabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configure() {
        let trackersViewController = TrackersView()
        let trackersNavigation = UINavigationController(rootViewController: trackersViewController)
        trackersNavigation.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statsViewController = StatisticView()
        let statsNavigation = UINavigationController(rootViewController: statsViewController)
        statsNavigation.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        viewControllers = [trackersNavigation, statsNavigation]
    }
}


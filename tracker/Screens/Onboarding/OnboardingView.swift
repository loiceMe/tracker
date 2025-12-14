//
//  OnboardingView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 06.12.2025.
//

import UIKit

final class OnboardingView: UIPageViewController {
    private static let showedOnboardingKey = "isShowedOnboarding"
    
    private lazy var pages: [UIViewController] = {
        return [
            makePage(
                image: UIImage(resource: .bgOne),
                titleText: "Отслеживайте только то, что хотите"
            ),
            makePage(
                image: UIImage(resource: .bgTwo),
                titleText: "Даже если это \nне литры воды и йога"
            )
        ]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "Вот это технологии!"
        config.baseBackgroundColor = .ypBlack
        config.baseForegroundColor = .ypWhite
        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
        config.background.cornerRadius = 16
        
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        return button
    }()
    
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        configure()
    }
    
    private static func setOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: showedOnboardingKey)
    }
    
    static func hasSeenOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: showedOnboardingKey)
    }
    
    private func makePage(image: UIImage, titleText: String) -> UIViewController {
        let viewController = UIViewController()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.clipsToBounds = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(imageView)
        viewController.view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: viewController.view.centerYAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 76),
            
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        
        return viewController
    }
    
    private func configure() {
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
            
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.heightAnchor.constraint(lessThanOrEqualToConstant: 60)
        ])
    }
    
    @objc
    private func handlePrimaryTapped() {
        Self.setOnboardingSeen()
        let root = TabBar()
        view.window?.rootViewController = root
        view.window?.makeKeyAndVisible()
        root.view.alpha = 0
        UIView.animate(withDuration: 0.25) { root.view.alpha = 1 }
    }
}

extension OnboardingView: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pages.firstIndex(of: viewController)
        else { return nil }

        let previous = index - 1
        return previous >= 0 ? pages[previous] : nil
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pages.firstIndex(of: viewController)
        else { return nil }
        
        let next = index + 1
        return next < pages.count ? pages[next] : nil
    }
}

extension OnboardingView: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: current) else { return }
        pageControl.currentPage = index
    }
}

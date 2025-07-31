//
//  TabController.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import UIKit
import SnapKit
import Then

class TabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        let listVC = ListViewController()
        let listNav = UINavigationController(rootViewController: listVC)
        listNav.tabBarItem = UITabBarItem(title: "담은 책", image: UIImage(systemName: "list.bullet"), tag: 1)

        setViewControllers([searchNav, listNav], animated: true)
    }
    
}

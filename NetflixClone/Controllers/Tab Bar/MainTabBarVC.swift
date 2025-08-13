//
//  ViewController.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

class MainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: HomeVC())
        let vc2 = UINavigationController(rootViewController: UpcomingVC())
        let vc3 = UINavigationController(rootViewController: SearchVC())
        let vc4 = UINavigationController(rootViewController: DownloadsVC())
        
        vc1.tabBarItem.image = SFSymbols.house
        vc2.tabBarItem.image = SFSymbols.playCircleTab
        vc3.tabBarItem.image = SFSymbols.search
        vc4.tabBarItem.image = SFSymbols.download
        
        vc1.title = "Home"
        vc2.title = "Upcoming"
        vc3.title = "Top Search"
        vc4.title = "Downloads"
        
        tabBar.tintColor = .label
        setViewControllers([vc1, vc2, vc3, vc4], animated: true)
    }


}


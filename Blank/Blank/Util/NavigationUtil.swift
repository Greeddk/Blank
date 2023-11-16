//
//  NavigationUtil.swift
//  Blank
//
//  Created by Greed on 10/31/23.
//

import SwiftUI

struct NavigationUtil {
    static func popToRootView(animated: Bool = false) {
        findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController)?.popToRootViewController(animated: animated)
    }
    
    static func popToOverView(animated: Bool = false) {
            guard let navigationController = findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController) else {
                return
            }
            
            if navigationController.viewControllers.count > 1 {
                let overViewController = navigationController.viewControllers[1]  // 루트 뷰 바로 다음에 있는 뷰 컨트롤러를 가져옵니다.
                navigationController.popToViewController(overViewController, animated: animated)
            }
        }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}

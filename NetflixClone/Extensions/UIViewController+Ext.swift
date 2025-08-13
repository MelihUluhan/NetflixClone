//
//  UIViewController+Ext.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 8.08.2025.
//

import UIKit

extension UIViewController {
    func presentErrorNFAlert(message: String? = "Something went wrong. Please try again later.") {
        let alertVC = NFAlertVC(message: message, image: SFSymbols.errorFill)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
    func presentNFAlert(title: String? = nil, message: String? = nil, image: UIImage? = nil) {
        let alertVC = NFAlertVC(movie: title,message: message, image: image)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
    func showFullScreenLoading() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let loadingView = UIView(frame: window.bounds)
        loadingView.tag = 999
        loadingView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        loadingView.alpha = 0
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        window.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.3) {
            loadingView.alpha = 1
        }
    }
    
    func hideFullScreenLoading() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let loadingView = window.viewWithTag(999) else { return }
        
        UIView.animate(withDuration: 0.5, animations: {
            loadingView.alpha = 0
        }) { _ in
            loadingView.removeFromSuperview()
        }
    }
}


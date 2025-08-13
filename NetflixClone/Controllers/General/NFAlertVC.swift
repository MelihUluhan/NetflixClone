//
//  NFAlert.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 8.08.2025.
//

import UIKit

class NFAlertVC: UIViewController {
    
    private var bottomConstraint: NSLayoutConstraint!
    private var sheetHeight: CGFloat = 0
    private var hasAnimatedIn = false
    
    private let sheetHolderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let movieLabel: UILabel = {
        let movie = UILabel()
        movie.textAlignment = .center
        movie.textColor = .label
        movie.font = .systemFont(ofSize: 17, weight: .semibold)
        movie.minimumScaleFactor = 0.9
        movie.lineBreakMode = .byTruncatingTail
        movie.translatesAutoresizingMaskIntoConstraints = false
        return movie
    }()
    
    private let messageLabel: UILabel = {
        let message = UILabel()
        message.textAlignment = .center
        message.textColor = .label
        message.font = .systemFont(ofSize: 15, weight: .medium)
        message.adjustsFontSizeToFitWidth = true
        message.minimumScaleFactor = 0.75
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(movie: String? = nil, message: String? = nil, image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
        movieLabel.text = movie
        messageLabel.text = message
        
        if image == SFSymbols.errorFill {
            imageView.tintColor = .systemRed
        } else {
            imageView.tintColor = .systemGreen
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(containerView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
        
        playButton.addTarget(self, action: #selector(hideSheetAndDismiss), for: .touchUpInside)
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.addSubview(sheetHolderView)
        containerView.addSubview(imageView)
        containerView.addSubview(movieLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(playButton)
        
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            
            sheetHolderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            sheetHolderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sheetHolderView.widthAnchor.constraint(equalToConstant: 150),
            sheetHolderView.heightAnchor.constraint(equalToConstant: 3),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: sheetHolderView.bottomAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 75),
            
            movieLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            movieLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            movieLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            
            messageLabel.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 6),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            
            playButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if sheetHeight == 0 {
            sheetHeight = containerView.frame.height
            bottomConstraint.constant = sheetHeight
        }
        
        if !hasAnimatedIn {
            hasAnimatedIn = true
            showSheet()
        }
    }
    
    private func showSheet() {
        self.view.layoutIfNeeded()
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    
    @objc private func hideSheetAndDismiss() {
        bottomConstraint.constant = sheetHeight
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseIn]) {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            hideSheetAndDismiss()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                bottomConstraint.constant = translation.y
            }
        case .ended:
            if translation.y > containerView.frame.height / 3 {
                hideSheetAndDismiss()
            } else {
                bottomConstraint.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
}

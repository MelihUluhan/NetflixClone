//
//  MoviePreviewViewController.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 25.06.2025.
//

import UIKit
import WebKit

class MoviePreviewVC: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Harry Potter"
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.text = "This is the best movie ever to watch"
        return label
    }()
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(webView)
        scrollView.addSubview(movieLabel)
        scrollView.addSubview(overviewLabel)
        
        configureConstaints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.transform = .identity
    }
    
    private func configureConstaints() {
        NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                webView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                webView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                webView.widthAnchor.constraint(equalTo: view.widthAnchor),
                webView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.3),

                movieLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
                movieLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                movieLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),

                overviewLabel.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 20),
                overviewLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                overviewLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
                overviewLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40)
                
            ])
    }
    
    func configure(with model: MoviePreviewViewModel) {
        movieLabel.text = model.movie
        overviewLabel.text = model.movieOverView
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }
        
        webView.load(URLRequest(url: url))
    }
}

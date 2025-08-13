//
//  SearchResultsViewController.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 25.06.2025.
//

import UIKit

protocol SearchResultsVCDelegate: AnyObject {
    func searchResultsVCDidTapItem(_ viewModel: MoviePreviewViewModel)
}

class SearchResultsVC: UIViewController {
    
    public var movies = [Movie]()
    
    public weak var delegate: SearchResultsVCDelegate?
    
    public let searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 180)
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(searchResultsCollectionView)
        
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }
}

extension SearchResultsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movie = movies[indexPath.row]
        cell.configure(with: movie.poster_path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        
        guard let movieName = movie.original_title ?? movie.original_name else {
            return
        }
        
        NetworkManager.shared.getMovie(with: movieName) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let videoElement):
                    delegate?.searchResultsVCDidTapItem(MoviePreviewViewModel(movie: movieName,
                                                                              youtubeView: videoElement,
                                                                              movieOverView: movie.overview ?? ""))
                    
                case .failure(let error): print(error.localizedDescription)
            }
        }
    }
}


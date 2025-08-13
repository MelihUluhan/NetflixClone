//
//  CollectionViewTableViewCell.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidStartLoading(_ cell: CollectionViewTableViewCell)
    func collectionViewTableViewCellDidFinishLoading(_ cell: CollectionViewTableViewCell, viewModel: MoviePreviewViewModel?, error: Error?)
    func collectionViewTableViewCellDownloadButtonTapped(_ movie: Movie?,error: Error?)
}

class CollectionViewTableViewCell: UITableViewCell {
    
    static let identifier = "CollectionViewTableViewCell"
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    private var movies = [Movie]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with movies: [Movie]) {
        self.movies = movies
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
    
    private func downloadMovieAt(indexPath: IndexPath) {
        DataPersistenceManager.shared.downloadMovieWith(model: movies[indexPath.row]) { result in
            switch result {
                case .success():
                    self.delegate?.collectionViewTableViewCellDownloadButtonTapped(self.movies[indexPath.row],error: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                case .failure(let error):
                    self.delegate?.collectionViewTableViewCellDownloadButtonTapped(nil,error: error)
            }
        }
    }
    
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell, let model = movies[indexPath.row].poster_path  else {
            return UICollectionViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        guard let movieName = movie.original_title ?? movie.original_name else {
            return
        }
        
        delegate?.collectionViewTableViewCellDidStartLoading(self) 
        
        NetworkManager.shared.getMovie(with: movieName + " trailer") {[weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                    case .success(let video):
                        let viewModel = MoviePreviewViewModel(movie: movieName, youtubeView: video, movieOverView: movie.overview ?? "-")
                        self.delegate?.collectionViewTableViewCellDidFinishLoading(self, viewModel: viewModel,error: nil)
                    case .failure(let error):
                        self.delegate?.collectionViewTableViewCellDidFinishLoading(self, viewModel: nil, error: error)
                }
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let downloadAction = UIAction(title: "Download",
                                          subtitle: nil,
                                          image: nil,
                                          identifier: nil,
                                          discoverabilityTitle: nil,
                                          state: .off) { [weak self] _ in
                guard let self else { return }
                self.downloadMovieAt(indexPath: indexPaths.first!)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
        
        return config
    }
    
}

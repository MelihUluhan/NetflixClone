//
//  DownloadsVC.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

class DownloadsVC: UIViewController {
    
    private var filteredMovies: [MovieItem] = []
    private var isSearching = false
    private var movies: [MovieItem] = [MovieItem]()
    
    private let downloadedTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search Downloaded Movie"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Downloads"
        view.addSubview(downloadedTableView)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self

        
        downloadedTableView.delegate = self
        downloadedTableView.dataSource = self
        fetchLocalStorageForDownloads()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownloads()
        }
    }
    
    private func fetchLocalStorageForDownloads() {
        self.showFullScreenLoading()
        DispatchQueue.main.async {
            DataPersistenceManager.shared.fetchMoviesFromDataBase { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success(let movies):
                        self.movies = movies
                        self.downloadedTableView.reloadData()
                    case .failure(let error):
                        presentErrorNFAlert(message: error.localizedDescription)
                }
            }
        }
        
        self.hideFullScreenLoading()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTableView.frame = view.bounds
    }
    
}

extension DownloadsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        cell.configure(with: MovieViewModel(
            movieName: movie.original_title ?? movie.original_name ?? "Unknown",
            posterURL: movie.poster_path ?? ""
        ))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        
        guard let movieName = movie.original_title ?? movie.original_name else {
            return
        }
        
        self.showFullScreenLoading()
        NetworkManager.shared.getMovie(with: movieName) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let videoElement):
                    DispatchQueue.main.async {
                        guard self.navigationController?.topViewController == self else { return }
                        let vc = MoviePreviewVC()
                        vc.configure(with: MoviePreviewViewModel(movie: movieName, youtubeView: videoElement, movieOverView: movie.overview ?? ""))
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                case .failure(let error):
                    presentErrorNFAlert(message: error.localizedDescription)
            }
        }
        self.hideFullScreenLoading()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let movieToDelete = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        
        DataPersistenceManager.shared.deleteMovieWith(model: movieToDelete) { result in
            switch result {
            case .success():
                if self.isSearching {
                    self.filteredMovies.remove(at: indexPath.row)
                    
                    if let indexInMain = self.movies.firstIndex(where: { $0.id == movieToDelete.id }) {
                        self.movies.remove(at: indexInMain)
                    }
                } else {
                    self.movies.remove(at: indexPath.row)
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            case .failure(let error):
                    self.presentErrorNFAlert(message: error.localizedDescription)
            }
        }
    }

}

extension DownloadsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(), !query.isEmpty else {
            isSearching = false
            downloadedTableView.reloadData()
            return
        }
        
        filteredMovies = movies.filter { movie in
            let name = movie.original_title ?? movie.original_name ?? ""
            return name.lowercased().contains(query)
        }
        
        isSearching = true
        downloadedTableView.reloadData()
    }
}

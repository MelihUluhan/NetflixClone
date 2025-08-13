//
//  SearchVC.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

class SearchVC: UIViewController {
    
    private var movies = [Movie]()
    
    private let discoverTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsVC())
        controller.searchBar.placeholder = "Search for a Movie or a Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .systemBackground
        
        view.addSubview(discoverTableView)
        discoverTableView.delegate = self
        discoverTableView.dataSource = self
        navigationItem.searchController = searchController
        
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
    }
    
    private func fetchDiscoverMovies() {
        self.showFullScreenLoading()
        NetworkManager.shared.getDiscoverMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let movies):
                    self.movies = movies
                    DispatchQueue.main.async {
                        self.discoverTableView.reloadData()
                    }
                case .failure(let error):
                    presentErrorNFAlert(message: error.localizedDescription)
            }
        }
        self.hideFullScreenLoading()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTableView.frame = view.bounds
    }
}

extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let movie = movies[indexPath.row]
        let model = MovieViewModel(movieName: movie.original_name ?? movie.original_title ?? "Unknown", posterURL: movie.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        
        guard let movieName = movie.original_title ?? movie.original_name else {
            return
        }
        
        NetworkManager.shared.getMovie(with: movieName) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
            switch result {
                case .success(let videoElement):
                    
                        guard self.navigationController?.topViewController == self else { return }
                        let vc = MoviePreviewVC()
                        vc.configure(with: MoviePreviewViewModel(movie: movieName, youtubeView: videoElement, movieOverView: movie.overview ?? ""))
                        self.navigationController?.pushViewController(vc, animated: true)

                case .failure(let error):
                    self.presentErrorNFAlert(message: error.localizedDescription)
            }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension SearchVC : UISearchResultsUpdating, SearchResultsVCDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
            let resultsController = searchController.searchResultsController as? SearchResultsVC
        else { return }
        
        resultsController.delegate = self
        
        NetworkManager.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let movies):
                        resultsController.movies = movies
                        resultsController.searchResultsCollectionView.reloadData()
                        
                    case .failure(let error): print(error.localizedDescription)
                }
            }
        }
    }
    
    func searchResultsVCDidTapItem(_ viewModel: MoviePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let vc = MoviePreviewVC()
            vc.configure(with: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

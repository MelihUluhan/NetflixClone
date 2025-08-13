//
//  UpcomingVC.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

class UpcomingVC: UIViewController {
    
    private var movies = [Movie]()
    
    private let upcomingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        configureUpcomingTableView()
        fetchUpcoming()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }
    
    private func configureUpcomingTableView() {
        view.addSubview(upcomingTableView)
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
    }
    
    private func fetchUpcoming() {
        self.showFullScreenLoading()
        NetworkManager.shared.getUpcomingMovies { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                    case .success(let movies):
                        self.movies = movies
                        self.upcomingTableView.reloadData()
                    case .failure(let error):
                        self.presentErrorNFAlert(message: error.localizedDescription)
                }
                self.hideFullScreenLoading()
            }
        }
    }


}

extension UpcomingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let movie = movies[indexPath.row]
        cell.configure(with: MovieViewModel(movieName: movie.original_title ?? movie.original_name ?? "Unknown", posterURL: movie.poster_path ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        
        guard let movieName = movie.original_title ?? movie.original_name else {
            return
        }
        
        self.showFullScreenLoading()
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
                self.hideFullScreenLoading()
            }
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

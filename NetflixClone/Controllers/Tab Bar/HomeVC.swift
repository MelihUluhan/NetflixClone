//
//  HomeVC.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 18.06.2025.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTv = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeVC: UIViewController {
    
    private var randomTrendingMovie: Movie?
    private var headerView: HeroHeaderUIView?
    
    let sectionMovies: [String] = ["Trending Movies", "Trending Tv", "Popular", "Upcoming Movies", "Top Rated"]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(homeFeedTable)
        view.backgroundColor = .systemBackground
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        
        configureNavBar()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        headerView?.delegate = self
        homeFeedTable.tableHeaderView = headerView
        
        configureHeroHeaderView()
    }
    
    private func configureHeroHeaderView() {
        self.showFullScreenLoading()
        NetworkManager.shared.getTrendingMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let movies):
                    let selectedMovie = movies.randomElement()
                    self.randomTrendingMovie = selectedMovie
                    self.headerView?.configure(with: MovieViewModel(movieName: selectedMovie?.original_name ?? selectedMovie?.original_title ?? "Unknown", posterURL: selectedMovie?.poster_path ?? ""))
                case .failure(let error): print(error.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.hideFullScreenLoading()
            }
        }
    }
    
    private func configureNavBar() {
        var image = UIImage(resource: .netflixLogo)
        image = image.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: SFSymbols.person, style: .done, target: self, action: nil),
            UIBarButtonItem(image: SFSymbols.playRectangle, style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionMovies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
            case Sections.TrendingMovies.rawValue:
                
                NetworkManager.shared.getTrendingMovies { result in
                    switch result {
                        case .success(let movies):
                            cell.configure(with: movies)
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
                
            case Sections.TrendingTv.rawValue:
                
                NetworkManager.shared.getTrendingTvs { result in
                    switch result {
                        case .success(let movies):
                            cell.configure(with: movies)
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
            case Sections.Popular.rawValue:
                
                NetworkManager.shared.getPopularMovies { result in
                    switch result {
                        case .success(let movies):
                            cell.configure(with: movies)
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
                
            case Sections.Upcoming.rawValue:
                
                NetworkManager.shared.getUpcomingMovies { result in
                    switch result {
                        case .success(let movies):
                            cell.configure(with: movies)
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
                
            case Sections.TopRated.rawValue:
                
                NetworkManager.shared.getTopRated { result in
                    switch result {
                        case .success(let movies):
                            cell.configure(with: movies)
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
                
            default:
                return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y , width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizingFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionMovies[section]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeVC: HeroHeaderUIViewDelegate {
    func heroHeaderViewPlayButtonTapped() {
        guard let randomMovie = randomTrendingMovie,
              let movieName = randomMovie.original_title ?? randomMovie.original_name else {
            self.presentErrorNFAlert()
            return
        }
        
        self.showFullScreenLoading()
        NetworkManager.shared.getMovie(with: movieName + " trailer") {[weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                    case .success(let video):
                        let viewModel = MoviePreviewViewModel(movie: movieName,
                                                              youtubeView: video,
                                                              movieOverView: randomMovie.overview ?? "-")
                        let vc = MoviePreviewVC()
                        vc.configure(with: viewModel)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let error):
                        self.presentErrorNFAlert(message: error.localizedDescription)
                }
            }
        }
        self.hideFullScreenLoading()
    }
    
    func heroHeaderViewDownloadButtonTapped() {
        guard let randomMovie = randomTrendingMovie else {
            self.presentErrorNFAlert()
            return
        }
        
        DataPersistenceManager.shared.downloadMovieWith(model: randomMovie) { result in
            switch result {
                case .success():
                    self.presentNFAlert(message: "\(randomMovie.original_title ?? randomMovie.original_name ?? "The movie") has been successfully                       downloaded.",image: SFSymbols.successFill)
                    NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                case .failure(let error):
                    self.presentErrorNFAlert(message: error.localizedDescription)
            }
        }
    }
    
    
}

extension HomeVC: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDownloadButtonTapped(_ movie: Movie?,error: (any Error)?) {
        if let error = error {
            self.presentErrorNFAlert(message: error.localizedDescription)
        } else {
            self.presentNFAlert(message: "\(movie?.original_title ?? movie?.original_name ?? "The movie") has been successfully                       downloaded.",image: SFSymbols.successFill)
        }
    }
    
    func collectionViewTableViewCellDidStartLoading(_ cell: CollectionViewTableViewCell) {
        self.showFullScreenLoading()
    }
    
    func collectionViewTableViewCellDidFinishLoading(_ cell: CollectionViewTableViewCell, viewModel: MoviePreviewViewModel?, error: Error?) {
        self.hideFullScreenLoading()
        guard let viewModel = viewModel else {
            presentErrorNFAlert(message: error?.localizedDescription)
            return
        }
        let vc = MoviePreviewVC()
        vc.configure(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}



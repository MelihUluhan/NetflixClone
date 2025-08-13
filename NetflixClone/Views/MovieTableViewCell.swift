//
//  MovieTableViewCell.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 25.06.2025.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    static let identifier = "MovieTableViewCell"
    
    private let playMovieButton: UIButton = {
        let button = UIButton()
        let image = SFSymbols.playCircle
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moviePosterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(moviePosterImageView)
        contentView.addSubview(movieLabel)
        contentView.addSubview(playMovieButton)
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            moviePosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            moviePosterImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            moviePosterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            moviePosterImageView.widthAnchor.constraint(equalToConstant: 100),
            
            movieLabel.leadingAnchor.constraint(equalTo: moviePosterImageView.trailingAnchor, constant: 20),
            movieLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            movieLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playMovieButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playMovieButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    public func configure(with model: MovieViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        moviePosterImageView.sd_setImage(with: url,completed: nil)
        movieLabel.text = model.movieName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

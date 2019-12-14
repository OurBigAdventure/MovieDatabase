//
//  DetailVC.swift
//  MovieDatabase
//
//  Created by Chris Brown on 12/13/19.
//  Copyright © 2019 Chris Brown. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    var movie: Movie?
    var imageBaseURL = ""
    var posterImageSize = ""

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var starIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        starIcon.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        starIcon.tintColor = .yellow
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let movie = movie else {
            titleLabel.isHidden = true
            yearLabel.isHidden = true
            posterImage.isHidden = true
            descriptionTextView.isHidden = true
            errorMessage.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.errorMessage.alpha = 1.0
            }
            return
        }

        titleLabel.text = movie.title
        if let releaseDate = movie.releaseDate {
            yearLabel.text = String(releaseDate.prefix(4))
        }
        if let voteAverage = movie.voteAverage {
            userRating.text = String(format:"%.1f", voteAverage)
        }
        if let posterPath = movie.posterPath {
            let url = imageBaseURL + posterImageSize + posterPath
            if let image = ImageCache.shared.fetchImage(url) {
                posterImage.image = image
            } else {
                posterImage.image = UIImage(named: "movie-poster")
            }
        }
        descriptionTextView.text = movie.overview
    }
}

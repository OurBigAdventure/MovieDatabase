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
    var homepage = ""

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var genreList: UITextView!
    @IBOutlet weak var homepageButton: UIButton!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        starIcon.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        starIcon.tintColor = .yellow
        durationLabel.text = ""
        homepageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        homepageButton.layer.cornerRadius = 8.0
        homepageButton.layer.borderColor = UIColor.white.cgColor
        homepageButton.layer.borderWidth = 2.0
        homepageButton.isHidden = true
        homepageButton.alpha = 0.0

        NotificationCenter.default.addObserver(self, selector: #selector(DetailVC.viewDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if UIDevice.current.orientation.isLandscape {
//            spacerView.isHidden = true
//        } else {
//            spacerView.isHidden = false
//        }
//    }

    override func viewWillAppear(_ animated: Bool) {
        guard let movie = movie else {
            titleLabel.isHidden = true
            durationLabel.isHidden = true
            yearLabel.isHidden = true
            posterImage.isHidden = true
            descriptionTextView.isHidden = true
            homepageButton.isHidden = true
            errorMessage.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.errorMessage.alpha = 1.0
            }
            return
        }
        if let movieID = movie.id {
            MDBConnection.shared.fetchMovieDetails(movieID) { (details) in
                if let details = details  {
                    DispatchQueue.main.async {
                        if let runtime = details["runtime"] as? Int {
                            let (hours, minutes) = self.minutesToHoursMinutes(runtime)
                            self.durationLabel.text = "\(hours) h \(minutes) m"
                        }
                        if let homepage = details["homepage"] as? String,
                            !homepage.isEmpty {
                            self.homepage = homepage
                            self.homepageButton.isHidden = false
                            UIView.animate(withDuration: 0.5, animations: {
                                self.homepageButton.alpha = 1.0
                            }) { _ in
                                self.homepageButton.addTarget(self, action: #selector(DetailVC.openHomepage), for: .touchUpInside)
                            }
                        }
                    }
                }
            }
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
        if let genres = movie.genreIds {
            for genre in genres {
                if let newGenre = MDBConnection.shared.genres[genre] {
                    var spacer = ", "
                    if self.genreList.text.isEmpty {
                        spacer = ""
                    }
                    self.genreList.text += spacer + newGenre
                }
            }
        }
        descriptionTextView.text = movie.overview
    }

    func minutesToHoursMinutes (_ minutes : Int) -> (Int, Int) {
      return (minutes / 60, minutes % 60)
    }

    @objc func openHomepage() {
        guard let url = URL(string: self.homepage) else { return }
        UIApplication.shared.open(url)
    }

    @objc func viewDidRotate() {
        if UIDevice.current.orientation.isLandscape {
            spacerView.isHidden = true
        } else {
            spacerView.isHidden = false
            stackView.setNeedsLayout()
        }
    }
}

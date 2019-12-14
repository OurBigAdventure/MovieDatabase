//
//  ViewController.swift
//  MovieDatabase
//
//  Created by Chris Brown on 12/10/19.
//  Copyright © 2019 Chris Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MDBConnectionDelegate, ImageCacheDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageBaseURL = ""
    var posterImageSize = ""
    var shouldUpdateImages = false
    var userHasScrolled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        MDBConnection.shared.delegate = self
        ImageCache.shared.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MDBConnection.shared.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MovieTableCell
        let currentMovie = MDBConnection.shared.movies[indexPath.item]
        cell?.titleLabel.text = currentMovie.title
        if let releaseDate = currentMovie.releaseDate {
            cell?.yearLabel.text = String(releaseDate.prefix(4))
        }
        if let voteAverage = currentMovie.voteAverage {
            cell?.userRatingLabel.text = String(format:"%.1f", voteAverage)
        }

        if let posterPath = currentMovie.posterPath {
            let url = imageBaseURL + posterImageSize + posterPath
            if let image = ImageCache.shared.fetchImage(url) {
                cell?.posterImageView.image = image
            } else {
                cell?.posterImageView.image = UIImage(named: "movie-poster")
                DispatchQueue.global(qos: .background).async {
                    ImageCache.shared.cacheImage(url, callback: nil)
                }
            }
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 6 {
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                MDBConnection.shared.fetchPopularMovies()
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userHasScrolled = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollingEnded()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingEnded()
    }

    func scrollingEnded() {
        if self.shouldUpdateImages {
            self.shouldUpdateImages = false
            self.tableView.reloadData()
        }
    }

    // MARK: - MDBConnection Delegate

    func movieListUpdated() {
        self.tableView.reloadData()
        self.spinner.stopAnimating()
    }

    func updateConfigInfo() {
        if let imageSettings = MDBConnection.shared.config["images"] as? [String:Any],
            let baseURL = imageSettings["secure_base_url"] as? String,
            let posterSizes = imageSettings["poster_sizes"] as? [String] {
            imageBaseURL = baseURL
            posterImageSize = posterSizes[2]
            self.tableView.reloadData()
        }
    }

    // MARK: - ImageCache Delegate

    func newImageAvailable() {
        if !userHasScrolled {
            self.tableView.reloadData()
        }
        shouldUpdateImages = true
    }

}


//
//  MDBConnection.swift
//  MovieDatabase
//
//  Created by Chris Brown on 12/10/19.
//  Copyright © 2019 Chris Brown. All rights reserved.
//

import UIKit

protocol MDBConnectionDelegate {
    func movieListUpdated()
    func updateConfigInfo()
}

class MDBConnection {

    static let shared = MDBConnection()

    var delegate: MDBConnectionDelegate?
    var baseURL = "https://api.themoviedb.org/3/"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var config = [String: Any]()
    var genres = [Int: String]()
    var currentPage = 1
    var maxPages = 1
    var movies = [Movie]()

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()

    private init() {}

    func setupMovieDB() {
        updateMovieDBConfig()
        fetchPopularMovies()
        fetchMovieGenres()
    }

    func updateMovieDBConfig() {
        if let url = URL(string: baseURL + "configuration?api_key=" + appDelegate.movieDatabaseAPIKey) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("🚧 Error fetching MDB Config: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    do {
                        self.config = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                        DispatchQueue.main.async {
                            self.delegate?.updateConfigInfo()
                        }
                    } catch {
                        print("🚧 Could not decode MDB Config")
                    }
                }
            }.resume()
        }
    }

    func fetchMovieGenres() {
        if let url = URL(string: baseURL + "genre/movie/list?api_key=" + appDelegate.movieDatabaseAPIKey) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("🚧 Error fetching MDB Genres: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    do {
                        let genres = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                        if let genreList = genres["genres"] as? [[String: Any]] {
                            for genre in genreList {
                                if let int = genre["id"] as? Int,
                                    let name = genre["name"] as? String {
                                    self.genres[int] = name
                                }
                            }
                        }
                    } catch {
                        print("🚧 Could not decode MDB Genres")
                    }
                }
            }.resume()
        }
    }

    func fetchPopularMovies() {
        if self.currentPage > self.maxPages { return }
        if let url = URL(string: baseURL + "movie/popular?page=\(self.currentPage)&api_key=" + appDelegate.movieDatabaseAPIKey) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("🚧 Error fetching Popular Movies: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    do {
                        let movies = try self.jsonDecoder.decode(Movies.self, from: data)
                        self.maxPages = movies.totalPages ?? 1
                        if let newMovies = movies.results {
                            self.movies.append(contentsOf: newMovies)
                            DispatchQueue.main.async {
                                self.delegate?.movieListUpdated()
                                self.currentPage += 1
                            }
                        }
                    } catch {
                        print("🚧 Could not decode Popular Movies")
                    }
                }
            }.resume()
        }
    }

    func fetchMovieDetails(_ id: Int, completion: @escaping ([String: Any]?) -> Void) {
        if let url = URL(string: baseURL + "movie/\(id)?api_key=" + appDelegate.movieDatabaseAPIKey) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("🚧 Error fetching Movie Details: \(error.localizedDescription)")
                    completion(nil)
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    do {
                        let movieDetails = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                        completion(movieDetails)
                    } catch {
                        print("🚧 Could not decode Movie Details")
                    }
                }
                completion(nil)
            }.resume()
        }
    }

    func cacheImages(for movies: [Movie]) {
        if let imageSettings = self.config["images"] as? [String:Any],
            let baseURL = imageSettings["secure_base_url"] as? String,
            let posterSizes = imageSettings["poster_sizes"] as? [String] {
            let imageBaseURL = baseURL
            let posterImageSize = posterSizes[2]
            for movie in movies {
                if let posterPath = movie.posterPath {
                    ImageCache.shared.cacheImage(imageBaseURL + posterImageSize + posterPath, callback: nil)
                }
            }
        }
    }

}

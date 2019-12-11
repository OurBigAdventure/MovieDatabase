//
//  MovieTableCellTableViewCell.swift
//  MovieDatabase
//
//  Created by Chris Brown on 12/10/19.
//  Copyright © 2019 Chris Brown. All rights reserved.
//

import UIKit

class MovieTableCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var spacerOne: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var spacerTwo: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        starImageView.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        starImageView.tintColor = .yellow
        playImageView.image = UIImage(systemName: "playButton")?.withRenderingMode(.alwaysTemplate)
        playImageView.tintColor = .lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        posterImageView.image = nil
        titleLabel.text = ""
        yearLabel.text = ""
        durationLabel.text = ""
        ratingLabel.text = ""
        userRatingLabel.text = ""
    }

}

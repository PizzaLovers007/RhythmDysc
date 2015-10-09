//
//  SongDetailCell.swift
//  RhythmDysc
//
//  Created by MUser on 6/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class SongDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!;
    @IBOutlet weak var artistLabel: UILabel!;
    @IBOutlet weak var maxBPMLabel: UILabel!;
    @IBOutlet weak var coverImageView: UIImageView!;
    @IBOutlet weak var sectorSelection: UISegmentedControl!;
    @IBOutlet weak var difficultySelection: UISegmentedControl!;
    @IBOutlet weak var startGameButton: UIButton!;
    @IBOutlet weak var highScoresButton: UIButton!;
    
    override func awakeFromNib() {
        super.awakeFromNib();
        // Initialization code
        startGameButton.backgroundColor = UIColor.clearColor();
        startGameButton.layer.cornerRadius = 5;
        startGameButton.layer.borderWidth = 1;
        startGameButton.layer.borderColor = startGameButton.tintColor?.CGColor;
        startGameButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        highScoresButton.backgroundColor = UIColor.clearColor();
        highScoresButton.layer.cornerRadius = 5;
        highScoresButton.layer.borderWidth = 1;
        highScoresButton.layer.borderColor = highScoresButton.tintColor?.CGColor;
        highScoresButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);

        // Configure the view for the selected state
    }
}

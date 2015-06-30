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
    
    override func awakeFromNib() {
        super.awakeFromNib();
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);

        // Configure the view for the selected state
    }

}

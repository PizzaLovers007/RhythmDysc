//
//  HighScoreCell.swift
//  RhythmDysc
//
//  Created by MUser on 8/1/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit

class HighScoreCell: UITableViewCell {

    @IBOutlet weak var difficultyLabel: UILabel!;
    @IBOutlet weak var gradeLabel: UILabel!;
    @IBOutlet weak var scoreLabel: UILabel!;
    @IBOutlet weak var maxComboLabel: UILabel!;
    @IBOutlet weak var accuracyLabel: UILabel!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

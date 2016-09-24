//
//  EvilNoteTableViewCell.swift
//  EvilNotes
//
//  Created by Roque Rueda on 09/09/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit

class EvilNoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

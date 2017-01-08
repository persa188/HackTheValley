//
//  TrendingEventCell.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-07.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import UIKit

class TrendingEventCell: UITableViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.eventDescription.sizeToFit()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

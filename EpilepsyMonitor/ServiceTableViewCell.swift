//
//  ServiceTableViewCell.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/13/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

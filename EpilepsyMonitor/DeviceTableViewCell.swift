//
//  DeviceTableViewCell.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/10/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceRssiLabel: UILabel!
    
    var displayPeripheral: DisplayPeripheral? {
		didSet {
			if let deviceName = displayPeripheral!.peripheral?.name {
				deviceNameLabel.text = deviceName.isEmpty ? "No Device Name" : deviceName
            }
            else {
				deviceNameLabel.text = "No Device Name"
			}
            
            if let rssi = displayPeripheral!.lastRSSI {
                deviceRssiLabel.text = "\(rssi) dB"
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

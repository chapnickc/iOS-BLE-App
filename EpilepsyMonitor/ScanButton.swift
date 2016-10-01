//
//  ScanButton.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/11/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit

class ScanButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // add a layer to the button
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0).cgColor

    }
    
    func buttonColorScheme(_ isScanning: Bool) {
        let title = isScanning ? "Stop Scanning" : "Scan"
        let titleColor = isScanning ? UIColor.red : UIColor.white
        
        setTitle(title, for: UIControlState())
        setTitleColor(titleColor, for: UIControlState())
        
        backgroundColor = isScanning ? UIColor.clear : UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0)
        layer.borderColor = isScanning ? UIColor.red.cgColor : UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0).cgColor
        
    }

}

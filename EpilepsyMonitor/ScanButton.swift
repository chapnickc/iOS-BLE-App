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
        // I am not sure what is wrong with this line, but it seems to be raising an error.
        layer.borderColor = UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0).CGColor
    }
    
    func buttonColorScheme(isScanning: Bool) {
        let title = isScanning ? "Stop Scanning" : "Scan"
        let titleColor = isScanning ? UIColor.redColor() : UIColor.whiteColor()
        
        setTitle(title, forState: UIControlState())
        setTitleColor(titleColor, forState: UIControlState())
        
        backgroundColor = isScanning ? UIColor.clearColor() : UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0)
        layer.borderColor = isScanning ? UIColor.redColor().CGColor : UIColor(red: 11/255.0, green: 102/255.0, blue: 254/255.0, alpha: 1.0).CGColor
        
    }

}

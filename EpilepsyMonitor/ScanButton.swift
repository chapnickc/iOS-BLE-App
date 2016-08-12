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
        //layer.borderColor = UIColor.redColor().CGColor
    }
    
    func buttonColorScheme(isScanning: Bool) {
        let title = isScanning ? "Stop Scanning" : "Scan"
        setTitle(title, forState: UIControlState.Normal)
        
        let titleColor = isScanning ? UIColor.redColor() : UIColor.whiteColor()
        setTitleColor(titleColor, forState: .Normal)
        
        backgroundColor = isScanning ? UIColor.clearColor() : UIColor.blueColor()
        
        layer.borderColor = isScanning ? UIColor.redColor().CGColor : UIColor.blueColor().CGColor
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

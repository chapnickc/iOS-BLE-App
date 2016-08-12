//
//  ConnectButton.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/11/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit

class ConnectButton: UIButton {

    var connectTitleColor = UIColor(red: 102/255.0, green: 255/255.0, blue: 102/255.0, alpha: 1)
    var connectBackgroundColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
    
    var connectedTitleColor = UIColor.whiteColor()
    var connectedBackgroundColor = UIColor.redColor()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // add a layer to the button
        //layer.borderWidth = 1.5
        //layer.borderColor = UIColor.redColor().CGColor
    }
    
    func buttonColorScheme(isConnected: Bool) {
        let title = isConnected ? "Disconnect" : "Connect"
        setTitle(title, forState: UIControlState.Normal)
        
        let titleColor = isConnected ? connectedTitleColor : connectTitleColor
        setTitleColor(titleColor, forState: .Normal)
        
        backgroundColor = isConnected ? connectedBackgroundColor : connectBackgroundColor
        
        
    }

 
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

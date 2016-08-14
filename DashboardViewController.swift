//
//  DashboardViewController.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/13/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit
import CoreBluetooth

class DashboardViewController: UIViewController, UITableViewDataSource, CBPeripheralDelegate{
    
    var peripheral: CBPeripheral?
    var services: [CBService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        <#code#>
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        <#code#>
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        <#code#>
    }
    

}

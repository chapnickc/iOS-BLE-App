//
//  DashboardViewController.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/13/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit
import CoreBluetooth

class DashboardViewController: UIViewController, UITableViewDataSource, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral?
    var services: [CBService] = []
    var rssiReloadTimer: NSTimer?
    
    let heartRateServiceUUID = CBUUID(string: "180D")
    let heartRateMeasurementUUID = CBUUID(string: "2A37")
    
//    var serviceUUIDS = [CBUUID] = []
    
    
    
    
    @IBOutlet weak var peripheralLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        peripheral?.delegate = self
        peripheralLabel.text = peripheral?.name
        peripheral?.discoverServices(nil)
        
        rssiReloadTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                                                                 target: self,
                                                                 selector: #selector(DashboardViewController.refreshRSSI),
                                                                 userInfo: nil,
                                                                 repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshRSSI() {
        peripheral?.readRSSI()
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceTableViewCell", forIndexPath: indexPath) as! ServiceTableViewCell
        let serviceName = services[indexPath.row].UUID
        cell.serviceNameLabel.text = "\(serviceName)"
        
        return cell
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if error != nil {
			print("Error discovering services: \(error?.localizedDescription)")
		}
        
        for service in peripheral.services! {
            services.append(service)
            peripheral.discoverCharacteristics(nil, forService: service)
            
        }
        
		tableView.reloadData()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
			print("Error discovering service characteristics: \(error?.localizedDescription)")
		}
        
        for characteristic in service.characteristics! {
            print("\(service): \(characteristic.UUID)")
        }
        
//        service.characteristics?.forEach({ (characteristic) in
//            print("\(service.UUID): \(characteristic.UUID) --- \(characteristic.value)")
//            print("\(characteristic.descriptors)---\(characteristic.properties)")
//        })
        
    }
    
}










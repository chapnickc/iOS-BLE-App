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
    
    var peripheral: CBPeripheral?                           // passed from the ScanningViewController
    var services: [CBService] = []
    var rssiReloadTimer: NSTimer?
    
    var lastBPM: UInt8?
    var lastTemp: UInt8?
    
    let heartRateServiceUUID = CBUUID(string: "180D")
    let heartRateMeasurementUUID = CBUUID(string: "2A37")
    
    let healthThermometerServiceUUID = CBUUID(string: "1809")
    let tempMeasurementUUID = CBUUID(string: "2A1C")
    
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
        
        let service = services[indexPath.row]
        let serviceName = service.UUID
        
        cell.serviceNameLabel.text = "\(serviceName)"
        
        if service.UUID == heartRateServiceUUID && self.lastBPM != nil {
           cell.serviceValueLabel.text = "\(self.lastBPM!)"
        }
        
        if service.UUID == healthThermometerServiceUUID && self.lastTemp != nil {
           cell.serviceValueLabel.text = "\(self.lastTemp!)"
        }
        
        return cell
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if error != nil {
			print("Error discovering services: \(error?.localizedDescription)")
		}
        
        
        // discover services for each charcteristic of the device.
        // eventually we can skip this using the serviceUUIDS array.
        for service in peripheral.services! {
            services.append(service)
            peripheral.discoverCharacteristics(nil, forService: service)
        }
        
		tableView.reloadData()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // TODO: Tell the device to notify us for certain charactersitics. Then update service cell value in table view
        
        if error != nil {
			print("Error discovering service characteristics: \(error?.localizedDescription)")
		}
        
        for characteristic in service.characteristics! {
            print("\(service): \(characteristic)")
            
            if characteristic.UUID == heartRateMeasurementUUID || characteristic.UUID == tempMeasurementUUID {
                self.peripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        /* TODO:    Distinguish between different characteristics using UUIDS.
                    This works now since we set notifications only for
                    the heart rate measurement characteristic.
         */
        
        if characteristic.UUID == heartRateMeasurementUUID {
            let data = characteristic.value!      // of type NSData
            
            // construct an array of N elements, where N = data.length, with initial values of 0
            var values = [UInt8](count: data.length, repeatedValue: 0)
            
            // copy data.length number of bytes into values array
            data.getBytes(&values, length: data.length)
            
            let bpm = values[1]
            print("BPM: \(bpm)")
            self.lastBPM = bpm
        }
        
        if characteristic.UUID == tempMeasurementUUID {
             let data = characteristic.value!      // of type NSData
            
            // construct an array of N elements, where N = data.length, with initial values of 0
            var values = [UInt8](count: data.length, repeatedValue: 0)
            
            // copy data.length number of bytes into values array
            data.getBytes(&values, length: data.length)
            
            let temp = values[1]
            print("Temp: \(temp)")
            self.lastTemp = temp
        }
       
        tableView.reloadData()
    }
}










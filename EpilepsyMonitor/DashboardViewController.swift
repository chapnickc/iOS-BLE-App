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
    var rssiReloadTimer: Timer?
    
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
        
        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0,
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableViewCell", for: indexPath) as! ServiceTableViewCell
        
        let service = services[(indexPath as NSIndexPath).row]
        let serviceName = service.uuid
        
        cell.serviceNameLabel.text = "\(serviceName)"
        
        if service.uuid == heartRateServiceUUID && self.lastBPM != nil {
           cell.serviceValueLabel.text = "\(self.lastBPM!)"
        }
        
        if service.uuid == healthThermometerServiceUUID && self.lastTemp != nil {
           cell.serviceValueLabel.text = "\(self.lastTemp!)"
        }
        
        return cell
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if error != nil {
			print("Error discovering services: \(error?.localizedDescription)")
		}
        
        
        // discover services for each charcteristic of the device.
        // eventually we can skip this using the serviceUUIDS array.
        for service in peripheral.services! {
            services.append(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
		tableView.reloadData()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // TODO: Tell the device to notify us for certain charactersitics. Then update service cell value in table view
        
        if error != nil {
			print("Error discovering service characteristics: \(error?.localizedDescription)")
		}
        
        for characteristic in service.characteristics! {
            print("\(service): \(characteristic)")
            
            if characteristic.uuid == heartRateMeasurementUUID || characteristic.uuid == tempMeasurementUUID {
                self.peripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        /* TODO:    Distinguish between different characteristics using UUIDS.
                    This works now since we set notifications only for
                    the heart rate measurement characteristic.
         */
        
        if characteristic.uuid == heartRateMeasurementUUID {
            let data = characteristic.value!      // of type NSData
            
            // construct an array of N elements, where N = data.length, with initial values of 0
            var values = [UInt8](repeating: 0, count: data.count)
            
            // copy data.length number of bytes into values array
            (data as NSData).getBytes(&values, length: data.count)
            
            let bpm = values[1]
            print("BPM: \(bpm)")
            self.lastBPM = bpm
        }
        
        if characteristic.uuid == tempMeasurementUUID {
             let data = characteristic.value!      // of type NSData
            
            // construct an array of N elements, where N = data.length, with initial values of 0
            var values = [UInt8](repeating: 0, count: data.count)
            
            // copy data.length number of bytes into values array
            (data as NSData).getBytes(&values, length: data.count)
            
            let temp = values[1]
            print("Temp: \(temp)")
            self.lastTemp = temp
        }
       
        tableView.reloadData()
    }
}










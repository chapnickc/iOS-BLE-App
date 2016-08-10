//
//  ViewController.swift
//  EpilepsyMonitor
//
//  Created by chapnickc on 8/10/16.
//  Copyright © 2016 Chad. All rights reserved.
//

import UIKit
import CoreBluetooth


struct DisplayPeripheral{
	var peripheral: CBPeripheral?
	var lastRSSI: NSNumber?
	var isConnectable: Bool?
}


class ViewController: UIViewController, UITableViewDataSource, CBCentralManagerDelegate {

    var centralManager: CBCentralManager?
    var peripherals: [DisplayPeripheral] = []
    var viewReloadTimer: NSTimer?
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
		centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		viewReloadTimer =
            NSTimer.scheduledTimerWithTimeInterval(1.0,
                                                   target: self,
                                                   selector: #selector(ViewController.refreshScanView),
                                                   userInfo: nil,
                                                   repeats: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		viewReloadTimer?.invalidate()
	}
    
    func refreshScanView() {
        if peripherals.count > 1 && centralManager!.isScanning {
            tableView.reloadData()
		}
    }

    @IBAction func scanButtonPressed(sender: AnyObject) {
        if centralManager!.isScanning {
			centralManager?.stopScan()
		}
        else {
			startScanning()
		}
    }
    
    // MARK: CBCentralManagerDelegate
    
   	func startScanning(){
        print("Starting Scan")
		peripherals = []
		self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        let triggerTime = (Int64(NSEC_PER_SEC) * 10)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime),
		               dispatch_get_main_queue(),
		               { () -> Void in
                            if self.centralManager!.isScanning {
                                self.centralManager?.stopScan()
                            }
                       })
	}
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if (central.state == CBCentralManagerState.PoweredOn) {
            startScanning()
        }
        else {
            print("Please Enable Bluetooth")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    	for (index, foundPeripheral) in peripherals.enumerate(){
			if foundPeripheral.peripheral?.identifier == peripheral.identifier {
				peripherals[index].lastRSSI = RSSI
				return
			}
		}
        
		let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
		let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
		peripherals.append(displayPeripheral)
		tableView.reloadData()
        print("Added \(peripheral.name)")
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceTableViewCell", forIndexPath: indexPath) as! DeviceTableViewCell
        
        cell.displayPeripheral = peripherals[indexPath.row]
        return cell
    }
}


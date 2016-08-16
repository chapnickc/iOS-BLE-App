//
//  ScanningViewController.swift
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


class ScanningViewController: UIViewController, UITableViewDataSource {
    
    // Interface Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanningButton: ScanButton!

    // BLE
    var centralManager: CBCentralManager?
    var selectedPeripheral: CBPeripheral?
    var peripherals: [DisplayPeripheral] = []
    
    // for view refresh time
    var viewReloadTimer: NSTimer?
   
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
                                                   selector: #selector(ScanningViewController.refreshScanView),
                                                   userInfo: nil,
                                                   repeats: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		viewReloadTimer?.invalidate()
	}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /* Pass the selectedPeripheral to the destinationViewController */
        
        if segue.identifier == "PeripheralConnectedSegue" {
            if let dashboardViewController = segue.destinationViewController as? DashboardViewController {
               dashboardViewController.peripheral = selectedPeripheral
            }
        }
        
//        if let destinationViewController = segue.destinationViewController as? DashboardViewController {
//           destinationViewController.peripheral = selectedPeripheral
//        }
    }
    
    // MARK: Scanning Functions
    
    func refreshScanView() {
        if peripherals.count > 1 && centralManager!.isScanning {
            tableView.reloadData()
		}
    }
    
    func updateViewForScanning(){
        scanningButton.buttonColorScheme(true)
    }
    
    func updateViewForStopScanning(){
        scanningButton.buttonColorScheme(false)
    }
    
    // MARK: Interface Actions

    @IBAction func scanningButtonPressed(sender: AnyObject) {
        if centralManager!.isScanning {
			centralManager?.stopScan()
            updateViewForStopScanning()
		}
        else {
			startScanning()
		}
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
        cell.delegate = self
        return cell
    }
}


extension ScanningViewController: DeviceCellDelegate {
    
	func connectPressed(peripheral: CBPeripheral) {
        /*
         Check if the selected peripheral is connected. 
         If not reassign selectedPeripheral, set peripheral's delegate property and
         connect to the peripheral.
        */
        
		if peripheral.state != .Connected {
			selectedPeripheral = peripheral
			peripheral.delegate = self
			centralManager?.connectPeripheral(peripheral, options: nil)
		}
        
        if peripheral.state == .Connected {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
	}
}



extension ScanningViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: CBCentralManagerDelegate
    
   	func startScanning(){
        print("Starting Scan")
		peripherals = []
		self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        updateViewForScanning()
        let triggerTime = (Int64(NSEC_PER_SEC) * 10)
        
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime),
		               dispatch_get_main_queue(),
		               { () -> Void in
                            if self.centralManager!.isScanning {
                                self.centralManager?.stopScan()
                                self.updateViewForStopScanning()
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
    }
    
    
    // MARK: CBPeripheralDelegate
    
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("Error connecting peripheral: \(error?.localizedDescription)")
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		print("Connected to \(peripheral.name)")
        performSegueWithIdentifier("PeripheralConnectedSegue", sender: self)
		peripheral.discoverServices(nil)
	}
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Canceled connection to \(peripheral.name)")
    }
}





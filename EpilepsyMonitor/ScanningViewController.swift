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
    var viewReloadTimer: Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
		centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewReloadTimer =
            Timer.scheduledTimer(timeInterval: 1.0,
                                                   target: self,
                                                   selector: #selector(ScanningViewController.refreshScanView),
                                                   userInfo: nil,
                                                   repeats: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewReloadTimer?.invalidate()
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* Pass the selectedPeripheral to the destinationViewController */
        
        if segue.identifier == "PeripheralConnectedSegue" {
            if let dashboardViewController = segue.destination as? DashboardViewController {
               dashboardViewController.peripheral = selectedPeripheral
            }
        }
    }
    
    // MARK: Scanning Functions
    
    func refreshScanView() {
        /*  Reloads the table data if the central manager 
            is scanning for devices and there is more than one peripheral.
        */
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

    @IBAction func scanningButtonPressed(_ sender: AnyObject) {
        if centralManager!.isScanning {
			centralManager?.stopScan()
            updateViewForStopScanning()
		}
        else {
			startScanning()
		}
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        
       
        cell.displayPeripheral = peripherals[(indexPath as NSIndexPath).row]
        cell.delegate = self
        return cell
    }
}


extension ScanningViewController: DeviceCellDelegate {
    
	func connectPressed(_ peripheral: CBPeripheral) {
        /*
         Check if the selected peripheral is connected. 
         If not reassign selectedPeripheral, set peripheral's delegate property and
         connect to the peripheral.
        */
        
		if peripheral.state != .connected {
			selectedPeripheral = peripheral
			peripheral.delegate = self
			centralManager?.connect(peripheral, options: nil)
		}
        
        if peripheral.state == .connected {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
	}
}



extension ScanningViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: CBCentralManagerDelegate
    
   	func startScanning(){
        print("Starting Scan")
		peripherals = []
		self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        updateViewForScanning()
        let triggerTime = (Int64(NSEC_PER_SEC) * 10)
        
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC),
		               execute: { () -> Void in
                            if self.centralManager!.isScanning {
                                self.centralManager?.stopScan()
                                self.updateViewForStopScanning()
                            }
                       })
	}
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state ==  .poweredOn) {
            startScanning()
        }
        else {
            print("Please Enable Bluetooth")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    	for (index, foundPeripheral) in peripherals.enumerated(){
			if foundPeripheral.peripheral?.identifier == peripheral.identifier {
				peripherals[index].lastRSSI = RSSI
				return
			}
		}
        
		let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
		let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        
        if peripheral.name != nil {
    		peripherals.append(displayPeripheral)
    		tableView.reloadData()
        }
        
    }
    
    
    // MARK: CBPeripheralDelegate
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        /*  Go to the dashboard for the connected peripheral. 
         *  Refer to the perpareForSegue() method above for more details.
         */
		print("Connected to \(peripheral.name)")
        performSegue(withIdentifier: "PeripheralConnectedSegue", sender: self)
	}
    
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print("Error connecting peripheral: \(error?.localizedDescription)")
	}
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Canceled connection to \(peripheral.name)")
    }
}





//
//  TableViewController.swift
//  BluIDSDK Sample App
//
//  Created by developer on 23/04/21.
//

import UIKit
import BluIDSDK
import CoreData

class TableViewController: UITableViewController {    
    var m_bluIDSDK:BluIDSDK?
    var m_isScanning:Bool  = false
    var m_onback: (() -> Void)?
    var m_onDeviceDisconnect: (() -> Void)?
    var m_onDeviceConnected:((Device_Information) -> Void)?
    public var m_arrayOfBluPOINTDevices: [Device_Information]?
    var m_selectedDevice:Device_Information?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "DiscoveredPeripheralCell", bundle: nil), forCellReuseIdentifier: "DiscoveredPeripheralCell")
    }
    public func setBluIDSDK(sdk: BluIDSDK){
        m_bluIDSDK=sdk;
    }
    
    func startScanning(){
        do {
            try m_bluIDSDK?.startDeviceDiscovery(filter: GlobalProperties.SCAN_FILTER, onDeviceDiscovered: self.deviceDiscoveredCallback)
            m_isScanning = true
        } catch {
            debugPrint(error)
        }
    }
    
    func deviceDiscoveredCallback(arrayOfDevices: [Device_Information]) -> Void{
        m_arrayOfBluPOINTDevices = arrayOfDevices
        DispatchQueue.main.async {
            guard self.viewIfLoaded?.window != nil else {
                return
            }
            self.tableView.reloadData()
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "LIST OF BluPOINT DEVICES"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let arrayOfDevices=m_arrayOfBluPOINTDevices{
            return arrayOfDevices.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell",for: indexPath) as! DiscoveredPeripheralCell
        if let arrayOfDevices = m_arrayOfBluPOINTDevices, !arrayOfDevices.isEmpty, indexPath.row < arrayOfDevices.count {
            let device :Device_Information = arrayOfDevices[indexPath.row]
            DispatchQueue.main.async {
                cell.rssiLabel.text="\(device.signalStrength)"
                cell.identifierLabel.text=device.name
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let arrOfDevices = m_arrayOfBluPOINTDevices, !arrOfDevices.isEmpty, indexPath.row < arrOfDevices.count else {
            return
        }
        m_selectedDevice = arrOfDevices[indexPath.row]
        if let _selectedDevice = m_selectedDevice{
            m_onDeviceConnected?(_selectedDevice)
        }
    }
    func foundCharacteristicSendData(found: Bool, details:Device_Details?){
        print("found\(details?.name as String?)");
        if(found){
            print("found");
            if let _selectedDevice = m_selectedDevice {
                m_onDeviceConnected?(_selectedDevice)
            }
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func ListBackButton(_ sender: Any) {
        m_onback?()
    }
}

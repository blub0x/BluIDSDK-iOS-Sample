//
//  MultipleDeviceUpdateViewController.swift
//  BluIDSDK Sample App
//
//  Created by developer on 11/06/21.
//

import UIKit
import BluIDSDK
class MultipleDeviceUpdateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var m_unselectedBluPOINTDevices: [Device_Information]?
    public var m_selectedBluPOINTDevices: [Device_Information]?
    var m_onDoneClicked:(([Device_Information ])->Void)?
    var m_onCancelClicked:(()->Void)?
    var m_BluIDSDKClient:BluIDSDK?
    var m_isScanning:Bool  = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == m_unSelectedDeviceTableView{
            if let arrOfBluPOINTDevices = m_unselectedBluPOINTDevices{
                return arrOfBluPOINTDevices.count
            }
        }else  if tableView == m_selectedDeviceTableView{
            if let arrOfBluPOINTDevices = m_selectedBluPOINTDevices{
                return arrOfBluPOINTDevices.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell",for: indexPath) as! DiscoveredPeripheralCell
        if tableView == m_unSelectedDeviceTableView{
            if let arrOfBluPOINTDevices = m_unselectedBluPOINTDevices, !arrOfBluPOINTDevices.isEmpty,
               indexPath.row < arrOfBluPOINTDevices.count {
                print("1")
                DispatchQueue.main.async {
                    cell.identifierLabel.text=arrOfBluPOINTDevices[indexPath.row].name
                    cell.rssiLabel.text="\(arrOfBluPOINTDevices[indexPath.row].signalStrength)"
                }
            }
        }else if tableView == m_selectedDeviceTableView{
            if let arrOfBluPOINTDevices = m_selectedBluPOINTDevices, !arrOfBluPOINTDevices.isEmpty,
               indexPath.row < arrOfBluPOINTDevices.count {
                print("2")
                DispatchQueue.main.async {
                    cell.identifierLabel.text=arrOfBluPOINTDevices[indexPath.row].name
                    cell.rssiLabel.text="\(arrOfBluPOINTDevices[indexPath.row].signalStrength)"
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == m_unSelectedDeviceTableView{
            return "UNSELECTED BluPOINT DEVICES"
        }else if tableView == m_selectedDeviceTableView{
            return "SELECTED BluPOINT DEVICES"
        }
        return ""
    }
    
    lazy var m_unSelectedDeviceTableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.register(UINib(nibName: "DiscoveredPeripheralCell", bundle: nil), forCellReuseIdentifier: "DiscoveredPeripheralCell")
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    lazy var m_selectedDeviceTableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.register(UINib(nibName: "DiscoveredPeripheralCell", bundle: nil), forCellReuseIdentifier: "DiscoveredPeripheralCell")
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    @IBOutlet weak var m_navigationBar: UINavigationBar!
    
    // Do any additional setup after loading the view.
    
    override func viewDidLoad() {
        self.view.addSubview(m_unSelectedDeviceTableView)
        self.m_unSelectedDeviceTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.m_unSelectedDeviceTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.m_unSelectedDeviceTableView.topAnchor.constraint(equalTo: self.m_navigationBar.bottomAnchor, constant: 0).isActive = true
        self.m_unSelectedDeviceTableView.heightAnchor.constraint(equalToConstant: (self.view.frame.height/3)).isActive = true
        
        self.view.addSubview(m_selectedDeviceTableView)
        self.m_selectedDeviceTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.m_selectedDeviceTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.m_selectedDeviceTableView.topAnchor.constraint(equalTo: self.m_unSelectedDeviceTableView.bottomAnchor, constant: 0).isActive = true
        self.m_selectedDeviceTableView.heightAnchor.constraint(equalToConstant: (self.view.frame.height/3)).isActive = true
        m_selectedBluPOINTDevices = []
        m_unselectedBluPOINTDevices = []
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    public func setBluIDSDK(sdk: BluIDSDK){
        m_BluIDSDKClient=sdk;
    }
    
    func startScanning(){
        do {
            try m_BluIDSDKClient?.startDeviceDiscovery(filter: GlobalProperties.SCAN_FILTER, onDeviceDiscovered: self.deviceDiscoveredCallback)
            m_isScanning = true
        } catch {
            debugPrint(error)
        }
    }
    
    func deviceDiscoveredCallback(arrayOfDevices: [Device_Information]) -> Void{
        let answer = arrayOfDevices.filter{ item in !(m_selectedBluPOINTDevices?.contains(where: {$0.id == item.id}))! }
        m_unselectedBluPOINTDevices=answer
        DispatchQueue.main.async {
            guard self.viewIfLoaded?.window != nil else {
                return
            }
            self.m_unSelectedDeviceTableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == m_unSelectedDeviceTableView, let temp = m_unselectedBluPOINTDevices, !temp.isEmpty,
           indexPath.row < temp.count {
            m_selectedBluPOINTDevices?.append(m_unselectedBluPOINTDevices![indexPath.row])
            m_unselectedBluPOINTDevices?.remove(at: indexPath.row)
        }
        else if tableView == m_selectedDeviceTableView, let temp = m_selectedBluPOINTDevices, !temp.isEmpty,
                indexPath.row < temp.count{
            m_unselectedBluPOINTDevices?.append(m_selectedBluPOINTDevices![indexPath.row])
            m_selectedBluPOINTDevices?.remove(at: indexPath.row)
        }
        m_unSelectedDeviceTableView.reloadData()
        m_selectedDeviceTableView.reloadData()
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        guard m_selectedBluPOINTDevices != nil else {
            return
        }
        let selectedBluPOINTDevicesID = m_selectedBluPOINTDevices!.filter{ $0.id != "" }
        print(selectedBluPOINTDevicesID) // prints [1, 2, 4]
        m_onDoneClicked!(selectedBluPOINTDevicesID)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        m_onCancelClicked!()
    }
}


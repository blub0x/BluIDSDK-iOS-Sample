//
//  FirmwareTableViewController.swift
//  BluIDSDK Sample App
//
//  Created by developer on 26/05/21.
//

import UIKit
import BluIDSDK

class FirmwareTableViewController: UITableViewController {
    var m_selectedFirmware:Device_Firmware?
    var m_onDoneClicked:((Device_Firmware)->Void)?
    var m_onMultipleDeviceDoneClicked:(([Device_Information], Device_Firmware)->Void)?
    var m_onCancelClicked:(()->Void)?
    var m_deviceList: [Device_Information]?
    var m_BluIDSDKClient:BluIDSDK?
    var m_arrayOfFirmareFiles:[Device_Firmware]?
    func setDeviceList(devicelist:[Device_Information]){
        m_deviceList = devicelist
    }
    
    public func setBluIDSDK(sdk: BluIDSDK){
        m_BluIDSDKClient=sdk
    }
    @IBAction func FirmwareSelectDoneButtonPressed(_ sender: Any) {
        if let selectedFirmware = self.m_selectedFirmware{
            if !selectedFirmware.isDownloaded {
                CommonUtils.showConfirmPopup(view: self, title: "Download", message: "This firmware version is not available on phone. Do you want to download?") {
                    let progressBar = CommonUtils.showProgressBar(view: self, message: "Downloading")
                    self.m_BluIDSDKClient?.downloadFirmware(version: selectedFirmware.version, onComplete: { error in
                        CommonUtils.dismissProgressBar(progressBar: progressBar) {
                        }
                        if let error = error {
                            CommonUtils.showMessage(view: self, title: "Error", message: "Download Failure!\n\(error.localizedDescription)")
                        }
                        self.processUpdateFirmware(firmware: selectedFirmware)
                    })
                } onNegative: {
                }
                return
            }
            processUpdateFirmware(firmware: selectedFirmware)
        }
    }
    
    func processUpdateFirmware(firmware:Device_Firmware) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let deviceList = self.m_deviceList{
                self.m_onMultipleDeviceDoneClicked!(deviceList, firmware)
                self.m_deviceList = nil
            }else{
                self.m_onDoneClicked!(firmware)
            }
        }
    }
    
    @IBAction func CancelbuttonClicked(_ sender: Any) {
        m_selectedFirmware = nil
        m_onCancelClicked!()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "FirmwareTableViewCell", bundle: nil), forCellReuseIdentifier: "FirmwareTableViewCell")
        
    }
    func onEnter(){
        m_BluIDSDKClient?.listAvailableFirmwareVersions(onResponse: firmwareListCallback)
    }
    
    func firmwareListCallback(firmwareList: [Device_Firmware]?){
        print("firmwareList?.count\(firmwareList?.count as Int?)")
        m_arrayOfFirmareFiles=firmwareList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "LIST OF AVAILABLE FIRMWARE"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrayOfFirmareFiles=m_arrayOfFirmareFiles{
            return arrayOfFirmareFiles.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirmwareTableViewCell",for: indexPath) as! FirmwareTableViewCell
        if let arrayOfFirmareFiles = m_arrayOfFirmareFiles, !arrayOfFirmareFiles.isEmpty, indexPath.row < arrayOfFirmareFiles.count {
            let firmware = arrayOfFirmareFiles[indexPath.row]
            DispatchQueue.main.async {
                cell.firmwareName.text=firmware.version
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell")
        guard let arrayOfFwFiles = m_arrayOfFirmareFiles, !arrayOfFwFiles.isEmpty, indexPath.row < arrayOfFwFiles.count else {
            return
        }
        let selectedFirmware = m_arrayOfFirmareFiles![indexPath.row]
        self.m_selectedFirmware = selectedFirmware
    }
}

//
//  MainScreenViewController.swift
//  BluIDSDK Sample App
//
//  Created by Akhil Kumar on 26/06/21.
//

import Foundation
import UIKit
import BluIDSDK

class MainScreenViewController: UITableViewController{
    var m_isUnlocked = false
    var m_buzzerTimeoutInSec:UInt8 = 2
    var m_BluIDSDKClient:BluIDSDK?
    var m_deviceList:[Device_Information] = []
    var m_selectedDevice:Device_Information?
    var m_actionToPerform: ((BleRole) -> Void)?
    var m_onEnvironmentChange: ((BluIDSDK_Environment) -> Void)?
    var m_onGetFirmwareList: (([Device_Firmware]?) -> Void)?
    var m_onMultiUpdateFirmwareButtonPressed: (() -> Void)?
    var m_autoTransferDB = AutoTransferSettings()
    internal var m_generalUserSettings:UserPreferences?
    internal let m_gestureModes = [AllowAccessType.foreground.toString(), AllowAccessType.phoneUnlocked.toString(), AllowAccessType.always.toString()]
    internal let m_gestureTypes = ["Tap", "Twist", "In Range", "AI", "Apple Watch", "BluREMOTE", "App Specific", "Wave", "Enhanced Tap"]
    internal let m_deviceStateLEDColors = [
        "Red": Device_LED_Color(red: 0xFF, green: 0, blue: 0),
        "Green": Device_LED_Color(red: 0, green: 0xFF, blue: 0),
        "Blue": Device_LED_Color(red: 0, green: 0, blue: 0xFF),
        "Amber": Device_LED_Color(red: 0xFF, green: 0xBF, blue: 0),
        "Cyan": Device_LED_Color(red: 0, green: 0xFF, blue: 0xFF),
        "Magenta": Device_LED_Color(red: 0xFF, green: 0, blue: 0xFF),
        "White": Device_LED_Color(red: 0xFF, green: 0xFF, blue: 0xFF),
        "HostControlled": Device_LED_Color(red: 0x80, green: 0x80, blue: 0x80),
        "Off": Device_LED_Color(red: 0, green: 0, blue: 0)
    ]
    internal let m_bluIDSDK_Environment = [
        BluIDSDK_Environment.production.rawValue : BluIDSDK_Environment.production,
        BluIDSDK_Environment.qa.rawValue : BluIDSDK_Environment.qa,
        BluIDSDK_Environment.qatest2.rawValue : BluIDSDK_Environment.qatest2,
        BluIDSDK_Environment.qatest3.rawValue : BluIDSDK_Environment.qatest3
    ]
    var m_environmentDB:BluIDSDKEnvironmentDB?
    
    @IBOutlet weak var m_loginLabel: UILabel!
    @IBOutlet weak var m_userNameLabel: UILabel!
    @IBOutlet weak var m_selectedDeviceDetails: UILabel!
    @IBOutlet weak var m_rebootButton: UIButton!
    @IBOutlet weak var m_disconnectButton: UIButton!
    @IBOutlet weak var m_multiDeviceButton: UIButton!
    @IBOutlet weak var m_singleDeviceButton: UIButton!
    @IBOutlet weak var m_progressBar: UIProgressView!
    @IBOutlet weak var m_progressLabel: UILabel!
    @IBOutlet weak var m_deviceNameButton: UIButton!
    @IBOutlet weak var m_deviceNameText: UITextField!
    @IBOutlet weak var m_bleStepper: UIStepper!
    @IBOutlet weak var m_bleStrengthLabel: UILabel!
    @IBOutlet weak var m_ledSwitch: UISwitch!
    @IBOutlet weak var m_ringBuzzerSwitch: UISwitch!
    @IBOutlet weak var m_unlockTableCell: UITableViewCell!
    @IBOutlet weak var m_transferCredentialsTableCell: UITableViewCell!
    @IBOutlet weak var m_loginTableCell: UITableViewCell!
    @IBOutlet weak var m_scanBluPOINTTableCell: UITableViewCell!
    @IBOutlet weak var m_tapSwitch: UISwitch!
    @IBOutlet weak var m_tapStepper: UIStepper!
    @IBOutlet weak var m_tapLabel: UILabel!
    @IBOutlet weak var m_twistSwitch: UISwitch!
    @IBOutlet weak var m_twistStepper: UIStepper!
    @IBOutlet weak var m_twistLabel: UILabel!
    @IBOutlet weak var m_inRangeSwitch: UISwitch!
    @IBOutlet weak var m_inRangeStepper: UIStepper!
    @IBOutlet weak var m_inRangeLabel: UILabel!
    @IBOutlet weak var m_debuLogsSwitch: UISwitch!
    @IBOutlet weak var m_debugLogsLabel: UITextView!
    @IBOutlet weak var m_sdkVersionLabel: UILabel!
    @IBOutlet weak var m_vibrateSwitch: UISwitch!
    @IBOutlet weak var m_autoTransferSwitch: UISwitch!
    @IBOutlet weak var m_allowTypeButton: UIButton!
    @IBOutlet weak var m_tapSetButton: UIButton!
    @IBOutlet weak var m_twistSetButton: UIButton!
    @IBOutlet weak var m_inRangeSetButton: UIButton!
    @IBOutlet weak var m_appSpecificSetButton: UIButton!
    @IBOutlet weak var m_appSpecificSwitch: UISwitch!
    @IBOutlet weak var m_appSpecificStepper: UIStepper!
    @IBOutlet weak var m_appSpecificValueLabel: UILabel!
    @IBOutlet weak var m_waveSetButton: UIButton!
    @IBOutlet weak var m_waveSwitch: UISwitch!
    @IBOutlet weak var m_waveStepper: UIStepper!
    @IBOutlet weak var m_waveValueLabel: UILabel!
    @IBOutlet weak var m_aiSetButton: UIButton!
    @IBOutlet weak var m_aiSwitch: UISwitch!
    @IBOutlet weak var m_aiStepper: UIStepper!
    @IBOutlet weak var m_aiValueLabel: UILabel!
    @IBOutlet weak var m_appleWatchSetButton: UIButton!
    @IBOutlet weak var m_appleWatchSwitch: UISwitch!
    @IBOutlet weak var m_appleWatchStepper: UIStepper!
    @IBOutlet weak var m_appleWatchValueLabel: UILabel!
    @IBOutlet weak var m_BluREMOTESwitch: UISwitch!
    @IBOutlet weak var m_BluREMOTESetButton: UIButton!
    @IBOutlet weak var m_BluREMOTEStepper: UIStepper!
    @IBOutlet weak var m_BluREMOTEValueLabel: UILabel!
    @IBOutlet weak var m_enhancedTapSetButton: UIButton!
    @IBOutlet weak var m_enhancedTapSwitch: UISwitch!
    @IBOutlet weak var m_iOSBackgroundStepper: UIStepper!
    @IBOutlet weak var m_iOSBackgroundValueLabel: UILabel!
    @IBOutlet weak var m_iOSForegroundStepper: UIStepper!
    @IBOutlet weak var m_iOSForegroundValueLabel: UILabel!
    @IBOutlet weak var m_androidStepper: UIStepper!
    @IBOutlet weak var m_androidValueLabel: UILabel!
    @IBOutlet weak var m_userTapSwitch: UISwitch!
    @IBOutlet weak var m_userTwistSwitch: UISwitch!
    @IBOutlet weak var m_userInRangeSwitch: UISwitch!
    @IBOutlet weak var m_bleSampleDeviceNameText: UITextField!
    @IBOutlet weak var m_sampleSelectedGestureButton: UIButton!
    @IBOutlet weak var m_idleLEDColorButton: UIButton!
    @IBOutlet weak var m_inUseLEDColorButton: UIButton!
    @IBOutlet weak var m_factoryResetTableCell: UITableViewCell!
    @IBOutlet weak var m_environmentButton: UIButton!
    
    
    override func viewDidLoad() {
        if m_autoTransferDB.isOn() == true {
            do {
                try m_BluIDSDKClient?.startDeviceDiscovery(filter: GlobalProperties.SCAN_FILTER, onDeviceDiscovered: { devices in
                })
                self.m_BluIDSDKClient?.startGestureBasedAuthentication()
                DispatchQueue.main.async {
                    self.m_autoTransferSwitch.isOn = true
                }
            } catch {
                debugPrint(error)
            }
        }
        if let userSettings =  m_generalUserSettings {
            m_allowTypeButton.setTitle(userSettings.allowAccess.toString(), for: .normal)
        }
        if let sdkEnvironment = m_environmentDB?.getEnvironment().rawValue {
            m_environmentButton.setTitle(sdkEnvironment, for: .normal)
        }
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableView.cellForRow(at: indexPath)
        switch tableCell {
        case m_loginTableCell:
            debugPrint("Login clicked")
            onLoginCellClicked()
        case m_transferCredentialsTableCell:
            debugPrint("Transfer Credentials clicked")
            onTransferCredentials()
        case m_scanBluPOINTTableCell:
            debugPrint("scan BluPOINT device clicked")
            onScanBluPOINTCellClicked()
        case m_unlockTableCell:
            debugPrint("unlock clicked")
            onUnlockBluPOINTDevice()
        case m_factoryResetTableCell:
            debugPrint("Factory reset BluPOINT clicked")
            factoryResetBluPOINTDevice()
        default:
            print("You selected cell #\(indexPath.item)!")
        }
        tableCell?.setSelected(false, animated: true)
    }
    
    @IBAction func onAutoTransfer(_ sender: UISwitch) {
        if sender.isOn {
            m_actionToPerform?(.AutoTransfer)
            m_BluIDSDKClient?.startGestureBasedAuthentication()
        }else {
            m_BluIDSDKClient?.stopGestureBasedAuthentication()
        }
        m_autoTransferDB.save(on: sender.isOn)
        
    }
    @IBAction func onReboot(_ sender: UIButton) {
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Rebooting Device")
        m_BluIDSDKClient?.rebootDevice(afterSeconds: nil, onDisconnect: { (error, id) in
            if let error = error {
                print(error)
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    CommonUtils.showMessage(view: self, title: "Reboot Failed", message: "\(error)\n\(error.localizedDescription)")
                }
                return
            }
            CommonUtils.dismissProgressBar(progressBar: progressBar) {}
            self.m_selectedDevice = nil
            self.disconnectUI()
        })
    }
    @IBAction func onDisconnect(_ sender: UIButton) {
        m_BluIDSDKClient?.lockDeviceAccess()
        m_selectedDevice = nil
        disconnectUI()
    }
    @IBAction func onMultiDeviceFlash(_ sender: UIButton) {
        m_onMultiUpdateFirmwareButtonPressed?()
    }
    @IBAction func onSingleDeviceFlash(_ sender: UIButton) {
        m_onGetFirmwareList?(nil)
    }
    @IBAction func onDeviceNameSubmit(_ sender: UIButton) {
        guard let name = m_deviceNameText.text, !name.isEmpty, name.count < 9 else {
            CommonUtils.showMessage(view: self, title: "Invalid Name", message: "Name should be upto 8 character and non empty")
            return
        }
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Name")
        m_BluIDSDKClient?.updateDeviceName(name: name, onResponse: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Failed", message: "Name Updation Failed\n\(error)")
                    return
                }
            }
        })
    }
    @IBAction func onBLEStrengthChanged(_ sender: UIStepper) {
        m_BluIDSDKClient?.updateDeviceBLETxPowerLevel(strength: UInt8(sender.value), callback: { (error, data) in
            DispatchQueue.main.async {
                if let _error = error {
                    print("error\(_error)")
                    if let numberValue = self.m_bleStrengthLabel.text, let previousValue = Int(numberValue) {
                        sender.value = Double(previousValue)
                    }
                    CommonUtils.showMessage(view: self, title: "Failure", message: "\(_error)\n\(_error.localizedDescription)")
                }else{
                    if let data = data{
                        self.m_bleStrengthLabel.text = "\(data)"
                    }
                }
            }
        })
    }
    @IBAction func onLEDSwitch(_ sender: UISwitch) {
        if sender.isOn {
            m_BluIDSDKClient?.identifyDevice(withLED: Device_LED(color: Device_LED_Color(red: 0, green: 0xff, blue: 0), onTimeInSeconds: 5), onResponse: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    CommonUtils.showMessage(view: self, title: "Failed", message: "Glow LED failed\n\(error)")
                }
                DispatchQueue.main.async {
                    sender.isOn = false
                }
            })
        }
    }
    @IBAction func onRingBuzzerSwitch(_ sender: UISwitch) {
        if sender.isOn {
            m_BluIDSDKClient?.identifyDevice(withBuzzerONInSeconds: m_buzzerTimeoutInSec, onResponse: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    CommonUtils.showMessage(view: self, title: "Failed", message: "Ring buzzer failed\n\(error)")
                }
                DispatchQueue.main.async {
                    sender.isOn = false
                }
            })
        }
    }
    
    @IBAction func onEndBLENameEdit(_ sender: UITextField) {
        view.endEditing(true)
    }
    @IBAction func onEndNameEdit(_ sender: UITextField) {
        view.endEditing(true)
    }
    @IBAction func onTapSwitchClicked(_ sender: UISwitch) {
    }
    @IBAction func onTapStepperChanged(_ sender: UIStepper) {
        let power = Int(sender.value)
        m_tapLabel.text = "\(power)"
    }
    @IBAction func onTapUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_tapSwitch.isOn, power: Int(m_tapStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Tap\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.tap,setting: settings, callback: { error in
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    if let error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                }
            })
    }
    @IBAction func onTwistSwitchClicked(_ sender: UISwitch) {
    }
    @IBAction func onTwistStepperChanged(_ sender: UIStepper) {
        let power = Int(sender.value)
        m_twistLabel.text = "\(power)"
    }
    @IBAction func onTwistUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_twistSwitch.isOn, power: Int(m_twistStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Twist\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.twist,setting: settings, callback: { error in
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    if let error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                }
            })
    }
    @IBAction func onInRangeStepperChanged(_ sender: UIStepper) {
        let power = Int(sender.value)
        m_inRangeLabel.text = "\(power)"
    }
    @IBAction func onInRangeUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_inRangeSwitch.isOn, power: Int(m_inRangeStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating InRange\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.inRange,setting: settings, callback: { error in
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    if let error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                }
            })
    }
    @IBAction func onVibrateClicked(_ sender: UISwitch) {
        guard m_generalUserSettings != nil else {
            sender.isOn = false
            return
        }
        m_generalUserSettings?.enableVibrate = sender.isOn
        m_BluIDSDKClient?.saveUserPreference(setting: m_generalUserSettings!)
    }
    @IBAction func onAllowAcceessChange(_ sender: UIButton) {
        guard let gestureSettings = m_generalUserSettings else {
            return
        }
        CommonUtils.showPicker(items: m_gestureModes, activeIndex: m_gestureModes.firstIndex(of: gestureSettings.allowAccess.toString()) ?? 0) { accessText in
            DispatchQueue.main.async {
                self.m_allowTypeButton.setTitle(accessText, for: .normal)
            }
            gestureSettings.allowAccess = AllowAccessType.foreground.toEnum(accessText)
            self.m_BluIDSDKClient?.saveUserPreference(setting: gestureSettings)
        }
    }
    
    @IBAction func onAppSpecificUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_appSpecificSwitch.isOn, power: Int(m_appSpecificStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating AppSpecific\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.appSpecific,setting: settings, callback: { error in
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    if let error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                }
            })
    }
    @IBAction func onAppSpecificStepperChange(_ sender: UIStepper) {
        updateStepperLabel(sender, m_appSpecificValueLabel)
    }
    @IBAction func onWaveUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_waveSwitch.isOn, power: Int(m_waveStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Wave\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.wave,setting: settings, callback: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                }
            }
        })
    }
    @IBAction func onWaveStepperChanged(_ sender: UIStepper) {
        updateStepperLabel(sender, m_waveValueLabel)
    }
    @IBAction func onAIUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_aiSwitch.isOn, power: Int(m_aiStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating AI\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.ai,setting: settings, callback: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                }
            }
        })
    }
    @IBAction func onAIStepperChange(_ sender: UIStepper) {
        updateStepperLabel(sender, m_aiValueLabel)
    }
    @IBAction func onAppleWatchUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_appleWatchSwitch.isOn, power: Int(m_appleWatchStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Apple\nWatch Settings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.appleWatch,setting: settings, callback: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                }
            }
        })
    }
    @IBAction func onAppleWatchStepperChanged(_ sender: UIStepper) {
        updateStepperLabel(sender, m_appleWatchValueLabel)
    }
    @IBAction func onBluREMOTEUpdateClicked(_ sender: UIButton) {
        let settings = GestureSetting(enabled: m_BluREMOTESwitch.isOn, power: Int(m_BluREMOTEStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating BluREMOTE\nSettings..")
        m_BluIDSDKClient?.updateDeviceSettings(gesture:.BluREMOTE,setting: settings, callback: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                }
            }
        })
    }
    @IBAction func onBluREMOTEStepperChange(_ sender: UIStepper) {
        updateStepperLabel(sender, m_BluREMOTEValueLabel)
    }
    @IBAction func onEnhancedTapUpdateClicked(_ sender: UIButton) {
        let settings = EnhancedTapSettings(enabled: m_enhancedTapSwitch.isOn, iosBackgroundPower: Int(m_iOSBackgroundStepper.value),
                                           iosForegroundPower: Int(m_iOSForegroundStepper.value), androidPower: Int(m_androidStepper.value))
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Updating Enhanced\nTap Settings..")
        m_BluIDSDKClient?.updateDeviceSettings(enhanceTapSetting: settings, callback: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                }
            }
        })
    }
    @IBAction func onIOSBackgroundStepperChange(_ sender: UIStepper) {
        updateStepperLabel(sender, m_iOSBackgroundValueLabel)
    }
    @IBAction func onIOSForegroundStepperChanged(_ sender: UIStepper) {
        updateStepperLabel(sender, m_iOSForegroundValueLabel)
    }
    @IBAction func onAndroidStepperChange(_ sender: UIStepper) {
        updateStepperLabel(sender, m_androidValueLabel)
    }
    @IBAction func onUserTapToggled(_ sender: UISwitch) {
        guard m_generalUserSettings != nil else {
            sender.isOn = false
            return
        }
        m_generalUserSettings?.enableTapSetting = sender.isOn
        m_BluIDSDKClient?.saveUserPreference(setting: m_generalUserSettings!)
    }
    @IBAction func onUserTwistToggled(_ sender: UISwitch) {
        guard m_generalUserSettings != nil else {
            sender.isOn = false
            return
        }
        m_generalUserSettings?.enableTwistSetting = sender.isOn
        m_BluIDSDKClient?.saveUserPreference(setting: m_generalUserSettings!)
    }
    @IBAction func onUserInRangeToggled(_ sender: UISwitch) {
        guard m_generalUserSettings != nil else {
            sender.isOn = false
            return
        }
        m_generalUserSettings?.enableRangeSetting = sender.isOn
        m_BluIDSDKClient?.saveUserPreference(setting: m_generalUserSettings!)
    }
    @IBAction func onGestureSelection(_ sender: UIButton) {
        guard let selectedGestureText = m_sampleSelectedGestureButton.titleLabel?.text else {
            return
        }
        CommonUtils.showPicker(items: m_gestureTypes, activeIndex: m_gestureTypes.firstIndex(of: selectedGestureText) ?? 0) { gestureType in
            DispatchQueue.main.async {
                self.m_sampleSelectedGestureButton.setTitle(gestureType, for: .normal)
            }
        }
    }

    @IBAction func onIdleLEDColorClicked(_ sender: UIButton) {
        onDeviceStateLEDColorChange(ledColorButton: sender, deviceState: .idle)
    }
    @IBAction func onInUseLEDColorClicked(_ sender: UIButton) {
        onDeviceStateLEDColorChange(ledColorButton: sender, deviceState: .in_use)
    }
    @IBAction func onEnvironmentChange(_ sender: UIButton) {
        guard let selectedEnvironment = sender.titleLabel?.text else {
            return
        }
        let environmentList = m_bluIDSDK_Environment.compactMap({ (key: String, value: BluIDSDK_Environment) -> String in
            return key
        })
        CommonUtils.showPicker(items: environmentList, activeIndex: environmentList.firstIndex(of: selectedEnvironment) ?? 0) { envSelected in
            guard selectedEnvironment != envSelected else {
                return
            }
            guard let env = self.m_bluIDSDK_Environment[envSelected] else {
                CommonUtils.showMessage(view: self, title: "Error", message: "Selected Environment is unsupported")
                return
            }
            let progressBar = CommonUtils.showProgressBar(view: self, message: "Switching environment")
            self.m_onEnvironmentChange?(env)
            self.m_environmentButton.setTitle(envSelected, for: .normal)
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                
            }
        }
    }
    
    func onDeviceStateLEDColorChange(ledColorButton:UIButton, deviceState:DeviceState) {
        guard let selectedColor = ledColorButton.titleLabel?.text else {
            return
        }
        let colorList = m_deviceStateLEDColors.compactMap({ (key: String, value: Device_LED_Color) -> String in
            return key
        })
        CommonUtils.showPicker(items: colorList, activeIndex: colorList.firstIndex(of: selectedColor) ?? 0) { colorSelected in
            guard let ledColor = self.m_deviceStateLEDColors[colorSelected] else {
                CommonUtils.showMessage(view: self, title: "Error", message: "Selected colour is unsupported")
                return
            }
            let progressBar = CommonUtils.showProgressBar(view: self, message: "Applying LED Colour")
            self.m_BluIDSDKClient?.setDeviceStateLEDColor(forDeviceState: deviceState, color: ledColor, onResponse: { error in
                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    if let error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(error)\n\(error.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        ledColorButton.setTitle(colorSelected, for: .normal)
                    }
                }
            })
        }
    }
    
    func updateStepperLabel(_ sender:UIStepper, _ label:UILabel) {
        let data = Int(sender.value)
        updateLabel(text: "\(data)", label: label)
    }
    func updateLabel(text:String, label:UILabel){
        DispatchQueue.main.async {
            label.text = text
        }
    }
    func onDebugLogs(log:String){
        DispatchQueue.main.async {
            self.m_debugLogsLabel.text = log
        }
    }
    func setGeneralUserSettings(generalUserSettings:UserPreferences) {
        m_generalUserSettings = generalUserSettings
        DispatchQueue.main.async {
            self.m_userTapSwitch.isOn = generalUserSettings.enableTapSetting
            self.m_userTwistSwitch.isOn = generalUserSettings.enableTwistSetting
            self.m_userInRangeSwitch.isOn = generalUserSettings.enableRangeSetting
            self.m_vibrateSwitch.isOn = generalUserSettings.enableVibrate
        }
    }
    
    func updateStepperUI(value:Int, stepper:UIStepper, label:UILabel){
        label.text = "\(value)"
        stepper.value = Double(value)
    }
    
    func updateGestureUI(bleSettings:GestureSetting, label:UILabel, toggle:UISwitch, stepper:UIStepper){
        updateStepperUI(value: bleSettings.power, stepper: stepper, label: label)
        toggle.isOn = bleSettings.enabled
    }
    
    func setUserNameLoggedIn(loginStr: String){
        onLogin(userName: loginStr)
    }
    
    func setSelectedDevice(device:Device_Information) {
        m_selectedDevice = device
        guard let firmwareVersion = device.firmwareVersion,let tap = device.tapSettings, let twist = device.twistSettings, let range = device.rangeSettings, let appSpecific = device.appSpecificSettings, let wave = device.waveSettings, let ai = device.aiSettings, let appleWatch = device.appleWatchSettings, let BlueREMOTE = device.BluREMOTESettings, let enhancedTap = device.enhancedTapSettings else {
            self.m_selectedDeviceDetails.text = "\(device.name)"
            return
        }
        if m_isUnlocked {
            enableAdminControls(false)
            enableFirmwareWidgets(false)
        }
        DispatchQueue.main.async {
            self.m_selectedDeviceDetails.text = "\(device.name)\nv\(firmwareVersion)"
            self.m_deviceNameText.text = device.name
            self.updateGestureUI(bleSettings: tap, label: self.m_tapLabel, toggle: self.m_tapSwitch, stepper: self.m_tapStepper)
            self.updateGestureUI(bleSettings: twist, label: self.m_twistLabel, toggle: self.m_twistSwitch, stepper: self.m_twistStepper)
            self.updateGestureUI(bleSettings: range, label: self.m_inRangeLabel, toggle: self.m_inRangeSwitch, stepper: self.m_inRangeStepper)
            self.updateGestureUI(bleSettings: appSpecific, label: self.m_appSpecificValueLabel, toggle: self.m_appSpecificSwitch, stepper: self.m_appSpecificStepper)
            self.updateGestureUI(bleSettings: wave, label: self.m_waveValueLabel, toggle: self.m_waveSwitch, stepper: self.m_waveStepper)
            self.updateGestureUI(bleSettings: ai, label: self.m_aiValueLabel, toggle: self.m_aiSwitch, stepper: self.m_aiStepper)
            self.updateGestureUI(bleSettings: appleWatch, label: self.m_appleWatchValueLabel, toggle: self.m_appleWatchSwitch, stepper: self.m_appleWatchStepper)
            self.updateGestureUI(bleSettings: BlueREMOTE, label: self.m_BluREMOTEValueLabel, toggle: self.m_BluREMOTESwitch, stepper: self.m_BluREMOTEStepper)
            self.m_enhancedTapSwitch.isOn = enhancedTap.enabled
            self.m_iOSBackgroundStepper.value = Double(enhancedTap.iosBackgroundPower)
            self.updateStepperLabel(self.m_iOSBackgroundStepper, self.m_iOSBackgroundValueLabel)
            self.m_iOSForegroundStepper.value = Double(enhancedTap.iosForegroundPower)
            self.updateStepperLabel(self.m_iOSForegroundStepper, self.m_iOSForegroundValueLabel)
            self.m_androidStepper.value = Double(enhancedTap.androidPower)
            self.updateStepperLabel(self.m_androidStepper, self.m_androidValueLabel)
        }
    }
    
    func setDeviceSelectLabel(deviceSelectStr: String){
        if m_isUnlocked {
            enableAdminControls(false)
            enableFirmwareWidgets(false)
        }
        DispatchQueue.main.async {
            self.m_selectedDeviceDetails.text = deviceSelectStr
        }
    }
    
    func setDeviceInfoInUI(deviceInfo:Device_Details) {
        DispatchQueue.main.async {
            self.m_deviceNameText.text = deviceInfo.name
        }
    }
    
    func getFrimwareVersion(){
        m_BluIDSDKClient?.getDeviceFirmwareVersion(callback: { (error, version) in
            if let error = error {
                print("error\(error)")
                return;
            }
            if let version = version, let text = self.m_selectedDevice?.name {
                self.setDeviceSelectLabel(deviceSelectStr: "\(text)\nv\(version)")
            }
        })
    }
    
    func disconnectUI() {
        DispatchQueue.main.async {
            self.enableFirmwareWidgets(false)
            self.enableOnDeviceSelected(false)
            self.enableAdminControls(false)
            self.enableGeneralNavigations(true)
            self.hideProgressBar(isHidden: true)
            self.m_selectedDeviceDetails.text = "none"
            self.m_deviceNameText.text = ""
            self.m_bleStrengthLabel.text = ""
            self.m_inUseLEDColorButton.setTitle("", for: .normal)
            self.m_idleLEDColorButton.setTitle("", for: .normal)
            self.m_bleStepper.value = 1.0
        }
    }
    
    func updateFirmware(firmware:Device_Firmware) {
        self.enableFirmwareWidgets(false)
        self.enableAdminControls(false)
        self.enableOnDeviceSelected(false)
        self.enableGeneralNavigations(false)
        self.hideProgressBar(isHidden: false)
        m_BluIDSDKClient?.updateSingleDeviceFirmware(version: firmware.version, onUpdateComplete: { (error:BluIDSDKError?, connectionState:Bool?) in
                    self.disconnectUI()
                    if let _error = error {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(_error)")
                    }
                }, progressHandler: updateProgressHandler)
    }
    
    func multiFirmwareUpdate(deviceList:[Device_Information], version: String){
        guard !deviceList.isEmpty else {
            return
        }
        m_deviceList = deviceList
        self.enableFirmwareWidgets(false)
        self.enableAdminControls(false)
        self.enableOnDeviceSelected(false)
        self.enableGeneralNavigations(false)
        self.hideProgressBar(isHidden: false)
        let _deviceList = deviceList.map { device -> String in
            return device.id
        }
        m_BluIDSDKClient?.updateMultipleDeviceFirmware(deviceIDs: _deviceList, firmwareVersion: version, onUpdateComplete: { (response:[String:BluIDSDKError?]) in
                    self.disconnectUI()
            if !response.isEmpty,  let _error = response.first(where: { (key: String, value: BluIDSDKError?) in
                return value != nil
            }) {
                        CommonUtils.showMessage(view: self, title: "Update Failed", message: "\(_error)")
                    }
            debugPrint("MultiDevice update complete!")
                }, progressHandler: updateMultiDeviceProgressHandler)
    }
    
    func updateProgressHandler(percent:Int) -> Void{
        DispatchQueue.main.async { [self] in
            m_progressLabel.text = "\(percent)%"
            m_progressBar.setProgress((Float(percent)/100.0), animated: true)
        }
    }
    
    func updateMultiDeviceProgressHandler(deviceID:String, percent:Int?, error:BluIDSDKError?) -> Void{
        guard  let percent = percent else {
            if let error = error {
                print(deviceID, error)
            }
            return
        }
        let name:String = (m_deviceList.filter { device in
            return device.id == deviceID
        }).first?.name ?? ""
        DispatchQueue.main.async { [self] in
            m_progressLabel.text = "\(name): \(percent)%"
            m_progressBar.setProgress((Float(percent)/100.0), animated: true)
        }
    }
    
    func onLoginCellClicked(){
        m_actionToPerform?(.Login)
    }
    func onScanBluPOINTCellClicked() {
        m_actionToPerform?(.Scan)
    }
    
    func onTransferCredentials(){
        guard let selectedDevice = m_selectedDevice else {
            CommonUtils.showMessage(view: self, title: "Error!", message: "Please select a device");
            return
        }
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Authenticating")
        DispatchQueue.global(qos: .userInitiated).async {
            self.m_BluIDSDKClient?.syncPersonCards(onComplete: { (error, cards) in
                if let error = error {
                    print(error)
                    CommonUtils.dismissProgressBar(progressBar: progressBar) {
                        CommonUtils.showMessage(view: self, title: "Transfer Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                    return
                }
                guard let cards = cards, !cards.isEmpty else {
                    CommonUtils.dismissProgressBar(progressBar: progressBar) {
                        CommonUtils.showMessage(view: self, title: "Transfer Failed", message: "Cards not found")
                    }
                    return
                }
                self.m_BluIDSDKClient?.transferCredential(deviceID: selectedDevice.id, onResponse: { error in
                    if let error = error {
                        debugPrint(error)
                        CommonUtils.dismissProgressBar(progressBar: progressBar) {
                            CommonUtils.showMessage(view: self, title: "Transfer Failed", message: "\(error)\n\(error.localizedDescription)")
                        }
                        return
                    }
                    CommonUtils.dismissProgressBar(progressBar: progressBar) {
                    }
                })
            })
        }
    }
    
    func setBluIDSDK(sdk:BluIDSDK){
        self.m_BluIDSDKClient = sdk
        DispatchQueue.main.async {
            self.m_sdkVersionLabel.text = "v\(sdk.getSDKVersion())"
        }
    }
    
    func factoryResetBluPOINTDevice(){
        guard m_selectedDevice != nil else {
            CommonUtils.showMessage(view: self, title: "Error!", message: "Please select the device")
            return
        }
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Performing Factory reset")
        m_BluIDSDKClient?.factoryResetDevice(onComplete: { error in
            CommonUtils.dismissProgressBar(progressBar: progressBar) {
                if let error = error {
                    CommonUtils.showMessage(view: self, title: "Factory reset Failed", message: "\(error)\n\(error.localizedDescription)")
                    return
                }
                self.disconnectUI()
            }
        })
    }
    
    func onUnlockBluPOINTDevice() {
        guard let selectedDevice = m_selectedDevice else {
            CommonUtils.showMessage(view: self, title: "Error!", message: "Please select the device")
            return
        }
        let progressBar = CommonUtils.showProgressBar(view: self, message: "Unlocking Device")
        m_BluIDSDKClient?.unlockDeviceAccess(deviceID: selectedDevice.id, onResponse: { error, expiryTime in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint(error)
                    self.enableAdminControls(false)
                    if case BluIDSDKError.deviceInBluboot = error {
                        self.m_singleDeviceButton.isEnabled = true
                    }
                    CommonUtils.dismissProgressBar(progressBar: progressBar) {
                        CommonUtils.showMessage(view: self, title: "Unlock Failed", message: "\(error)\n\(error.localizedDescription)")
                    }
                    return
                }
                self.getAdvertisementStrength(onDone: {
                        self.m_BluIDSDKClient?.getDeviceStateLEDColor(forDeviceState: .idle, onResponse: { idleLEDError, idleLEDColor in
                            if let idleLEDError = idleLEDError {
                                print(idleLEDError)
                            }
                            if let idleLEDColor = idleLEDColor {
                                let idleLEDColorText:String = (self.m_deviceStateLEDColors.first(where: { (key: String, value: Device_LED_Color) in
                                    return (value.red == idleLEDColor.red && value.green == idleLEDColor.green && value.blue == idleLEDColor.blue)
                                })?.key) ?? "HostControlled"
                                self.m_idleLEDColorButton.setTitle(idleLEDColorText, for: UIControl.State.normal)
                            }
                            self.m_BluIDSDKClient?.getDeviceStateLEDColor(forDeviceState: .in_use, onResponse: { inUseError, inUseLEDColor in
                                if let inUseError = inUseError {
                                    print(inUseError)
                                }
                                if let inUseLEDColor = inUseLEDColor {
                                    let inUseLEDColorText:String = (self.m_deviceStateLEDColors.first(where: { (key: String, value: Device_LED_Color) in
                                        return (value.red == inUseLEDColor.red && value.green == inUseLEDColor.green && value.blue == inUseLEDColor.blue)
                                    })?.key) ?? "HostControlled"
                                    self.m_inUseLEDColorButton.setTitle(inUseLEDColorText, for: UIControl.State.normal)
                                }
                                self.enableAdminControls(true)
                                self.enableFirmwareWidgets(true)
                                guard let expiryTime = expiryTime else {
                                    CommonUtils.dismissProgressBar(progressBar: progressBar) {
                                    }
                                    debugPrint("expiry time not found")
                                    return
                                }
                                debugPrint("Expiry time \(expiryTime)")
                                CommonUtils.dismissProgressBar(progressBar: progressBar) {
                                }
                            })
                        })
                    })
            }
        },onDisconnect: { (id) in
            print("Device disconnect during unlock session \(selectedDevice)")
        })
    }
    
    func getAdvertisementStrength(onDone callback:@escaping()->Void){
        m_BluIDSDKClient?.getBLETxPowerLevel(callback: { (error, data) in
            DispatchQueue.main.async {
                if let _error = error {
                    print("error\(_error)")
                }else{
                    if let data = data{
                        self.m_bleStrengthLabel.text = "\(data)"
                        self.m_bleStepper.value = Double(data)
                    }
                }
                callback()
            }
        })
    }
    
    func onLogin(userName:String) {
        DispatchQueue.main.async {
            self.m_userNameLabel.text = "(\(userName))"
            self.m_loginLabel.text = "Logout"
        }
    }
    
    func onLogout(){
        DispatchQueue.main.async {
            self.m_userNameLabel.text = ""
            self.m_loginLabel.text = "Login"
            self.m_BluIDSDKClient?.logout()
        }
    }
    
    func enableGeneralNavigations(_ isEnabled:Bool){
        debugPrint("enableGeneralNavigations \(isEnabled)")
        DispatchQueue.main.async {
            self.m_loginTableCell.isUserInteractionEnabled = isEnabled
            self.m_scanBluPOINTTableCell.isUserInteractionEnabled = isEnabled
            self.m_multiDeviceButton.isEnabled = isEnabled
        }
    }
    
    func enableOnDeviceSelected(_ isEnabled:Bool){
        debugPrint("enableOnDeviceSelected \(isEnabled)")
        DispatchQueue.main.async {
            self.m_unlockTableCell.isUserInteractionEnabled = isEnabled
        }
    }
    
    func enableAdminControls(_ isEnabled:Bool){
        debugPrint("enableAdminControls \(isEnabled)")
        DispatchQueue.main.async {
            self.m_rebootButton.isEnabled = isEnabled
            self.m_disconnectButton.isEnabled = isEnabled
            self.m_deviceNameText.isEnabled = isEnabled
            self.m_deviceNameButton.isEnabled = isEnabled
            self.m_bleStepper.isEnabled = isEnabled
            self.m_ledSwitch.isEnabled = isEnabled
            self.m_ringBuzzerSwitch.isEnabled = isEnabled
            self.m_isUnlocked = isEnabled
            self.m_iOSForegroundStepper.isEnabled = isEnabled
            self.m_androidStepper.isEnabled = isEnabled
            self.m_idleLEDColorButton.isEnabled = isEnabled
            self.m_inUseLEDColorButton.isEnabled = isEnabled
        }
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_tapStepper, button: self.m_tapSetButton, toggle: self.m_tapSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_twistStepper, button: self.m_twistSetButton, toggle: self.m_twistSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_inRangeStepper, button: self.m_inRangeSetButton, toggle: self.m_inRangeSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_aiStepper, button: self.m_aiSetButton, toggle: self.m_aiSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_waveStepper, button: self.m_waveSetButton, toggle: self.m_waveSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_BluREMOTEStepper, button: self.m_BluREMOTESetButton, toggle: self.m_BluREMOTESwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_appleWatchStepper, button: self.m_appleWatchSetButton, toggle: self.m_appleWatchSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_appSpecificStepper, button: self.m_appSpecificSetButton, toggle: self.m_appSpecificSwitch)
        self.enableGestureWidgets(isEnabled: isEnabled, stepper: self.m_iOSBackgroundStepper, button: self.m_enhancedTapSetButton, toggle: self.m_enhancedTapSwitch)
    }
    func enableGestureWidgets(isEnabled:Bool, stepper:UIStepper, button:UIButton, toggle:UISwitch){
        DispatchQueue.main.async {
            stepper.isEnabled = isEnabled
            button.isEnabled = isEnabled
            toggle.isEnabled = isEnabled
        }
    }
    
    func enableFirmwareWidgets(_ isEnabled:Bool){
        debugPrint("enableFirmwareWidgets \(isEnabled)")
        DispatchQueue.main.async {
            self.m_singleDeviceButton.isEnabled = isEnabled
        }
    }
    func hideProgressBar(isHidden:Bool) {
        debugPrint("hideProgressBar \(isHidden)")
        DispatchQueue.main.async {
            self.m_progressBar.isHidden = isHidden
            self.m_progressLabel.isHidden = isHidden
            self.m_progressLabel.text = "0%"
            self.m_progressBar.setProgress(0.0, animated: true)
        }
    }
}

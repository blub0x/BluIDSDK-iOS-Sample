//
//  SceneDelegate.swift
//  BluIDSDK Sample App
//
//  Created by Akhil Kumar on 08/04/21.
//

import UIKit
import BluIDSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var m_BluIDSDKClient: BluIDSDK?
    var m_tableViewController : TableViewController?
    var m_firmwareTableViewController : FirmwareTableViewController?
    var m_mainScreenViewController: MainScreenViewController?
    var m_multipleDeviceUpdateViewController : MultipleDeviceUpdateViewController?
    var m_loginViewController : LoginViewController?
    var m_environmentDB:BluIDSDKEnvironmentDB?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        m_environmentDB = BluIDSDKEnvironmentDB()
        m_BluIDSDKClient = BluIDSDK(env: m_environmentDB?.getEnvironment() ?? .production)
        window = UIWindow(windowScene: windowScene)
        //        initializeBleRoleSelectViewController()
        initializeMainViewController()
        initializeLoginViewController()
        initializeTableViewController()
        initializeFirmwareTableViewController()
        initializeMultipleDeviceUpdateViewController()
        window?.rootViewController = m_mainScreenViewController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func initializeMainViewController() {
        m_mainScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreenViewController") as? MainScreenViewController
        guard let bluIDSDK = m_BluIDSDKClient else {
            return
        }
        m_mainScreenViewController?.m_environmentDB = m_environmentDB
        m_mainScreenViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_mainScreenViewController?.setGeneralUserSettings(generalUserSettings: bluIDSDK.getUserPreference())
        m_mainScreenViewController?.m_actionToPerform = {[weak self] choice in
            DispatchQueue.main.async {
                switch choice{
                case .Login:
                    self?.window?.rootViewController = self?.m_loginViewController
                case .Scan:
                    self?.m_tableViewController?.view.backgroundColor = .cyan
                    self?.window?.rootViewController = self?.m_tableViewController
                    self?.m_tableViewController?.startScanning()
                case .AutoTransfer:
                    self?.m_tableViewController?.startScanning()
                    return
                }
                self?.window?.makeKeyAndVisible()
            }
        }
        m_mainScreenViewController?.m_onEnvironmentChange = switchEnvironment
    }
    
    
    func initializeLoginViewController(){
        m_loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        guard let bluIDSDK = m_BluIDSDKClient else {
            return
        }
        m_loginViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_loginViewController?.m_onBack = {
            DispatchQueue.main.async {
                self.window?.rootViewController = self.m_mainScreenViewController
            }
        }
        m_loginViewController?.m_onLogin = {(userName) in
            DispatchQueue.main.async {
                self.window?.rootViewController = self.m_mainScreenViewController
                self.m_mainScreenViewController?.onLogin(userName: userName)
            }
        }
    }
    
    func initializeTableViewController(){
        m_tableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as? TableViewController
        guard let bluIDSDK = m_BluIDSDKClient else {
            return
        }
        m_tableViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_tableViewController?.startScanning()
        m_tableViewController?.m_onDeviceConnected = { (selectedDevice:Device_Information) in
            if (self.m_mainScreenViewController?.m_isUnlocked == true) {
                bluIDSDK.lockDeviceAccess()
            }
            self.m_mainScreenViewController?.enableOnDeviceSelected(true)
            self.window?.rootViewController = self.m_mainScreenViewController
            self.m_mainScreenViewController?.setSelectedDevice(device: selectedDevice)
        }
        m_tableViewController?.m_onDeviceDisconnect = {
            self.m_mainScreenViewController?.disconnectUI()
        }
        m_tableViewController?.m_onback = {
            DispatchQueue.main.async {
                self.window?.rootViewController = self.m_mainScreenViewController
            }
        }
    }
    func initializeFirmwareTableViewController(){
        m_firmwareTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirmwareTableViewController") as? FirmwareTableViewController
        guard let bluIDSDK = m_BluIDSDKClient else {
            return
        }
        self.m_firmwareTableViewController?.setBluIDSDK(sdk: bluIDSDK)
        self.m_firmwareTableViewController?.m_onDoneClicked = { (fileName) in
            DispatchQueue.main.async {
                self.window?.rootViewController = self.m_mainScreenViewController
                self.m_mainScreenViewController?.updateFirmware(firmware: fileName)
            }
        }
        self.m_firmwareTableViewController?.m_onMultipleDeviceDoneClicked = { (deviceList, firmware) in
            DispatchQueue.main.async {
                self.window?.rootViewController = self.m_mainScreenViewController
                self.m_mainScreenViewController?.multiFirmwareUpdate(deviceList: deviceList, version: firmware.version)
            }
        }
        self.m_firmwareTableViewController?.m_onCancelClicked = {
            self.window?.rootViewController = self.m_mainScreenViewController
        }
        m_mainScreenViewController?.m_onGetFirmwareList = { (firmwareList) in
            self.window?.rootViewController = self.m_firmwareTableViewController
            self.m_firmwareTableViewController?.onEnter()
        }
    }
    
    func initializeMultipleDeviceUpdateViewController(){
        m_multipleDeviceUpdateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MultipleDeviceUpdateViewController") as? MultipleDeviceUpdateViewController
        guard let bluIDSDK = m_BluIDSDKClient else {
            return
        }
        m_mainScreenViewController?.m_onMultiUpdateFirmwareButtonPressed={
            self.window?.rootViewController = self.m_multipleDeviceUpdateViewController
            self.m_multipleDeviceUpdateViewController?.setBluIDSDK(sdk: bluIDSDK)
            self.m_multipleDeviceUpdateViewController?.startScanning()
            
        }
        m_multipleDeviceUpdateViewController?.m_onCancelClicked = {
            self.window?.rootViewController = self.m_mainScreenViewController
        }
        self.m_multipleDeviceUpdateViewController?.m_onDoneClicked = { (deviceIDs) in
            self.window?.rootViewController = self.m_firmwareTableViewController
            self.m_firmwareTableViewController?.setDeviceList(devicelist: deviceIDs)
            self.m_firmwareTableViewController?.onEnter()
            
        }
    }
    
    func switchEnvironment(environment:BluIDSDK_Environment) {
        m_mainScreenViewController?.disconnectUI()
        m_mainScreenViewController?.onLogout()
        m_BluIDSDKClient?.stopDeviceDiscovery()
        m_BluIDSDKClient?.logout()
        let bluIDSDK = BluIDSDK(env: environment)
        m_environmentDB?.save(env: environment)
        m_BluIDSDKClient = bluIDSDK
        m_loginViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_tableViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_mainScreenViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_firmwareTableViewController?.setBluIDSDK(sdk: bluIDSDK)
        m_multipleDeviceUpdateViewController?.setBluIDSDK(sdk: bluIDSDK)
    }
    
}

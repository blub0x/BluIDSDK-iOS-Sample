//
//  CommonUtils.swift
//  BluIDSDK Sample App
//
//  Created by Akhil Kumar on 15/06/21.
//

import Foundation
import UIKit
import AYPopupPickerView


class CommonUtils {
    static func showConfirmPopup(view:UIViewController, title:String, message:String, onPositive:@escaping()->Void, onNegative:@escaping()->Void){
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
              print("Handle Ok logic here")
            onPositive()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              onNegative()
        }))
        DispatchQueue.main.async {
            view.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    static func showMessage(view:UIViewController, title:String, message:String){
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            view.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    static func showProgressBar(view:UIViewController, message:String)->UIAlertController{
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        DispatchQueue.main.async {
            loadingIndicator.startAnimating();

            alert.view.addSubview(loadingIndicator)
            view.present(alert, animated: true, completion: nil)
        }
        return alert
    }
    
    static func dismissProgressBar(progressBar:UIAlertController, onComplete:@escaping ()->Void){
        DispatchQueue.main.async {
            progressBar.dismiss(animated: false, completion: onComplete)
        }
    }
    
    static func showPicker(items:[String], activeIndex:Int, onSelection callback:@escaping(String)->Void){
        if items.isEmpty {
            return
        }
        var selectIndex = activeIndex
        if activeIndex >= items.count || activeIndex < 0 {
            selectIndex = 0
        }
        let popupPickerView = AYPopupPickerView()
        popupPickerView.pickerView.backgroundColor = .systemBackground
        popupPickerView.headerView.backgroundColor = .secondarySystemBackground
        popupPickerView.display(itemTitles: items, defaultIndex: selectIndex) {
            let selectedIndex = popupPickerView.pickerView.selectedRow(inComponent: 0)
            callback(items[selectedIndex])
        }
    }
    
    static func isMACFormat(macAddress:String) -> Bool{
        let passwordRegex = "^[0-9A-Fa-f]{12}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: macAddress)
    }
    
    static func isDeviceKeyValid(key:String) -> Bool{
        let keyRegex = "^[0-9A-Fa-f]{288}$"
        return NSPredicate(format: "SELF MATCHES %@", keyRegex).evaluate(with: key)
    }
}

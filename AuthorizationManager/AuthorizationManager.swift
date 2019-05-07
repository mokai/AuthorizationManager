//
//  AuthorizationManager.swift
//  UiOSProject
//
//  Created by 廉鑫博 on 2019/5/7.
//  Copyright © 2019 廉鑫博. All rights reserved.
//

import Contacts
import MapKit
import UIKit
import AVFoundation
import Photos
import Dispatch



@available(iOS 9.0, *)
class AuthorizationManager {
    
    typealias CompletionHandler = (Bool) -> ()
    
    enum AuthorizationType {
        enum LocationRequestType {
            case always
            case whenInUse
        }
        case location(type:LocationRequestType)
        case camera
        case photoLibrary
        case record
        case addressBook
    }
    
    static let shared = AuthorizationManager()
    
    func get(_ authorization:AuthorizationType, result: @escaping CompletionHandler)
    {
        switch authorization {
        case .location(let type):
            getlocationAuthorization(type: type, result: result)
        case .camera:
            getCameraAuthorization(result: result)
        case .photoLibrary:
            getPhotoLibraryAuthorization(result: result)
        case .record:
            getRecordAuthorization(result: result)
        case .addressBook:
            getAddressBookAuthorization(result: result)
        }
    }
    
    
    private var locationManager :LocationManager?
    
    /// 获取定位权限
    /// NSLocationAlwaysUsageDescription
    /// NSLocationUsageDescription
    /// NSLocationAlwaysAndWhenInUseUsageDescription
    /// - Parameters:
    ///   - type: 定位类型
    ///   - result: 结果
    private func getlocationAuthorization(type:AuthorizationType.LocationRequestType,result: @escaping CompletionHandler)
    {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager = LocationManager(result: result)
            switch type
            {
            case .always:
                locationManager?.requestAlwaysAuthorization()
            case .whenInUse:
                locationManager?.requestWhenInUseAuthorization()
            }
        case .authorizedAlways,.authorizedWhenInUse:
            result(true)
        default:
            result(false)
        }
    }
    
    
    /// 获取相机权限
    /// NSCameraUsageDescription
    /// - Parameter result: 结果
    private func getCameraAuthorization(result: @escaping CompletionHandler)
    {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    result(granted)
                }
            }
        case .authorized:
            result(true)
        default :
            result(false)
        }
    }
    
    
    /// 获取相册权限
    /// NSPhotoLibraryAddUsageDescription,NSPhotoLibraryUsageDescription
    /// - Parameter result: 结果
    private func getPhotoLibraryAuthorization(result: @escaping CompletionHandler){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    self.getPhotoLibraryAuthorization(result: result)
                }
            }
        case .authorized:
            result(true)
        default:
            result(false)
        }
    }
    
    
    /// 获取麦克风权限
    /// NSMicrophoneUsageDescription
    /// - Parameter result: 结果
    private func getRecordAuthorization(result: @escaping CompletionHandler){
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (res) in
                DispatchQueue.main.async {
                    self.getRecordAuthorization(result: result)
                }
            }
        case .granted:
            result(true)
        default:
            result(false)
        }
    }
    
    
    /// 获取通讯录权限
    /// NSContactsUsageDescription
    /// - Parameter result: 结果
    private func getAddressBookAuthorization(result: @escaping CompletionHandler){
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { (res, error) in
                DispatchQueue.main.async {
                    result(res)
                }
            }
        case .authorized:
            result(true)
        default:
            result(false)
        }
    }
    
}

private class LocationManager: CLLocationManager, CLLocationManagerDelegate
{
    let result:AuthorizationManager.CompletionHandler
    required init(result : @escaping AuthorizationManager.CompletionHandler) {
        self.result = result
        super.init()
        delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status == .notDetermined
        {
            return
        }
        
        if status == .authorizedAlways || status == .authorizedWhenInUse
        {
            result(true)
        }else
        {
            result(false)
        }
        
    }
    deinit {
        print("deinit")
    }
    
}

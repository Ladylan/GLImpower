//
//  GLImpower.swift
//  GLImpower
//
//  Created by GanL on 17/6/19.
//  Copyright © 2017年 GanL. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos
import Contacts
import EventKit
import UserNotifications

public enum ImpowerType{
    case camera
    case photo
    case microphone
    case contact
    case notification
    case calendar(calendarType)
    case location(locationType)
    
    public enum calendarType{
        case event
        case reminder
    }
    
    public enum locationType{
        case whenInUse
        case always
    }
}

private var _notification: Notification?
private var _location: CLLocationManager?
private var _locationDelegate: LocationDelegate?
public typealias GLImpowerAction = () -> Void

class GLImpower: NSObject {
    
}

//MARK: judgeStatus

/**
 * 根据type判断是否未进行授权处理
 **/
public func judgeIsNotDetermined(impowerType: ImpowerType) -> Bool{
    switch impowerType {
    case .photo:
        return PHPhotoLibrary.authorizationStatus() == .notDetermined
    case .camera:
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined
    case .microphone:
        return AVAudioSession.sharedInstance().recordPermission() == .undetermined
    case .contact:
        if #available(iOS 9, *) {
            return CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
        }else{
            return ABAddressBookGetAuthorizationStatus() == .notDetermined
        }
    case .calendar(let entityType):
        switch entityType {
        case .event:
            return EKEventStore.authorizationStatus(for: .event) == .notDetermined
        default:
            return EKEventStore.authorizationStatus(for: .reminder) == .notDetermined
        }
    case .location(let type):
        switch type {
        case .whenInUse:
            return CLLocationManager.authorizationStatus() == .notDetermined
        case .always:
            return CLLocationManager.authorizationStatus() == .notDetermined
        }
    case .notification:
        return UIApplication.shared.notificationAuthorizationStatus == .notDetermined
    }
}

/**
 * 根据type判断权限是否拒绝
 **/
public func judgeIsDenied(impowerType: ImpowerType) -> Bool{
    switch impowerType {
    case .photo:
        return PHPhotoLibrary.authorizationStatus() == .denied
    case .camera:
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied
    case .microphone:
        return AVAudioSession.sharedInstance().recordPermission() == .denied
    case .contact:
        if #available(iOS 9, *) {
            return CNContactStore.authorizationStatus(for: .contacts) == .denied
        }else{
            return ABAddressBookGetAuthorizationStatus() == .denied
        }
    case .calendar(let entityType):
        switch entityType {
        case .event:
            return EKEventStore.authorizationStatus(for: .event) == .denied
        default:
            return EKEventStore.authorizationStatus(for: .reminder) == .denied
        }
    case .location(let type):
        switch type {
        case .whenInUse:
            return CLLocationManager.authorizationStatus() == .denied
        case .always:
            return CLLocationManager.authorizationStatus() == .denied
        }
    case .notification:
        return UIApplication.shared.notificationAuthorizationStatus == .notDetermined
    }
}


//MARK: getImpower

/**
 * 授权处理
 * @param type - 授权类型
 * @param agreed - 授权状态为“同意”时回调
 * @param agreed - 授权状态为“拒绝”时回调
 **/
public func getImpower(_ type: ImpowerType,
                       agreed agreedAction: @escaping GLImpowerAction,
                       rejected rejectedAction: @escaping GLImpowerAction){
    
    if judgeIsNotDetermined(impowerType: type) {
        //未授权过，弹出提示框询问是否进行下一步授权操作
        showImpowerAlert(type: type, agreed: agreedAction, rejected: rejectedAction)
    }else{
        //已进行过授权操作，则返回授权状态
        impowerState(type: type, agreed: agreedAction, rejected: rejectedAction)
    }
}

/**
 * 返回授权状态
 **/
public func impowerState(type: ImpowerType,
                         agreed: @escaping GLImpowerAction,
                         rejected: @escaping GLImpowerAction){
    switch type {
    case .camera:
        getCameraImpower(agreed: agreed, rejected: rejected)
    case .photo:
        getPhotoImpower(agreed: agreed, rejected: rejected)
    case .microphone:
        getMicorphoneImpower(agreed: agreed, rejected: rejected)
    case .location(let locationType):
        getLocationImpower(locationType, agreed: agreed, rejected: rejected)
    case .contact:
        getContactImpower(agreed: agreed, rejected: rejected)
    case .calendar(let entityType):
        switch entityType {
        case .event:
            getCalendarImpower(.event, agreed: agreed, rejected: rejected)
        case .reminder:
            getCalendarImpower(.reminder, agreed: agreed, rejected: rejected)
        }
    case .notification:
        getNotificationImpower(agreed: agreed, rejected: rejected)
    }
}



/**
 * 获取相机权限
 **/
private func getCameraImpower(agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
        DispatchQueue.main.async {
            granted ? agreed() : rejected()
        }
    }
}

/**
 * 获取相册权限
 **/
private func getPhotoImpower(agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                agreed()
            default:
                rejected()
            }
        }
    }
}

/**
 * 获取麦克风权限
 **/
private func getMicorphoneImpower(agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async {
            granted ? agreed() : rejected()
        }
    }
}

/**
 * 获取位置权限
 **/
private func getLocationImpower(_ locationType: ImpowerType.locationType, agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    switch CLLocationManager.authorizationStatus() {
    case .authorizedWhenInUse:
        locationType == .whenInUse ? agreed() : rejected()
    case .authorizedAlways:
        agreed()
    case .notDetermined:
        if CLLocationManager.locationServicesEnabled() {
            let locationManager = CLLocationManager()
            _location = locationManager
            let delegate = LocationDelegate(locationType: locationType, successAction: agreed, failureAction: rejected)
            _locationDelegate = delegate
            locationManager.delegate = delegate
            switch locationType {
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            case .always:
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.startUpdatingLocation()
        } else {
            rejected()
        }
    default:
        rejected()
    }
}

/**
 * 获取通讯录权限
 **/
private func getContactImpower(agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    if #available(iOS 9.0, *) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            agreed()
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    granted ? agreed() : rejected()
                }
            }
        default:
            rejected()
        }
    } else {
        switch ABAddressBookGetAuthorizationStatus() {
        case .authorized:
            agreed()
        case .notDetermined:
            if let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() {
                ABAddressBookRequestAccessWithCompletion(addressBook) { granted, error in
                    DispatchQueue.main.async {
                        granted ? agreed() : rejected()
                    }
                }
            }
        default:
            rejected()
        }
    }
}

/**
 * 获取日历权限
 **/
private func getCalendarImpower(_ entityYype: EKEntityType, agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    switch EKEventStore.authorizationStatus(for: entityYype) {
    case .authorized:
        agreed()
    case .notDetermined:
        EKEventStore().requestAccess(to: entityYype) { granted, error in
            DispatchQueue.main.async {
                granted ? agreed() : rejected()
            }
        }
    default:
        rejected()
    }
}

/**
 * 获取通知权限
 **/
private func getNotificationImpower(agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    let setting = UIUserNotificationSettings(
        types: [.alert, .badge, .sound],
        categories: nil
    )
    
    switch UIApplication.shared.notificationAuthorizationStatus {
    case .notDetermined:
        let notification = Notification {
            if UIApplication.shared.notificationAuthorizationStatus == .authorized {
                agreed()
            } else {
                rejected()
            }
        }
        _notification = notification
        UIApplication.shared.registerUserNotificationSettings(setting)
    case .authorized:
        UIApplication.shared.registerUserNotificationSettings(setting)
        agreed()
    case .denied:
        rejected()
    }
}

//MARK: Notification
private let askedForNotificationPermissionKey = "Impower.AskedForNotificationPermission"

private extension UIApplication {
    
    enum NotificationAuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }
    
    var notificationAuthorizationStatus: NotificationAuthorizationStatus {
        if UIApplication.shared.currentUserNotificationSettings?.types.isEmpty == false {
            return .authorized
        }
        let asked = UserDefaults.standard.bool(forKey: askedForNotificationPermissionKey)
        return asked ? .denied : .notDetermined
    }
}

private class Notification: NSObject {
    
    var finish: (() -> Void)? = nil
    init(_ finish: (() -> Void)?) {
        super.init()
        
        self.finish = finish
        NotificationCenter.default.addObserver(self, selector: #selector(requestingNotifications), name: .UIApplicationWillResignActive, object: nil)
    }
    
    @objc private func requestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedRequestingNotifications), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func finishedRequestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        UserDefaults.standard.set(true, forKey: askedForNotificationPermissionKey)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.finish?()
        }
    }
}

//MARK: LocationDelegate
private class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    let locationType: ImpowerType.locationType
    let successAction: GLImpowerAction
    let failureAction: GLImpowerAction
    
    init(locationType: ImpowerType.locationType, successAction: @escaping GLImpowerAction, failureAction: @escaping GLImpowerAction) {
        self.locationType  = locationType
        self.successAction = successAction
        self.failureAction = failureAction
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse:
                self.locationType == .whenInUse ? self.successAction() : self.failureAction()
                _location = nil
                _locationDelegate = nil
            case .authorizedAlways:
                self.locationType == .always ? self.successAction() : self.failureAction()
                _location = nil
                _locationDelegate = nil
            case .denied:
                self.failureAction()
                _location = nil
                _locationDelegate = nil
            default:
                break
            }
        }
    }
}


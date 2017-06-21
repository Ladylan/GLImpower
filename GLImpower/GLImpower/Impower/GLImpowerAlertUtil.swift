//
//  GLImpowerAlertUtil.swift
//  GLImpower
//
//  Created by GanL on 17/6/19.
//  Copyright © 2017年 GanL. All rights reserved.
//

import UIKit

class GLImpowerAlertUtil: NSObject {

}

private func noImpowerAlertTitleWithType(impowerType: ImpowerType) -> String{
    var title = ""
    switch impowerType {
    case .photo:
        title = "没有权限访问你的相册，您可在手机设置中修改！"
    case .camera:
        title = "没有权限访问你的相机，您可在手机设置中修改！"
    case .contact:
        title = "没有权限访问你的通讯录，您可在手机设置中修改！"
    case .microphone:
        title = "没有权限访问你的麦克风，您可在手机设置中修改！"
    case .notification:
        title = "没有权限向你发送推送消息，您可在手机设置中修改！"
    case .calendar:
        title = "没有权限访问你的日历，您可在手机设置中修改！"
    case .location:
        title = "没有权限访问你的位置信息，您可在手机设置中修改！"
    }
    return title
}

private func didImpowerAlertView(impowerType: ImpowerType) -> String{
    var title = ""
    switch impowerType {
    case .photo:
        title = "已获得相册权限！"
    case .camera:
        title = "已获得相机权限！"
    case .contact:
        title = "已获得通讯录权限！"
    case .microphone:
        title = "已获得麦克风权限！"
    case .notification:
        title = "已获得通知权限！"
    case .calendar:
        title = "已获得日历权限！"
    case .location:
        title = "已获得位置权限！"
    }
    return title
}

public func alertTitleWithType(impowerType: ImpowerType) -> String{
    var title = ""
    switch impowerType {
    case .photo:
        title = "Olive想要访问你的相册"
    case .camera:
        title = "Olive想要访问你的相机"
    case .contact:
        title = "Olive想要访问你的通讯录"
    case .microphone:
        title = "Olive想要访问你的麦克风"
    case .notification:
        title = "Olive想要想你发送推送消息"
    case .calendar:
        title = "Olive想要访问你的日历"
    case .location:
        title = "Olive想要访问你的位置信息"
    }
    return title
}

public func showRejectAlertView(impowerType: ImpowerType){
    
        let title = noImpowerAlertTitleWithType(impowerType: impowerType)
        
        let alertController = UIAlertController(title: title,
                                                message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(alertController, animated: true, completion: nil)
}


public func showDidAgreeImpowerAlertView(impowerType: ImpowerType){
    let title = didImpowerAlertView(impowerType: impowerType)
    
    let alertController = UIAlertController(title: title,
                                            message: "", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    let okAction = UIAlertAction(title: "确定", style: .default, handler: {
        action in
    })
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(alertController, animated: true, completion: nil)
}

public func showImpowerAlert(type: ImpowerType, agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    let title = alertTitleWithType(impowerType: type)
    let alertController = UIAlertController(title: title,
                                            message: "", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "暂不", style: .cancel, handler: nil)
    let okAction = UIAlertAction(title: "确定", style: .default, handler: {
        action in
        impowerWithType(type: type, agreed: agreed, rejected: rejected)
    })
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(alertController, animated: true, completion: nil)
}

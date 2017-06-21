//
//  GLImpowerAlertUtil.swift
//  GLImpower
//
//  Created by GanL on 17/6/19.
//  Copyright © 2017年 GanL. All rights reserved.
//

import UIKit

public typealias GLAlertAction = () -> Void

class GLImpowerAlertUtil: NSObject {

}

//MARK: AlertTitleString

/**
 * 无访问权限时的提示框Title
 **/
private func noImpowerAlertTitle(impowerType: ImpowerType) -> String{
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

/**
 * 已获得访问权限时的提示框Title
 **/
private func didImpowerAlertTitle(impowerType: ImpowerType) -> String{
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

/**
 * 询问是否进行下一步授权时的提示框Title
 **/
public func askImpowerAlertTitle(impowerType: ImpowerType) -> String{
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

//MARK: ShowAlertView

/**
 * 授权拒绝提示弹框
 **/
public func showRejectAlertView(impowerType: ImpowerType){
    showAlertView(title: noImpowerAlertTitle(impowerType: impowerType), cancelStr: "取消", confirmStr: "确定", cancelAction: {
    }, confirmAction: {
    })
}

/**
 * 授权同意提示弹框
 **/
public func showDidAgreeImpowerAlertView(impowerType: ImpowerType){
    showAlertView(title: didImpowerAlertTitle(impowerType: impowerType), cancelStr: "取消", confirmStr: "确定", cancelAction: {
    }, confirmAction: {
    })
}

/**
 * 询问是否进行下一步授权提示弹框
 **/
public func showImpowerAlert(type: ImpowerType, agreed: @escaping GLImpowerAction, rejected: @escaping GLImpowerAction){
    showAlertView(title: askImpowerAlertTitle(impowerType: type), cancelStr: "暂不", confirmStr: "确定", cancelAction: {
    }, confirmAction: {
        impowerState(type: type, agreed: agreed, rejected: rejected)
    })
}

/**
 * 弹框样式设定
 * @param title - 弹框标题
 * @param cancelStr - 取消按钮文字
 * @param confirmStr - 确认按钮文字
 * @param cancelAction - 确认按钮点击回调
 * @param cancelAction - 取消按钮点击回调
 **/
private func showAlertView(title: String, cancelStr: String, confirmStr: String, cancelAction: @escaping GLAlertAction, confirmAction: @escaping GLAlertAction){
    
    let alertController = UIAlertController(title: title,
                                            message: "", preferredStyle: .alert)
    let cancel = UIAlertAction(title: cancelStr, style: .cancel, handler: {
        action in
        cancelAction()
    })
    let confirm = UIAlertAction(title: confirmStr, style: .default, handler: {
        action in
        confirmAction()
    })
    alertController.addAction(cancel)
    alertController.addAction(confirm)
    ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(alertController, animated: true, completion: nil)
}

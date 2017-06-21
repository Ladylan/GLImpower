//
//  ViewController.swift
//  GLImpower
//
//  Created by GanL on 17/6/19.
//  Copyright © 2017年 GanL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var headImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headImageView.layer.cornerRadius = headImageView.frame.size.width/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //相册&相机
    @IBAction func photoImpowerClick(_ sender: Any) {
        GLPhotoHelper.sharePhotoHelper.showSelecteAlertView(didSelectedBlock: { (photo) in
            self.headImageView.image = photo
        })
    }
    
    //麦克风
    @IBAction func micorphoneImpowerClick(_ sender: Any) {
        getImpower(.microphone, agreed: { 
            showDidAgreeImpowerAlertView(impowerType: .microphone)
        }, rejected: {
            showRejectAlertView(impowerType: .microphone)
        })
    }
    
    //位置
    @IBAction func locationImpowerClick(_ sender: Any) {
        getImpower(.location(.always), agreed: {
            showDidAgreeImpowerAlertView(impowerType: .location(.always))
        }, rejected: {
            showRejectAlertView(impowerType: .location(.always))
        })
    }
    
    //日历
    @IBAction func calendarImpowerClick(_ sender: Any) {
        getImpower(.calendar(.event), agreed: {
            showDidAgreeImpowerAlertView(impowerType: .calendar(.event))
        }, rejected: {
            showRejectAlertView(impowerType: .calendar(.event))
        })
    }
    
    //通知
    @IBAction func notificationImpowerClick(_ sender: Any) {
        getImpower(.notification, agreed: {
            showDidAgreeImpowerAlertView(impowerType: .notification)
        }, rejected: {
            showRejectAlertView(impowerType: .notification)
        })
    }
    
    //通讯录
    @IBAction func contactImpowerClick(_ sender: Any) {
        getImpower(.contact, agreed: {
            showDidAgreeImpowerAlertView(impowerType: .contact)
        }, rejected: {
            showRejectAlertView(impowerType: .contact)
        })
    }
    
    
}



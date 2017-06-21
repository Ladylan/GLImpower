//
//  GLPhotoHelper.swift
//  heroHelper
//
//  Created by Olive on 2017/5/24.
//  Copyright © 2017年 GanL. All rights reserved.
//

import UIKit

let photoHelper = GLPhotoHelper()
typealias selectedBlock = (UIImage) -> ()


class GLPhotoHelper: UIImagePickerController {
    
    class var sharePhotoHelper: GLPhotoHelper {
        return photoHelper
    }
    
    var helper = GLPhotoDelegate()
    
    /**
     * 选择图片途径弹框
     **/
    public func showSelecteAlertView(didSelectedBlock: @escaping selectedBlock) {
        let alertController = UIAlertController.init(title: "选取图片", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let canleAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let library = UIAlertAction.init(title: "相册", style: UIAlertActionStyle.default) { (action) in
            //相册权限校验
            getImpower(.photo, agreed: {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                    self.creatWithScourceType(type: UIImagePickerControllerSourceType.photoLibrary,block: didSelectedBlock)
                }
            }, rejected: {
                showRejectAlertView(impowerType: .photo)
            })
        }
        let carmare = UIAlertAction.init(title: "拍照", style: UIAlertActionStyle.default) { (action) in
            //相机权限校验
            getImpower(.camera, agreed: {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                    self.creatWithScourceType(type: UIImagePickerControllerSourceType.camera,block: didSelectedBlock)
                }
            }, rejected: {
                showRejectAlertView(impowerType: .camera)
            })
        }
        alertController.addAction(canleAction)
        alertController.addAction(library)
        alertController.addAction(carmare)
        ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    /**
     * @param type - 获取图片途径
     * @parm block - 选择图片回调
     **/
    private func creatWithScourceType(type: UIImagePickerControllerSourceType, block:@escaping selectedBlock)  {
        photoHelper.helper = GLPhotoDelegate()
        photoHelper.delegate = photoHelper.helper
        photoHelper.sourceType = type
        photoHelper.allowsEditing = true
        
        photoHelper.helper.selectedBlock = block
        ((UIApplication.shared.delegate?.window)!)!.rootViewController?.present(self, animated: true, completion: nil)
    }
}


class GLPhotoDelegate: NSObject ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var selectedBlock : selectedBlock = {_ in}
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage? = nil;
        if picker.allowsEditing {
            image = info[UIImagePickerControllerEditedImage] as! UIImage?
        }else{
            image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        }
        self.compactImage(image: image!)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: 压缩图片
    func compactImage(image: UIImage) {
        
        var imageSize    = image.size
        imageSize.width  = imageSize.width/4
        imageSize.height = imageSize.height/4
        
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        selectedBlock(newImage!)
    }
}

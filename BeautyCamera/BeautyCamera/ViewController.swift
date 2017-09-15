//
//  ViewController.swift
//  BeautyCamera
//
//  Created by Mazy on 2017/9/15.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    fileprivate var stillCamera: GPUImageStillCamera?
    fileprivate var brightFilter: GPUImageBrightnessFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建相机
        // swift 3.0 AVCaptureSessionPreset640x480
        // swift 4.0 AVCaptureSession.Preset.vga640x480.rawValue
        stillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .front)
        // 设置为竖屏
        stillCamera?.outputImageOrientation =  .portrait
        
        // 创建滤镜
        brightFilter = GPUImageBrightnessFilter()
        brightFilter?.brightness = 0.3
        stillCamera?.addTarget(brightFilter)
        
        // 创建实时显示的画面 View
        let showView = GPUImageView(frame: view.bounds)
        view.insertSubview(showView, at: 0)
        brightFilter?.addTarget(showView)
        
        // 启动相机
        stillCamera?.startCapture()

    }

    @IBAction func captureAction(_ sender: UIButton) {
        stillCamera?.capturePhotoAsImageProcessedUp(toFilter: brightFilter, withCompletionHandler: { (image, error) in
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            self.stillCamera?.startCapture()
        })
    }
    
    @IBAction func rotateCameraAction(_ sender: UIButton) {
        stillCamera?.rotateCamera()
    }
    
    @IBAction func albumAction(_ sender: UIButton) {
        let imagePcker = UIImagePickerController()
        imagePcker.sourceType = .photoLibrary
        self.present(imagePcker, animated: true, completion: nil)
    }
    
}


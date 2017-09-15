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

    // 相机
    fileprivate var stillCamera: GPUImageStillCamera?
    
    // 初始化滤镜
    fileprivate let exposureFilter    = GPUImageExposureFilter()   // 曝光
    fileprivate let bilateralFilter   = GPUImageBilateralFilter()  // 磨皮
    fileprivate let brightnessFilter  = GPUImageBrightnessFilter() // 美白
    fileprivate let satureationFilter = GPUImageSaturationFilter() // 饱和
    
    fileprivate var filterGroup: GPUImageFilterGroup?
    
    fileprivate var showView = GPUImageView(frame: UIScreen.main.bounds)
    
    @IBOutlet weak var beautySetViewCons: NSLayoutConstraint!
    
    @IBOutlet weak var cameraActionCons: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建相机
        // swift 3.0 AVCaptureSessionPreset640x480
        // swift 4.0 AVCaptureSession.Preset.vga640x480.rawValue
        // 全屏 AVCaptureSession.Preset.hd1280x720
        stillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .front)
        // 设置为竖屏
        stillCamera?.outputImageOrientation =  .portrait
        
        // 创建滤镜
        filterGroup = setupGroupFilter()
        filterGroup?.addTarget(showView)
        
        // 创建实时显示的画面 View
        view.insertSubview(showView, at: 0)
        stillCamera?.addTarget(filterGroup)
        
        // 启动相机
        stillCamera?.startCapture()

    }
    
    fileprivate func setupGroupFilter() -> GPUImageFilterGroup {
        // 创建滤镜组
        let filterGroup = GPUImageFilterGroup()
        // 关联滤镜
        bilateralFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(satureationFilter)

        // 设置滤镜组起点和终点 filter
        filterGroup.initialFilters = [bilateralFilter]
        filterGroup.terminalFilter = satureationFilter
        //返回滤镜组
        return filterGroup
    }

    @IBAction func captureAction(_ sender: UIButton) {
        // 拍摄图片
        stillCamera?.capturePhotoAsImageProcessedUp(toFilter: filterGroup, withCompletionHandler: { (image, error) in
            if let image = image {
                // 将图片存入相册
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
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
    
    @IBAction func showBeautySetView(_ sender: UIButton) {
        
        if self.beautySetViewCons.constant == 0 {
            UIView.animate(withDuration: 0.25) {
                self.beautySetViewCons.constant = -250
                self.cameraActionCons.constant = 0
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.beautySetViewCons.constant = 0
                self.cameraActionCons.constant = -120
            })
        }
    }
}

extension ViewController {
    
    @IBAction func switchBeautyStatus(_ sender: UISwitch) {
        if sender.isOn {
            stillCamera?.removeAllTargets()
            stillCamera?.addTarget(filterGroup)
            filterGroup?.addTarget(showView)
        } else {
            stillCamera?.removeAllTargets()
            stillCamera?.addTarget(showView)
        }
    }
    
    @IBAction func confirmAction() {
        showBeautySetView(UIButton())
    }
    
    @IBAction func BilateralFilterSlider(_ sender: UISlider) {
        bilateralFilter.distanceNormalizationFactor = CGFloat(sender.value) * 8
        bilateralFilter.texelSpacingMultiplier = 4
    }
    
    // -10 --- 10
    @IBAction func exposureFilterSlider(_ sender: UISlider) {
        exposureFilter.exposure = CGFloat(sender.value) * 20 - 10
    }
    
    // -1 --- 1
    @IBAction func brightnessFilterSlider(_ sender: UISlider) {
        brightnessFilter.brightness = CGFloat(sender.value)*2 - 1
    }
    
    @IBAction func satureationFilterSlider(_ sender: UISlider) {
        satureationFilter.saturation = CGFloat(sender.value)*2
    }
}

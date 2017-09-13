//
//  ViewController.swift
//  AVCaptureByGPUImage
//
//  Created by Mazy on 2017/9/13.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    fileprivate lazy var videoCamera: GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .front)
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视频才采集的画面样式
        videoCamera.outputImageOrientation = .portrait
        
        // 添加滤镜
        videoCamera.addTarget(filter)
        
        // 设置代理，监听采集到的视频
        videoCamera.delegate = self
        
        // 添加一个用于实时显示画面的GPUImageView
        let gpuImageView = GPUImageView(frame: view.bounds)
        view.addSubview(gpuImageView)
        
        // 给显示画面添加滤镜
        filter.addTarget(gpuImageView)
        
        // 开始采集视频
        videoCamera.startCapture()
    }
    
    @IBAction func switchCamera() {
    }
    
    @IBAction func pauseAction(_ sender: UIButton) {
    }

    @IBAction func closeOrBeginAction(_ sender: UIButton) {
    }
    
}

extension ViewController: GPUImageVideoCameraDelegate {
    
    // output video sampleBuffer
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}


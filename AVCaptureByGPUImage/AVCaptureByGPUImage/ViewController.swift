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
    
    /// 初始化相机
    fileprivate lazy var videoCamera: GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .front)
    /// 设置图片预览视图
    fileprivate var gpuImageView: GPUImageView?
    /// 懒加载高亮滤镜
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视频才采集的画面样式 - 竖屏
        videoCamera.outputImageOrientation = .portrait

        // 添加滤镜（如果不添加滤镜，无法看到图像）
        videoCamera.addTarget(filter)

        // 设置代理，监听采集到的视频
        videoCamera.delegate = self

        // 设置并添加用于实时显示画面的GPUImageView
        gpuImageView = GPUImageView(frame: view.bounds)
        if let gpuImageView = gpuImageView {
            // 添加到最底层
            view.insertSubview(gpuImageView, at: 0)
            // 给显示画面添加滤镜
            filter.addTarget(gpuImageView)
        }


        // 开始采集视频
        videoCamera.startCapture()
    }
    
    
    /// 旋转摄像头
    @IBAction func switchCamera() {
        videoCamera.rotateCamera()
    }
    
    
    /// 暂停和恢复
    @IBAction func pauseAction(_ sender: UIButton) {
        sender.setTitle("Pause", for: .normal)
        sender.setTitle("Resume", for: .selected)
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            // 暂停
            videoCamera.pauseCapture()
        } else {
            // 恢复
            videoCamera.resumeCameraCapture()
        }
        
    }

    /// 开始和结束
    @IBAction func closeOrBeginAction(_ sender: UIButton) {
        sender.setTitle("Stop", for: .normal)
        sender.setTitle("Start", for: .selected)
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            // 停止
            videoCamera.stopCapture()
            gpuImageView?.removeFromSuperview()
        } else {
            
            if let gpuImageView = gpuImageView {
                view.insertSubview(gpuImageView, at: 0)
                // 给显示画面添加滤镜
                filter.addTarget(gpuImageView)
            }
            // 开始
            videoCamera.startCapture()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCamera.stopCapture()
        // 移除输入输出源
        videoCamera.removeInputsAndOutputs()
        gpuImageView?.removeFromSuperview()
    }
    
}


// MARK: - GPUImageVideoCameraDelegate
extension ViewController: GPUImageVideoCameraDelegate {
    // output video sampleBuffer
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}


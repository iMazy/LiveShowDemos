//
//  ViewController.swift
//  AVCaptureByAVFoundation
//
//  Created by Mazy on 2017/9/12.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    fileprivate var captureSession: AVCaptureSession!
    fileprivate var videoOutput: AVCaptureVideoDataOutput?
    fileprivate var videoInput: AVCaptureDeviceInput?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 创建捕捉会话（AVCaptureSession）
        captureSession = AVCaptureSession()
        
        // 设置视频输入源&输出源
//         - 输入源（AVCaptureDeviceInput）：从摄像头输入
//         - 输出源（AVCaptureVideoDataOutput）：可以设置代理，在代理方法中拿到数据
//         - 将输入&输出添加到会话中
        setupVideoInputOutput()
        
        // 设置音频输入源&输出源
        setupAudioInputOutput()
        
        // 添加预览图层
        setupPreviewLayer()
        
        // 开始采集即可
        captureSession.startRunning()
    }
    
    /// 设置视频输入源&输出源
    func setupVideoInputOutput() {
        // iOS 10.0 +
        // let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType(rawValue: AVMediaTypeVideo), mediaType: AVMediaTypeVideo, position: .front)
        
        // 取出所有的设备
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else { return }
        // 过滤出前置摄像头
        guard let device = devices.filter({ $0.position == .front }).first else { return }
        // 创建输入设备
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        self.videoInput = input
        
        // 创建输出设备
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        self.videoOutput = output
        
        // 添加输入输出设备
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
    }
    
    /// 设置音频输入源&输出源
    func setupAudioInputOutput() {
        // 取出所有的设备
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) else { return }
        // 创建输入设备
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }

        // 创建输入设备
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        // 添加输入输出设备
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
    }
    
    /// 添加预览图层（可选）
    func setupPreviewLayer() {
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
        previewLayer.frame = view.bounds
        self.previewLayer = previewLayer
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    /// 转换摄像头
    func rotateCamera() {
        // 获取当前设备的的摄像头方向
        guard let videoInput = videoInput else { return }
        let position: AVCaptureDevicePosition = videoInput.device.position == .front ? .back : .front
        guard let devices = (AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]) else { return }
        guard let device = devices.filter({ $0.position == position }).first else { return }
        guard let newInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        // 开启配置
        captureSession.beginConfiguration()
        captureSession.removeInput(videoInput)
        captureSession.addInput(newInput)
        captureSession.commitConfiguration()
        
        // 记录最新的 input
        self.videoInput = newInput
    }
    
    
    /// 停止音视频采集
    func stopCapturing() {
        captureSession.stopRunning()
        self.previewLayer.removeFromSuperlayer()
    }
    
    @IBAction func stopCapture() {
        stopCapturing()
    }
    
    
    @IBAction func translateCamera(_ sender: UIButton) {
        rotateCamera()
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if self.videoOutput?.connection(withMediaType: AVMediaTypeVideo) == connection {
            print("采集到视频文件")
        } else {
            print("采集到音频文件")
        }
    }
}

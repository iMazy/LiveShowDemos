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

    fileprivate var captureSession: AVCaptureSession?
    fileprivate var videoOutput: AVCaptureVideoDataOutput?
    fileprivate var videoInput: AVCaptureDeviceInput?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建捕捉会话（AVCaptureSession）
        captureSession = AVCaptureSession()

        // 设置视频输入源&输出源
        setupVideoInputOutput()

        // 设置音频输入源&输出源
        setupAudioInputOutput()

        // 添加预览图层
        setupPreviewLayer()

        // 开始采集即可
        captureSession?.startRunning()
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
        if let session = captureSession {
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
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
        if let session = captureSession {
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }
    }
    
    /// 添加预览图层
    func setupPreviewLayer() {
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
        previewLayer.frame = view.bounds
        self.previewLayer = previewLayer
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    /// 转换摄像头
    func switchCamera() {
        
        // 添加切换动画
        let rotaionAnim = CATransition()
        rotaionAnim.type = "oglFlip"
        rotaionAnim.subtype = "fromLeft"
        rotaionAnim.duration = 0.25
        view.layer.add(rotaionAnim, forKey: nil)
        
        // 获取当前设备的的摄像头方向
        guard let videoInput = videoInput else { return }
        // 获取当前摄像头方向 并切换
        let position: AVCaptureDevicePosition = videoInput.device.position == .front ? .back : .front
        guard let devices = (AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]) else { return }
        guard let device = devices.filter({ $0.position == position }).first else { return }
        guard let newInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        /// 开启配置
        // 开始配置
        captureSession?.beginConfiguration()
        captureSession?.removeInput(videoInput)
        captureSession?.addInput(newInput)
        // 结束配置
        captureSession?.commitConfiguration()
        
        // 记录最新的 input
        self.videoInput = newInput
    }
    
    
    /// 停止音视频采集
    func stopCapturing() {
        // 先移除预览视图
        self.previewLayer?.removeFromSuperlayer()
        // 停止视频采集
        captureSession?.stopRunning()
        // 置空 session
        captureSession = nil
    }
    
    @IBAction func stopCapture() {
        stopCapturing()
    }
    
    
    @IBAction func translateCamera(_ sender: UIButton) {
        switchCamera()
    }
    
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if self.videoOutput?.connection(withMediaType: AVMediaTypeVideo) == connection {
            print("采集到视频文件")
        } else {
            print("采集到音频文件")
        }
    }
}

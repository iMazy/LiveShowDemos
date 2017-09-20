//
//  ViewController.swift
//  Audio&VideoPlay
//
//  Created by Mazy on 2017/9/19.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

// http://baobab.wdjcdn.com/14559682994064.mp4


/*
 Make sure to change the name of your tune as well as the extension. The file needs to be properly imported (Project Build Phases > Copy Bundle Resources). You might want to place it in assets.xcassets for greater convenience.
 */
class ViewController: UIViewController {
    
    // 定义一个播放器属性
    fileprivate var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playShortAudio() {
        // 注意
        // 这里的资源长度最多30秒
        // 资源必须 Project Build Phases > Copy Bundle Resources 引入资源文件，否则获取不到文件
        if let soundURL = Bundle.main.url(forResource: "buyao", withExtension: "wav") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            // Play
            AudioServicesPlaySystemSound(mySound);
        }
    }
    
    @IBAction func playMusic() {
        
        // 2.获取对应音乐资源
        guard let fileUrl = Bundle.main.url(forResource: "309769", withExtension: "mp3") else {
            return }
        // 3.创建对应的播放器
        do {
            player = try AVAudioPlayer(contentsOf: fileUrl)
        } catch {
            print(error)
        }
        
        // 4.准备播放
        player?.prepareToPlay()
    
        // 5.播放音乐
        player?.play()
        
        player?.delegate = self
    
    }
    
    @IBAction func playVideo() {
    }
    
}

extension ViewController: AVAudioPlayerDelegate {
    
}


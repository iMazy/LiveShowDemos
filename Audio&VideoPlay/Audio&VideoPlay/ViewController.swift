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

import IJKMediaFramework

// http://baobab.wdjcdn.com/14559682994064.mp4

/*
 Make sure to change the name of your tune as well as the extension. The file needs to be properly imported (Project Build Phases > Copy Bundle Resources). You might want to place it in assets.xcassets for greater convenience.
 */
class ViewController: UIViewController {
    
    // 定义一个播放器属性
    fileprivate var player: AVAudioPlayer?
    
    @IBOutlet weak var playerView: UIImageView!
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
        
        // 设置代理监听播放完成
        player?.delegate = self
        
        // 4.准备播放
        player?.prepareToPlay()

        // 5.播放音乐
        player?.play()
        

    }
    
    fileprivate func stop() {
        if player?.isPlaying ?? false {
            // 停止、暂停
            player?.stop()
        } else {
            player?.play()
        }
    }
    
    @IBAction func playVideo() {
    // 1.创建AVPlayer
    guard let url = URL(string: "http://baobab.wdjcdn.com/14559682994064.mp4") else { return }
    // 2.创建播放器
    // 提供数据,设置数据源
    let item = AVPlayerItem(url: url)
    // 负责控制播放,暂停、播放、指定时间播放等
    let player = AVPlayer(playerItem: item)
    
    // 3.创建图层,负责显示
    let layer = AVPlayerLayer(player: player)
    layer.frame = playerView.bounds
    playerView.layer.addSublayer(layer)
    
    // 4.播放视频
    player.play()
    }
    
    @IBAction func playByIjk() {
        // 1.打开硬解码
        let options = IJKFFOptions.byDefault()
        options?.setOptionIntValue(1, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer)
        
        // 2.初始化播放器
        guard let ijkPlayer = IJKFFMoviePlayerController(contentURLString: "http://baobab.wdjcdn.com/14559682994064.mp4", with: options) else { return }
        ijkPlayer.view.frame = playerView.bounds
        playerView.addSubview(ijkPlayer.view)
        
        // 3.开始进行播放
        ijkPlayer.prepareToPlay()
    }
    
}


// MARK: - AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    /// 完成播放
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("播放完成")
        }
    }
}


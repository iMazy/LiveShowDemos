//
//  ViewController.swift
//  BeautifiedImageWithFilters
//
//  Created by Mazy on 2017/9/13.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    fileprivate lazy var imagePlcker = UIImagePickerController()
    
    fileprivate var imagePicture: GPUImagePicture?
    
    fileprivate var filters: [[String : String]] {
        let path = Bundle.main.path(forResource: "Filters.plist", ofType: nil)
        return NSArray(contentsOfFile: path!) as! [[String: String]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePlcker.delegate = self
        imagePlcker.sourceType = .photoLibrary
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
    }
    
    @objc private func imageViewTapped() {
        present(imagePlcker, animated: true, completion: nil)
    }

    func processImage(_ image: UIImage, filter : GPUImageFilter) -> UIImage? {
        // 2.1.如果是对图像进行处理GPUImagePicture
//        let picProcess = GPUImagePicture(image: image)
        
        imagePicture?.removeAllTargets()
        
        // 2.2.添加需要处理的滤镜
        imagePicture?.addTarget(filter)
        
        // 2.3.处理图片
        // 代表着输出的结果会被用于获取图像
        filter.useNextFrameForImageCapture()
        // Image rendering 渲染图片
        imagePicture?.processImage()
        
        // print(imagePicture?.outputImageSize())
        
        // 2.4.取出最新的图片
        return filter.imageFromCurrentFramebuffer()
    }

}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as?UIImage {
            
            self.imageView.image = image
            
            imagePicture = GPUImagePicture(image: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (filters[row]["filterClass"] ?? "") + " " + (filters[row]["filterName"] ?? "")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let filterName = filters[row]["filterClass"] else { return }
        guard let filter = NSClassFromString(filterName) as? GPUImageFilter.Type else { return }
        guard let image = self.imageView.image else { return }
        self.imageView.image = self.processImage(image, filter: filter.init())
    }
}

//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import MapKit

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
//    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
    @IBOutlet weak var uglifySwitch: UISwitch!
    @IBOutlet weak var beautifySwitch: UISwitch!
    @IBOutlet weak var geotagSwitch: UISwitch!
    
    
    @IBOutlet weak var filterControls: UIView!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    var geotag: CLLocationCoordinate2D?
    
    
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CIColorControls")!
    
    var originalImage: UIImage? {
        didSet {
            
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            
            // 1x, 2x, or 3x
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
//        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    
    @IBAction func changeBrightness(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func changeContrast(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func changeSaturation(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func uglify(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func beautify(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func geotagTapped(_ sender: Any) {
        setupGeoTag()
    }
    
    
    // Location Functions
    
    func setupGeoTag() {
        
        
        
    }
    
    
    
    // Filter functions
    func updateImage() {
        if let scaledImage  = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func image(byFiltering image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Set the values of the filters parameters
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(saturationSlider.value, forKey: "inputSaturation")
        filter.setValue(brightnessSlider.value, forKey: "inputBrightness")
        filter.setValue(contrastSlider.value, forKey: "inputContrast")
        
        // The metadata to be processed. NOT the actual filtered image
        guard let outputCIImage = filter.outputImage else { return image }
        
        // This is a visual Image that has been processed
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        let uiFinal = UIImage(cgImage: outputCGImage)
        
        var uglyImage: UIImage?
        if uglifySwitch.isOn {
            uglyImage = uglify(image: uiFinal)
        }
        
        var finalImage: UIImage?
        if beautifySwitch.isOn {
            if let uglyImage = uglyImage {
                finalImage = beautify(image: uglyImage)
            } else {
                finalImage = beautify(image: uiFinal)
            }
        }
        
        if let finalImage = finalImage {
            return finalImage
        } else if let uglyImage = uglyImage {
            return uglyImage
        } else {
            return uiFinal
        }
        
        
    }
    
    func uglify(image: UIImage) -> UIImage {
        let uglyFilter = CIFilter(name: "CIColorInvert")!
        guard let cgImage = image.cgImage else { return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        uglyFilter.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = uglyFilter.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func beautify(image: UIImage) -> UIImage {
        let beautyFilter = CIFilter(name: "CIPhotoEffectChrome")!
        guard let cgImage = image.cgImage else { return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        beautyFilter.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = beautyFilter.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func showFilterControls() {
        filterControls.isHidden = false
        filterControls.isUserInteractionEnabled = true
    }
    
    
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let originalImage = originalImage else { return }
        
        let processedImage = self.image(byFiltering: originalImage)
        
        guard let imageData = processedImage.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
//    func setImageViewHeight(with aspectRatio: CGFloat) {
//
//        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
//
//        view.layoutSubviews()
//    }
    
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
//        setImageViewHeight(with: image.ratio)
        
        originalImage = image
        showFilterControls()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

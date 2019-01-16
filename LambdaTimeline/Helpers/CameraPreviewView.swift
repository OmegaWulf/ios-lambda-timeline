//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Nikita Thomas on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}

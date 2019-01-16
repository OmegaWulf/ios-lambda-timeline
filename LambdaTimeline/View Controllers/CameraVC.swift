//
//  CameraVC.swift
//  LambdaTimeline
//
//  Created by Nikita Thomas on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraVC: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    var capturedVideoURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup capture session
        
        let captureSession = AVCaptureSession()
        
        // Add Inputs
        
        let camera = bestCamera()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Could not add camera to capture session")
        }
        
        captureSession.addInput(cameraInput)
        
        
        // Add Outputs
        
        let movieOutput = AVCaptureMovieFileOutput()
        recordOutput = movieOutput
        
        guard captureSession.canAddOutput(movieOutput) else { fatalError("Cannot add movie file output to capture sessions")}
        
        captureSession.addOutput(movieOutput)
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        
    }
    
    
    private func bestCamera() -> AVCaptureDevice {
        
        // iPhone X or plus
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
            
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            // This should only run on simulator or device without camera
            fatalError("Missing camera")
        }
    }
    
    private func newRecordingURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        
        
        return tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        DispatchQueue.main.async {
            self.updateButton()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        DispatchQueue.main.async {
            
            defer { self.updateButton() }
            self.capturedVideoURL = outputFileURL
            
            self.performSegue(withIdentifier: "toEditVideo", sender: nil)
            
        }
    }
    
    
    func updateButton() {
        
        let isRecording = recordOutput.isRecording
        let buttonImage = isRecording ? "Stop" : "Record"
        
        recordButton.setImage(UIImage(named: buttonImage), for: .normal)
        
    }
 
     
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVideo" {
            let dest = segue.destination as! VideoPostVC
            
            dest.capturedVideoURL = capturedVideoURL
        }
     }
 
    
}

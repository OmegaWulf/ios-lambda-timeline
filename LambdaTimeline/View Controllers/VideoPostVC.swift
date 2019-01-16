//
//  VideoPostVC.swift
//  LambdaTimeline
//
//  Created by Nikita Thomas on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostVC: UIViewController {
    
    var capturedVideoURL: URL!
    var player: AVPlayer?
    var isPlaying: Bool = false
    
    
    @IBOutlet weak var postTitle: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
//        if !isPlaying {
            player?.play()
            playButton.isHidden = true
//            isPlaying = true
        
             NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
//        } else {
//            player?.pause()
//        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //        print("Video Finished")
        //        isPlaying = false
        playButton.isHidden = false
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        guard let text = postTitle.text, !text.isEmpty else { return }
        let postCont = PostController()
        
        do {
            let videoData = try Data(contentsOf: capturedVideoURL)
            
            postCont.createPost(with: text, ofType: .video, mediaData: videoData) { (success) in
                guard success else {
                    NSLog("Could not createPost")
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }
        } catch {
            NSLog("Could not convert video into data: \(error)")
        }
        
    }
    
    func setupPlayer() {
        
        self.player = AVPlayer(url: capturedVideoURL)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        
        layer.frame = videoView.layer.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        
        videoView.layer.addSublayer(layer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

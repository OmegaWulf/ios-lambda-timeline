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
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if !isPlaying {
            player?.play()
            playButton.isHidden = true
            isPlaying = true
        } else {
            player?.pause()
            playButton.isHidden = false
            isPlaying = false
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

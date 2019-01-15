//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, AVAudioRecorderDelegate {
    
    var recorder: AVAudioRecorder?
    var recordingURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        let alert = UIAlertController(title: "Text or Voice?", message: "Write your comment or send a voice comment", preferredStyle: .alert)
        
        let textAction = UIAlertAction(title: "Text", style: .default) { (_) in
            self.showTextAlert()
        }
        
        let voiceAction = UIAlertAction(title: "Voice", style: .default) { (_) in
            self.showRecordAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(textAction)
        alert.addAction(voiceAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func showTextAlert() {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func showRecordAlert() {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 115)
        
        let recordButton = UIButton(frame: CGRect(x: 75, y: 0, width: 95, height: 95))
        vc.view.addSubview(recordButton)
        
        recordButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        recordButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 8)
        recordButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        recordButton.widthAnchor.constraint(equalToConstant: CGFloat(150))
        recordButton.heightAnchor.constraint(equalToConstant: CGFloat(150))
        
        
        let recordImage = UIImage(named: "recordButton")
        recordButton.setImage(recordImage, for: .normal)
        
        
        recordButton.addTarget(self, action: #selector(holdRelease), for: UIControl.Event.touchUpInside)
        recordButton.addTarget(self, action: #selector(holdDown), for: UIControl.Event.touchDown)
        
        
        let alert = UIAlertController(title: "Hold To Record Your Comment", message: "", preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    @objc func holdDown(sender:UIButton) {
        // Start recording
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
            
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording")
        }
        
    }
    
    
    @objc func holdRelease(sender:UIButton) {
        // Stop recording
        recorder?.stop()
        recordingURL = recorder?.url
        self.recorder = nil
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func newRecordingURL() -> URL {
        
        let fileManager = FileManager.default
        let documentsDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // The UUID is the name of the file
        let newRecordingURL = documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        
        return newRecordingURL
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}

//
//  ViewController.swift
//  cameraFaceText
//
//  Created by IPS-177  on 29/12/23.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices


class CameraVC: UIViewController  {
    
    
    @IBOutlet weak var recordLiveVideoBtn: UIButton!
    
    var myPickedVideo: NSURL! = NSURL()
    var VideoToPass: Data!
    var recordingTimer: Timer?
    var recordingDuration: TimeInterval = 30
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
   
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

  

    @IBAction func recordLiveVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera Available")

            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.sourceType = .camera
            videoPicker.mediaTypes = [kUTTypeMovie as String]
            videoPicker.allowsEditing = false
            present(videoPicker, animated: true, completion: nil)
           
        } else {
            print("Camera Unavailable")
        }
    }


}

// MARK: - UIImagePickerControllerDelegate
extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true, completion: nil)
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else {
            return
        }
        
        if let pickedVideo: NSURL = (info[UIImagePickerController.InfoKey.mediaURL] as? NSURL) {
            
            self.myPickedVideo = pickedVideo
            
            do {
                try? VideoToPass = Data(contentsOf: pickedVideo as URL)
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentsDirectory = paths[0]
                let tempPath = documentsDirectory.appendingFormat("/vid.mp4")
                let url = URL(fileURLWithPath: tempPath)
                do {
                    try? VideoToPass.write(to: url, options: [])
                }
            }
        }
        
        UISaveVideoAtPathToSavedPhotosAlbum(
            url.path,
            self,
            #selector(video(_:didFinishSavingWithError:contextInfo:)),
            nil)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func DisplayVideoFromData(videoURL: NSURL, myView: UIView) {
        
        let player = AVPlayer(url: videoURL as URL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.needsDisplayOnBoundsChange = true
        playerLayer.frame = myView.bounds
        
        myView.layer.masksToBounds = true
        myView.layer.addSublayer(playerLayer)
        
        player.play()
    }
}

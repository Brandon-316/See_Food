//
//  ViewController.swift
//  SeeFood
//
//  Created by Brandon Mahoney on 2/26/19.
//  Copyright © 2019 Brandon Mahoney. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    let apiKey = "eMqZG-8QdlUnOZekemABW5zS5zZzyzqKsEK71XihQw_i"
    let version = "2019-02-27"
    var classificationResults: [String] = []
    
    @IBOutlet weak var camera: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        camera.isEnabled = false
        SVProgressHUD.show()
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage

            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            visualRecognition.classify(image: userPickedImage) { (classifiedImages, error) in
                let classes = classifiedImages!.result!.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.camera.tintColor = UIColor.white
                    self.camera.isEnabled = true
                    self.shareButton.isHidden = false
                    SVProgressHUD.dismiss()
                    if self.classificationResults.contains("hotdog") {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = #imageLiteral(resourceName: "hotdog")
                    } else {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = #imageLiteral(resourceName: "not-hotdog")
                    }
                }
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title!)")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
            
        } else {
            self.navigationItem.title = "Please log in to Twitter"
        }
    }
    
    
}


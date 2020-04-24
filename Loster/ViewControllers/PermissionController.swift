//
//  PermissionController.swift
//  Loster
//
//  Created by Malovic, Milos on 4/21/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech


class PermissionController: UIViewController {
    
    // MARK: IBOutlet's
    
    @IBOutlet weak var permissonLbl: UILabel!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar(largeTitleColor: .systemIndigo, backgoundColor: .systemBackground, tintColor: .systemIndigo, title: "Privacy and permissions", preferredLargeTitle: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: Function's
    
    func checkPermissions() {
        UserDefaults.standard.set(false, forKey: "permissions")
        
        // check status for all three permissions
        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuthorized = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcibeAuthorized = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        // make a single boolean out of all three
        let authorized = photosAuthorized && recordingAuthorized && transcibeAuthorized
        
        // if we're missing one, show the first run screen
        if authorized == false {
            requestPhotosPermission()
        } else {
            let vc = LostStuffTableController.instantiate(from: "Main")
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UserDefaults.standard.set(true, forKey: "permissions")
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func requestPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.requestRecordPermisson()
                }
            }
        }
    }
    
    func requestRecordPermisson() {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] (allowed) in
            if allowed == true {
                DispatchQueue.main.async {
                    self.requestTranscribePermissions()
                }
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] (status) in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.checkPermissions()
                }
            }
        }
    }
    
    func authorizationComplete() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBAction's
    
    @IBAction func continueebtnPressed(_ sender: Any) {
        requestPhotosPermission()
    }
}

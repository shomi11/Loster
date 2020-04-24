//
//  LostStuffTableController.swift
//  Loster
//
//  Created by Malovic, Milos on 4/21/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import CoreSpotlight
import MobileCoreServices

private let reuseIdentifier = "mainCell"

class LostStuffTableController: UITableViewController {
    
    // MARK: Class Properties
    
    var stuffs = [URL]()
    var filteredStuffs = [URL]()
    var activeStuff: URL!
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL!
    var audioPlayer: AVAudioPlayer?
    var searchQuery: CSSearchQuery?
    let searchController = UISearchController(searchResultsController: nil)
    let recordView = UIView()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        Auth.checkAuth { [weak self] (succes, error) in
            if error != nil {
                self?.presentAlertController(withTitle: "Authentifaction Failed", message: "Press ok if you want to try again", textField: nil, actions: (title: "OK", style: .default, handler: nil))
            } else if succes == true {
                // back table view if auth succes
                self?.tableView.isHidden = false
                
                // configure navigation bar
                self?.configureNavigationBar(largeTitleColor: .systemIndigo, backgoundColor: .systemBackground, tintColor: .systemIndigo, title: "Where is my stuff", preferredLargeTitle: true)
                
                // open camera btn
                let cameraBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self?.cameraBtnPressed))
                
                // open libraryBtn
                let libraryBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self?.libraryBtnPresssed))
                
                // set navigation bar btn's
                self?.navigationItem.rightBarButtonItems = [cameraBtn, libraryBtn]
                
                // set and add search controller
                self?.searchController.searchResultsUpdater = self
                self?.searchController.automaticallyShowsCancelButton = true
                self?.searchController.searchBar.placeholder = "What are you searching for ?"
                self?.navigationItem.searchController = self?.searchController
                
                // create a recording url
                 self?.recordingURL = self?.getDocumentsDirectory().appendingPathComponent("recording.m4a")
                
                // load stuff
                 self?.loadStuff()
            } else {
                self?.tableView.isHidden = true
            }
        }
    }
    
    // MARK: Class function's
    
    @objc func cameraBtnPressed() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.showsCameraControls = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func libraryBtnPresssed() {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .automatic
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func loadStuff() {
        stuffs.removeAll()
        
        // attempt to load all the stuff in documents directory
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else { return }

        // loop over every file found
        for file in files {
            let filename = file.lastPathComponent
            
            // check it ends with ".thumb" so we don't count each stuff more than once
            if filename.hasSuffix(".thumb") {
                // get the root name of the stuff (i.e., without its path extension)
                let noExtension = filename.replacingOccurrences(of: ".thumb", with: "")
                
                // create a full path from the stuff
                let stuffPath = getDocumentsDirectory().appendingPathComponent(noExtension)
                
                // add it to our array
                stuffs.append(stuffPath)
            }
        }
        
        filteredStuffs = stuffs
        
        // reload our list of memories
        self.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)

    }
    
    private func saveNewMemory(image: UIImage) {
        // create a unique name for this stuff
        let stuffName = "memory-\(Date().timeIntervalSince1970)"
        
        // use the unique name to create filenames for the full-size image and the thumbnail
        let imageName = stuffName + ".jpg"
        let thumbnailName = stuffName + ".thumb"
        
        do {
            // create a URL where we can write the JPEG to
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            
            // convert the UIImage into a JPEG data object”
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                // write that data to the URL we created
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            if let thumbnail = resizedImage(image: image, to: 150) {
                let imagePath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                if let jpegData = thumbnail.jpegData(compressionQuality: 0.8) {
                    try jpegData.write(to: imagePath, options: [.atomicWrite])
                }
            }
        } catch {
            print("Failed to save to disk.")
        }
    }
    
    func resizedImage(image: UIImage, to width: CGFloat) -> UIImage? {
        // calculate how much we need to bring the width down to match our target size
        let scale = width / image.size.width
        
        // bring the height down by the same amount so that the aspect ratio is preserved
        let height = image.size.height * scale
        
        // create a new image context we can draw into
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        
        // draw the original image into the context
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // pull out the resized version
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the context so UIKit can clean ”
        
        UIGraphicsEndImageContext()
        
        // send it back to the caller
        return newImage
    }
    
    @objc func memoryLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            
            // grabing current cell
            guard let cell = sender.view as? LostStuffTableViewCell else { return }
            if let index = tableView.indexPath(for: cell) {
                
                // add a view to cell that shows user what item is recorded for
                recordView.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height)
                recordView.backgroundColor = .systemRed
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                imageView.center = CGPoint(x: cell.contentView.frame.size.width  / 2,
                                           y: cell.contentView.frame.size.height / 2)
                imageView.image = UIImage(named: "record_icon")
                recordView.addSubview(imageView)
                cell.contentView.addSubview(recordView)
                activeStuff = stuffs[index.row]
                
                // record stuff item
                recordMemory()
            }
        } else if sender.state == .ended {
            finishRecording(success: true)
        }
    }
    
    func recordMemory() {
        audioPlayer?.stop()
       
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            // 1. configure the session for recording and playback through the speaker
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            // 2. set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // 3. create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch let error {
            // failed to record!
            print("Failed to record: \(error)")
            finishRecording(success: false)
        }
    }
    
    private func finishRecording(success: Bool) {

        // 1
        audioRecorder?.stop()
        
        if success {
            do {
                // 2
                recordView.removeFromSuperview()
                let stuffAudioURL = activeStuff.appendingPathExtension("m4a")
                let fm = FileManager.default
                
                // 3
                if fm.fileExists(atPath: stuffAudioURL.path) {
                    try fm.removeItem(at: stuffAudioURL)
                }
                
                // 4
                try fm.moveItem(at: recordingURL, to: stuffAudioURL)
                
                // 5
                transcribeAudio(memory: activeStuff)
            } catch let error {
                print("Failure finishing recording: \(error)")
            }
        }
    }
    
    private func transcribeAudio(memory: URL) {
        // get paths to where the audio is, and where the transcription should be
        let audio = audioURL(for: memory)
        let transcription = transcriptionURL(for: memory)
        
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: audio)
        
        // start recognition!”
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, we need to write it to disk
            if result.isFinal {
                // pull out the best transcription...
                let text = result.bestTranscription.formattedString
                // ...and write it to disk at the correct filename for this memory.
                do {
                    try text.write(to: transcription, atomically: true, encoding: String.Encoding.utf8)
                    self.indexMemory(memory: memory, text: text)
                    self.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
                } catch {
                    print("Failed to save transcription.")
                }
            }
        }
    }
    
    func indexMemory(memory: URL, text: String) {
        // create a basic attribute set
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = "My Stuff"
        attributeSet.contentDescription = text
        attributeSet.thumbnailURL = thumbnailURL(for: memory)
        
        // wrap it in a searchable item, using the memory's full path as its unique identifier
        let item = CSSearchableItem(uniqueIdentifier: memory.path, domainIdentifier: "com.Loster", attributeSet: attributeSet)
        
        // set never expire
        item.expirationDate = Date.distantFuture
        
        // ask Spotlight to index the item
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed: \(text)")
            }
        }
    }
    
    private func imageURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    private func thumbnailURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    private func audioURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }
    
    private func transcriptionURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }
    
    func dateCreated(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.creationDate] as? Date
        } catch let err {
            print(err.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStuffs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? LostStuffTableViewCell else {fatalError("no cell to deque")}
        
        if cell.gestureRecognizers == nil {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(memoryLongPress))
            recognizer.minimumPressDuration = 0.25
            cell.addGestureRecognizer(recognizer)
        }
        
        let stuff = filteredStuffs[indexPath.row]
        let imageName = thumbnailURL(for: stuff).path
        let image = UIImage(contentsOfFile: imageName)
        cell.stuffImageView.image = image
        
        let directory = getDocumentsDirectory()
        let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        if let files = files {
            let date = dateCreated(url: files[indexPath.row])
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = date {
                let stringDate = formatter.string(from: date)
                let formatedDate = formatter.date(from: stringDate)
                formatter.dateFormat = "EEEE, MMM d, yyyy"
                if let formatedDate = formatedDate {
                    let dt = formatter.string(from: formatedDate)
                    cell.dateLbl.text = dt
                }
            }
        }
        
        do {
            cell.descLbl.text = "Your transcribed text will apear hear"
            let textUrl = transcriptionURL(for: stuff).path
            let transcribedTxt = try String(contentsOfFile: textUrl)
            cell.descLbl.text = transcribedTxt
        } catch {
            print("there is no transcribed text")
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memory = filteredStuffs[indexPath.row]
        let fm = FileManager.default
        
        do {
            let audioName = audioURL(for: memory)
            let transcriptionName = transcriptionURL(for: memory)
            
            if fm.fileExists(atPath: audioName.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: audioName)
                audioPlayer?.play()
            }
            
            if fm.fileExists(atPath: transcriptionName.path) {
                let contents = try String(contentsOf: transcriptionName)
                print(contents)
            }
        } catch {
            print("Error loading audio")
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          
            let stuff = filteredStuffs[indexPath.row]
           
            let audio = audioURL(for: stuff)
            let txt = transcriptionURL(for: stuff)
            let jpg = imageURL(for: stuff)
            let thumb = thumbnailURL(for: stuff)
            
            let fm = FileManager.default
            
            if fm.fileExists(atPath: audio.path) {
                do {
                    try fm.removeItem(at: audio)
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            
            if fm.fileExists(atPath: txt.path) {
                do {
                    try fm.removeItem(at: txt)
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            
            if fm.fileExists(atPath: jpg.path) {
                do {
                    try fm.removeItem(at: jpg)
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            
            if fm.fileExists(atPath: thumb.path) {
                do {
                    try fm.removeItem(at: thumb)
                } catch let err {
                    print(err.localizedDescription)
                }
            }
         
            loadStuff()
        }
    }
}

extension LostStuffTableController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let possibleImage = info[.originalImage] as? UIImage {
            saveNewMemory(image: possibleImage)
            picker.dismiss(animated: true) { [unowned self] in
                self.loadStuff()
            }
        }
    }
}

extension LostStuffTableController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMemories(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterMemories(text: String) {
        
        guard text.count > 0 else {
            filteredStuffs = stuffs
            
            tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
            return
        }
        
        var allItems = [CSSearchableItem]()
        
        searchQuery?.cancel()
        
        let queryString = "contentDescription == \"*\(text)*\"c"
        searchQuery = CSSearchQuery(queryString: queryString, attributes: nil)
        
        searchQuery?.foundItemsHandler = { items in
            allItems.append(contentsOf: items)
        }
        
        searchQuery?.completionHandler = { error in
            DispatchQueue.main.async { [unowned self] in
                self.activateFilter(matches: allItems)
            }
        }
        searchQuery?.start()
    }
    
    func activateFilter(matches: [CSSearchableItem]) {
        filteredStuffs = matches.map { item in
            return URL(fileURLWithPath: item.uniqueIdentifier)
        }
        tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
    }
}

extension LostStuffTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterMemories(text: searchController.searchBar.text ?? "")
    }
}

extension LostStuffTableController: AVAudioRecorderDelegate { }

extension LostStuffTableController: UINavigationControllerDelegate { }


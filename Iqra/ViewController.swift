//
//  ViewController.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-04.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import AVFoundation
import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    var resultsController: ResultsTableController? = nil
    var searchQuery: String = ""
    var translationCode: String = "en-hilali"
    
    let networkRequestDelegate = NetworkDelegate()
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ar_AE"))
    let waitingPopover = UIAlertController(title: nil, message: "Please wait", preferredStyle: UIAlertControllerStyle.alert);
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    @IBOutlet var searchView: UITextField!
    @IBOutlet var speechButton: UIButton!
    @IBOutlet var micStatus: UILabel!
    @IBOutlet var IqraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempTranslation = UserDefaults.standard.string(forKey: "translationCode")
        
        if (tempTranslation == nil) {
            translationCode = "en-hilali"
        } else {
            translationCode = tempTranslation!
        }
    
        speechRecognizer?.delegate = self
        speechButton.isEnabled = false
        setupViewShadow()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                break
                
            case .denied:
                isButtonEnabled = false
                break
                
            case .restricted:
                isButtonEnabled = false
                break
                
            case .notDetermined:
                isButtonEnabled = false
                break
            }
            
            OperationQueue.main.addOperation() {
                self.speechButton.isEnabled = isButtonEnabled
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Do nothing
    }
    
    @IBAction func unwindToMainSegue(sender: UIStoryboardSegue) {
        let tempTranslation = UserDefaults.standard.string(forKey: "translationCode")
        
        if (tempTranslation == nil) {
            translationCode = "en-hilali"
        } else {
            translationCode = tempTranslation!
        }
    }
    
    private func setupViewShadow() {
        IqraView.layer.shadowColor = UIColor.black.cgColor
        IqraView.layer.shadowOpacity = 1
        IqraView.layer.shadowOffset = CGSize.zero
        IqraView.layer.shadowRadius = 5
    }
    
    
    @IBAction func settingsButton(_ sender: UIBarButtonItem) {
        presentPopoverMenu(sender)
    }
    
    private func beepSound() throws {
        AudioServicesPlaySystemSound(1113);
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechButton.isEnabled = true
        } else {
            speechButton.isEnabled = false
        }
    }
    
    private func startRecording() throws {
        
        if (recognitionTask != nil) {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        let inputNode = audioEngine.inputNode
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            var isFinal = false
            
            if let result = result {
                self.searchView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.speechButton.isEnabled = true
                self.endRecording()
            }
        })
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    private func searchCallback(_ data: Data, _ response: URLResponse) {
        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
        
        // Parse JSON data
        let result = jsonResponse!["result"] as! [String:AnyObject]
        let matches = result["matches"] as! [[String:Any]]
        
        // Create an array of Ayah's
        var results = [Ayah]()
        
        for ayah in matches {
            let arabicAyah = ayah["arabicAyah"] as! String
            let surahName = ayah["arabicSurahName"] as! String
            let ayahNum = ayah["ayahNum"] as! Int
            let surahNum = ayah["surahNum"] as! Int
            let translatedAyah = ayah["translationAyah"] as! String
            let translatedSurah = ayah["translationSurahName"] as! String
            
            let tempAyah = Ayah.init(arabicAyah, surahName, translatedAyah, translatedSurah, ayahNum, surahNum)
            
            results.append(tempAyah)
        }
        
        // Launch results segue
        DispatchQueue.main.async {
            self.resultsController = self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as! ResultsTableController
            
            // Shorten the list if necessary
            var finalResults = [Ayah]()
            
            if (results.count > 0) {
                if (results.count > 150) {
                    for i in 0..<150 {
                        finalResults.append(results[i])
                    }
                } else {
                    finalResults = results
                }
                
                self.resultsController?.results = finalResults
                self.resultsController?.selection = [Bool](repeating: true, count: finalResults.count)
                self.resultsController?.expectedCellHeight = [CGFloat](repeating: 0, count: finalResults.count)
                self.resultsController?.query = self.searchQuery
                self.resultsController?.actualResults = results.count
                self.resultsController?.selectedTranslationCode = self.translationCode
                
                self.dismissWaitingPopover()
            } else {
                self.micStatus.text = "No matches were found"
                self.resultsController = nil
                self.dismissWaitingPopover()
            }
        }
    }
    
    private func settingsActionTapped() {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "GeneralSettingsController") as! GeneralSettingsController
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    private func aboutActionTapped() {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "AboutController") as! AboutController
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    private func contactActionTapped() {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ContactController") as! ContactController
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    private func shareActionTapped() {
        let textToShare = "Check out this amazing app I\'ve been using called Iqra!"
        
        if let myWebsite = NSURL(string: "https://iqraapp.com/") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func presentPopoverMenu(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let settingsAction = UIAlertAction(title: "General Settings", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.settingsActionTapped()
        })
        alertController.addAction(settingsAction)
        
        let aboutAction = UIAlertAction(title: "About", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.aboutActionTapped()
        })
        alertController.addAction(aboutAction)
        
        let contactAction = UIAlertAction(title: "Contact", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.contactActionTapped()
        })
        alertController.addAction(contactAction)
        
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.shareActionTapped()
        })
        alertController.addAction(shareAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert :UIAlertAction!) in
            // Do nothing
        })
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentWaitingPopover() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        spinner.color = UIColor.black;
        spinner.center = CGPoint(x: 40, y: 30)
        spinner.startAnimating();
        
        waitingPopover.view.addSubview(spinner);
        
        present(waitingPopover, animated: true, completion: nil)
    }
    
    private func dismissWaitingPopover() {
        self.dismiss(animated: true, completion: {
            if (self.resultsController != nil) {
                self.navigationController?.pushViewController(self.resultsController!, animated: true)
            }
        })
    }
    
    @IBAction func speechRecognition(_ sender: UIButton) {
        try! beepSound()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speechButton.isEnabled = false
        } else {
            try! startRecording()
            beginRecording()
        }
    }
    
    private func beginRecording() {
        searchView.text = ""
        speechButton.setBackgroundImage(#imageLiteral(resourceName: "mic_active"), for: .normal)
        self.micStatus.text = "Please begin reciting"
        
        // Enable this for debugging purposes
        //searchView.text = "الله"
        //self.searchQuery = searchView.text!
    }
    
    private func endRecording() {
        
        // Search for results
        if ((searchView.text?.characters.count)! > 0) {
            presentWaitingPopover()
            
            let search = searchView.text!
            let target = "\u{e2}"
            let query = search.substring(from: target.endIndex)
            
            networkRequestDelegate.performSearchQuery(query, translationCode, searchCallback)
        }
        
        self.searchQuery = searchView.text!
        self.searchView.text = ""
        self.speechButton.setBackgroundImage(#imageLiteral(resourceName: "mic_inactive"), for: .normal)
        self.micStatus.text = "Tap on the mic and recite a full or partial verse"
    }
}


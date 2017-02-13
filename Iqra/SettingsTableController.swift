//
//  SettingsTableViewController.swift
//  IqraApp
//
//  Created by Hussain Al-Homedawy on 2016-12-05.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class SettingsTableController: UITableViewController {
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    let settings = ["General Settings", "About", "Contact", "Share"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let source = sender as! UIBarButtonItem
        
        if (source === backButton) {
            // do nothing
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 0:
            // General Settings
            let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "GeneralSettingsController") as! GeneralSettingsController
            self.navigationController?.pushViewController(storyboard, animated: true)

            break
        case 1:
            // About
            let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "AboutController") as! AboutController
            self.navigationController?.pushViewController(storyboard, animated: true)
            
            break
        case 2:
            // Contact      
            let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ContactController") as! ContactController
            self.navigationController?.pushViewController(storyboard, animated: true)
            
            break
        case 3:
            // Share
            let textToShare = "Check out this amazing app I\'ve been using called Iqra!"
            
            if let myWebsite = NSURL(string: "https://iqraapp.com/") {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
            
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCellContainer
        
        // Configure cell
        cell.settingsTitle.text = settings[indexPath.row]
        
        return cell
    }
    
    @IBAction func unwindToSettingsSegue(sender: UIStoryboardSegue) {
        let sourceViewController = sender.source
        
        if ((sourceViewController as? GeneralSettingsController) != nil) {
            // do nothing
        }
    }
}

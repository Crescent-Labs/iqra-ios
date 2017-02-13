//
//  ContactController.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-07.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class ContactController: UIViewController {
    
    let networkRequestDelegate = NetworkDelegate()
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var messageField: UITextField!
    @IBOutlet var sendButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let source = sender as! UIBarButtonItem
        
        if (source === sendButton) {
            networkRequestDelegate.sendMessage(nameField.text!, messageField.text!, emailField.text!)
        }
    }
    
}

//
//  SettingsController.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-04.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class GeneralSettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var pickerView: UIPickerView!
    
    var translationSource = ["Sahih International", "A. J. Arberry", "Muhammad Asad",
                            "Abdul Majid Daryabadi", "Abdullah Yusuf Ali", "Sayyid Abul Ala Maududi",
                            "Mohammad Habib Shakir", "Mohammed Marmaduke William Pickthall", "Professor Shaykh Hasan Al-Fatih Qaribullah", "Muhammad Sarwar", "Dr. Muhammad Taqi-ud-Din al-Hilali and Dr. Muhammad Muhsin Khan", "Transliteration"];
    
    var translationCode = ["en-sahih", "en-arberry", "en-asad", "en-daryabadi", "en-hilali", "en-pickthall",
                           "en-qaribullah", "en-sarwar", "en-yusufali", "en-maududi", "en-shakir",
                           "en-transliteration"];
    
    var selectedTranslationCode: String = "en-hilali"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempTranslation = UserDefaults.standard.string(forKey: "translationCode")
        
        if (tempTranslation == nil) {
            selectedTranslationCode = "en-hilali"
        } else {
            selectedTranslationCode = tempTranslation!
        }
        
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        let index = translationCode.index(of: selectedTranslationCode)
        
        if (index != nil) {
            pickerView.selectRow(index!, inComponent: 0, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let source = sender as! UIBarButtonItem
        
        if (source == backButton) {
            // do nothing
        } else if (source == saveButton) {
            UserDefaults.standard.set(selectedTranslationCode, forKey: "translationCode")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTranslationCode = translationCode[row]
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return translationSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {        
        return translationSource[row]
    }
}

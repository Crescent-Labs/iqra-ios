//
//  ResultsViewCell.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-11.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class ResultsViewCell: UITableViewCell {
    
    var tableView: UIView? = nil
    var tableViewController: ResultsTableController? = nil
    
    var ayahNum: Int = 0
    var surahNum: Int = 0
    
    @IBOutlet var translatedSurahName: UILabel!
    @IBOutlet var arabicSurahName: UILabel!
    @IBOutlet var verseNumber: UILabel!
    
    @IBOutlet var arabicVerse: UITextView!
    @IBOutlet var translatedVerse: UITextView!
    
    @IBOutlet var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arabicSurahName.textAlignment = .right
        translatedVerse.textAlignment = .left
        verseNumber.textAlignment = .right
        
        arabicVerse.textAlignment = .right
        translatedVerse.textAlignment = .left
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        presentPopoverMenu(sender)
    }
    
    private func shareAyah (_ ayah: Ayah, _ arabic: Bool, _ english: Bool) {
        // Share
        var textToShare = "";
        
        if (arabic) {
            textToShare = textToShare + "\(ayah.arabicAyah) \n(\(ayah.surahName) الآيه \(ayah.surahNum):\(ayah.ayahNum))"
        }
        
        if (arabic && english) {
            textToShare = textToShare + "\n\n"
        }
        
        if (english) {
            textToShare = textToShare + "\(ayah.translatedAyah) \n(\(ayah.translatedSurah) verse \n(\(ayah.surahNum):\(ayah.ayahNum))"
        }
        
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = tableView
        tableViewController!.present(activityVC, animated: true, completion: nil)
        
    }
    
    private func presentPopoverMenu(_ sender: UIButton) {
        let ayah = Ayah(arabicVerse.text!, arabicSurahName.text!, translatedVerse.text!, translatedSurahName.text!, ayahNum, surahNum)
        
        let alertController = UIAlertController(title: "Share", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let arabicAyah = UIAlertAction(title: "Arabic Ayah", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.shareAyah(ayah, true, false)
        })
        alertController.addAction(arabicAyah)
        
        let englishAyah = UIAlertAction(title: "English Ayah", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.shareAyah(ayah, false, true)
        })
        alertController.addAction(englishAyah)
        
        let both = UIAlertAction(title: "Both", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            self.shareAyah(ayah, true, true)
        })
        alertController.addAction(both)
        
        tableViewController!.present(alertController, animated: true, completion: nil)
    }
    
}

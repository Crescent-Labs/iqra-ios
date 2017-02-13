//
//  ResultsTableController.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-11.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class ResultsTableController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let networkRequestDelegate = NetworkDelegate()
    
    let waitingPopover = UIAlertController(title: nil, message: "Please wait", preferredStyle: UIAlertControllerStyle.alert);
    
    var query = "Results"
    var results = [Ayah]()
    var actualResults: Int = 0
    var selection = [Bool]()
    var expectedCellHeight = [CGFloat]()
    var prevSelectedRow: IndexPath? = nil
    var changedTranslation: Bool = false
    
    var translationSource = ["Sahih International", "A. J. Arberry", "Muhammad Asad",
                             "Abdul Majid Daryabadi", "Abdullah Yusuf Ali", "Sayyid Abul Ala Maududi",
                             "Mohammad Habib Shakir", "Mohammed Marmaduke William Pickthall", "Professor Shaykh Hasan Al-Fatih Qaribullah", "Muhammad Sarwar", "Dr. Muhammad Taqi-ud-Din al-Hilali and Dr. Muhammad Muhsin Khan", "Transliteration"];
    
    var translationCode = ["en-sahih", "en-arberry", "en-asad", "en-daryabadi", "en-hilali", "en-pickthall",
                           "en-qaribullah", "en-sarwar", "en-yusufali", "en-maududi", "en-shakir",
                           "en-transliteration"];
    
    var selectedTranslationCode: String = "en-hilali"
    
    @IBOutlet var resultsView: UITextView!
    
    let ROW_HEIGHT: CGFloat = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (results.count != actualResults) {
            resultsView.text = "\(actualResults) results (not all shown):"
        } else {
            resultsView.text = "\(results.count) results:"
        }
        
        resultsView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let prevTranslationCode = selectedTranslationCode
        
        selectedTranslationCode = translationCode[row]
        
        if (prevTranslationCode != selectedTranslationCode) {
            changedTranslation = true
        } else {
            changedTranslation = false
        }
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle the selection state
        selection[indexPath.row] = !selection[indexPath.row]
        
        if (prevSelectedRow != nil && prevSelectedRow != indexPath) {
            selection[(prevSelectedRow?.row)!] = true
            tableView.reloadRows(at: [prevSelectedRow!], with: .none)
        } else if (prevSelectedRow == indexPath) {
            prevSelectedRow = nil
        }
        
        prevSelectedRow = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsViewCell", for: indexPath) as! ResultsViewCell
        
        // Configure the cell
        let ayah = results[indexPath.row]
        
        cell.tableView = tableView
        cell.tableViewController = self
        cell.ayahNum = ayah.ayahNum
        cell.surahNum = ayah.surahNum
        cell.arabicSurahName.text = ayah.surahName
        cell.translatedSurahName.text = ayah.translatedSurah
        cell.verseNumber.text = "\(ayah.surahNum):\(ayah.ayahNum)"
        cell.arabicVerse.isHidden = selection[indexPath.row]
        cell.translatedVerse.isHidden = selection[indexPath.row]
        cell.shareButton.isHidden = selection[indexPath.row]
        cell.arabicVerse.text = ayah.arabicAyah
        cell.translatedVerse.text = ayah.translatedAyah
        resizeTextView(cell.arabicVerse)
        resizeTextView(cell.translatedVerse)
        
        expectedCellHeight[indexPath.row] = cell.arabicVerse.frame.size.height + cell.translatedVerse.frame.size.height
        
        return cell
    }
    
    private func resizeTextView (_ textView: UITextView) {
        textView.isScrollEnabled = false
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selection[indexPath.row] == false) {
            return ROW_HEIGHT + expectedCellHeight[indexPath.row]
        }
        
        return ROW_HEIGHT
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ViewController
        
        viewController.translationCode = selectedTranslationCode
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        let tempTranslation = UserDefaults.standard.string(forKey: "translationCode")
        
        let alert = UIAlertController(title: "Current Translation", message: nil, preferredStyle: .actionSheet);
        
        // Create the picker
        let picker: UIPickerView = UIPickerView(frame: CGRect(x:alert.view.center.x * 0.1, y:0, width: 300, height: 200))
        
        // Set the pickers datasource and delegate
        picker.delegate = self;
        picker.dataSource = self;
        if (tempTranslation != nil) {
            let index = translationCode.index(of: tempTranslation!)
            
            if (index != nil) {
                picker.selectRow(index!, inComponent: 0, animated: true)
            }
        }
        
        // Add the picker to the alert controller
        alert.view.addSubview(picker);
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: picker.frame.height + 60)
        
        alert.view.addConstraint(height);
        
        // Tapping outside can cancel the dialog
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            if (self.changedTranslation) {
                self.repeatSearch()
            }
        })
        
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        present (alert, animated: true, completion: nil)
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
        self.dismiss(animated: true, completion: nil)
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
        
        prevSelectedRow = nil
        
        DispatchQueue.main.async {
            // Dismiss waiting popover
            self.dismissWaitingPopover()
            
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
                
                self.results = finalResults
                self.selection = [Bool](repeating: true, count: finalResults.count)
                self.expectedCellHeight = [CGFloat](repeating: 0, count: finalResults.count)
                self.actualResults = results.count
                
                // Reload the table view
                self.tableView.reloadData()
            }
        }
    }
    
    private func repeatSearch() -> Void {
        UserDefaults.standard.set(selectedTranslationCode, forKey: "translationCode")
        
        changedTranslation = false
        
        presentWaitingPopover()
        
        let search = query
        let target = "\u{e2}"
        let final = search.substring(from: target.endIndex)
        
        networkRequestDelegate.performSearchQuery(final, selectedTranslationCode, searchCallback)
    }
    
}

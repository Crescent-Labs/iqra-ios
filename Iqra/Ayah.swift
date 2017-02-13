//
//  Ayah.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-11.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import Foundation

class Ayah {
    var arabicAyah: String
    var surahName: String
    var translatedAyah: String
    var translatedSurah: String
    
    var ayahNum: Int
    var surahNum: Int
    
    init(_ arabicAyah: String, _ surahName: String, _ translatedAyah: String, _ translatedSurah: String, _ ayahNum: Int, _ surahNum: Int) {
        self.arabicAyah = arabicAyah
        self.surahName = surahName
        self.translatedAyah = translatedAyah
        self.translatedSurah = translatedSurah
        self.ayahNum = ayahNum
        self.surahNum = surahNum
    }
}

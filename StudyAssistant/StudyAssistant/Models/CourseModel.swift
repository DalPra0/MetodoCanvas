import Foundation
import SwiftUI

struct Course: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var code: String
    var professor: String
    var colorHex: String
    var syllabusURL: String?
    var canvasID: String?
    
    init(name: String, code: String, professor: String, colorHex: String, syllabusURL: String? = nil, canvasID: String? = nil) {
        self.name = name
        self.code = code
        self.professor = professor
        self.colorHex = colorHex
        self.syllabusURL = syllabusURL
        self.canvasID = canvasID
    }
    
    var color: Color {
        let hex = colorHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            return Color(red: r, green: g, blue: b)
        }
        
        return Color.blue
    }
}

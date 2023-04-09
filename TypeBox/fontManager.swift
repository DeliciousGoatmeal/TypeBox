//
//  fontManager.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI
import CoreText
import AppKit
import Combine


class FontInfoManager {
    
    var fontInfo: [FontInfo] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fontInfoManagerUpdated"), object: self)
        }
    }
    
    init(fontInfo: [FontInfo] = []) {
        self.fontInfo = fontInfo
    }
    
    func loadFonts(fontDirectories: [URL]) {
        DispatchQueue.global(qos: .userInitiated).async {
            var allFontInfo: [FontInfo] = []
            for directory in fontDirectories {
                let newFontInfo = fontsInDirectory(directory: directory)
                allFontInfo += newFontInfo
            }
            DispatchQueue.main.async {
                self.fontInfo = allFontInfo
            }
        }
    }
}




struct CustomDirectoriesManager {
    var customDirectories: [URL] {
        didSet {
            UserDefaults.standard.set(customDirectories.map { $0.path }, forKey: "customDirectories")
        }
    }
    
    init() {
        if let customDirectoryPaths = UserDefaults.standard.stringArray(forKey: "customDirectories") {
            customDirectories = customDirectoryPaths.map { URL(fileURLWithPath: $0) }
        } else {
            customDirectories = []
        }
    }
}

struct FontDirectoriesManager {

    var fontDirectories: [URL] {
        let defaultDirectories = [
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .localDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask).first!.appendingPathComponent("Fonts"),
            //FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("Adobe/CoreSync/plugins/livetype/.r")
        ]

        return Array(Set(defaultDirectories + customDirectories)) // Remove duplicates
    }

    private var customDirectories: [URL] {
        if let customDirectoryPaths = UserDefaults.standard.stringArray(forKey: "customDirectories") {
            return customDirectoryPaths.map { URL(fileURLWithPath: $0) }
        }
        return []
    }
}


func getFontInfo(from fontDirectories: [URL]) -> [(path: String, fontFamily: String)] {
    var fontInfo: [(path: String, fontFamily: String)] = []

    for directory in fontDirectories {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            for fileURL in contents {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        fontInfo += getFontInfo(from: [fileURL])
                    } else {
                        let fontDescriptorsResult = CTFontManagerCreateFontDescriptorsFromURL(fileURL as CFURL)
                        if let fontDescriptors = fontDescriptorsResult as? [CTFontDescriptor], let descriptor = fontDescriptors.first, let fontName = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as? String {
                            fontInfo.append((path: fileURL.path, fontFamily: fontName))
                        } else {
                            if fileManager.isReadableFile(atPath: fileURL.path) {
                                print("Error processing font file: \(fileURL.path). Unable to create font descriptors.")
                                if let error = fontDescriptorsResult {
                                    print("CoreText error: \(error)")
                                }
                            } else {
                                print("Error processing font file: \(fileURL.path). The file is not readable.")
                            }
                        }
                    }
                }
            }
        } catch {
            print("I am getFontInfo. Error reading font files from directory: \(error.localizedDescription)")
        }
    }

    return fontInfo
}










enum FontStyle: String, CaseIterable {
    case regular = "Regular"
    case bold = "Bold"
    case italic = "Italic"
    case boldItalic = "Bold Italic"
    
    var uiFontSymbolicTrait: CTFontSymbolicTraits {
        switch self {
        case .regular:
            return []
        case .bold:
            return .traitBold
        case .italic:
            return .traitItalic
        case .boldItalic:
            return [.traitBold, .traitItalic]
        }
    }
}

func fontFamilyName(from fontPath: String) -> String {
    let fontURL = NSURL(fileURLWithPath: fontPath)
    if let fontDescriptors = CTFontManagerCreateFontDescriptorsFromURL(fontURL) as? [CTFontDescriptor],
       let descriptor = fontDescriptors.first {
        let familyName = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as! String
        return familyName
    }
    return "Unknown"
}

struct FontInfo: Equatable, Identifiable, Hashable {
    let id = UUID()
    let path: String
    let fontFamily: String
}


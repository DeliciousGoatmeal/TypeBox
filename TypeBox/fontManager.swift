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
    @StateObject private var customDirectoriesManager = CustomDirectoriesManager()
    
    @Published var fontInfo: [FontInfo]
    
    
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
                self.fontInfo = Array(Set(allFontInfo)).sorted { $0.fontFamily < $1.fontFamily }
            }
        }
    }


    
    func uniqueAndSortedFontInfos(_ fontInfos: [FontInfo]) -> [FontInfo] {
        var uniqueFontInfos: [FontInfo] = []
        var seenFontFamilies: Set<String> = []

        for fontInfo in fontInfos.sorted(by: { $0.fontFamily < $1.fontFamily }) {
            if !seenFontFamilies.contains(fontInfo.fontFamily) {
                uniqueFontInfos.append(fontInfo)
                seenFontFamilies.insert(fontInfo.fontFamily)
            }
        }
        return uniqueFontInfos
    }

    
}





class CustomDirectoriesManager: ObservableObject {
    @Published var customDirectories: [CustomDirectory] {
         didSet {
             UserDefaults.standard.set(customDirectories.map { $0.url.path }, forKey: "customDirectories")
         }
     }

     init() {
         if let customDirectoryPaths = UserDefaults.standard.stringArray(forKey: "customDirectories") {
             customDirectories = customDirectoryPaths.map { CustomDirectory(url: URL(fileURLWithPath: $0)) }
         } else {
             customDirectories = []
         }
     }

     func addDirectory(_ directory: URL) {
         customDirectories.append(CustomDirectory(url: directory))
     }
    
    func showDirectoryPicker() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a custom directory"
        openPanel.prompt = "Choose"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                self.addDirectory(url)
            }
        }
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


class FontLoader: ObservableObject {
    @Published var fontInfo: [FontInfo] = []
    @Published var fontsLoaded: Bool = false
    

    func loadFontsFromDirectories(_ fontDirectories: [URL]) {
        print("loadFontsFromDirectories called")
        DispatchQueue.global(qos: .userInitiated).async {
            var newFontInfo: [FontInfo] = []
            
            for directory in fontDirectories {
                print("Loading fonts from directory: \(directory)")
                newFontInfo += fontsInDirectory(directory: directory)
            }
            
            DispatchQueue.main.async {
                self.fontInfo = newFontInfo
                self.fontsLoaded = true
                print("Loaded font info: \(self.fontInfo)")
            }
        }
    }
}

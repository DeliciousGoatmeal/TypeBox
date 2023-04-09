import Foundation
import SwiftUI

func fontsInDirectory(directory: URL) -> [FontInfo] {
    var fontFiles = [FontInfo]()

    let fileManager = FileManager.default

    do {
        let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: .skipsHiddenFiles)

        for file in files {
            if file.pathExtension.lowercased() == "ttf" || file.pathExtension.lowercased() == "otf" {
                do {
                    if let fontInfo = getFontInfoFromFile(file: file) {
                        fontFiles.append(fontInfo)
                    }
                } catch {
                    print("Error getting font info: \(error)")
                }
            }
        }
    } catch {
        print("I am fonts in directory. Error reading font files from directory: \(error)")
    }

    print("Fonts in directory \(directory): \(fontFiles)")
    return fontFiles
}


func getFontInfoFromFile(file: URL) -> FontInfo? {
    let fontDescriptorsResult = CTFontManagerCreateFontDescriptorsFromURL(file as CFURL)
    if let fontDescriptors = fontDescriptorsResult as? [CTFontDescriptor], let descriptor = fontDescriptors.first, let fontName = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as? String {
        return FontInfo(path: file.path, fontFamily: fontName)
    } else {
        print("Error processing font file: \(file.path). Unable to create font descriptors.")
        if let error = fontDescriptorsResult {
            print("CoreText error: \(error)")
        }
        return nil
    }
}


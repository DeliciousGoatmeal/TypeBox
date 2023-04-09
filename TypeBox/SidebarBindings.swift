//
//  SidebarBindings.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI


struct SidebarBindings {
    var searchText: Binding<String>
    var fontSize: Binding<CGFloat>
    var customPreviewText: Binding<String>
    var fontDirectories: Binding<[URL]>
    var pressedBox: Binding<String?>
    var filterFonts: (String) -> [FontInfo]
    var copyToClipboard: (String) -> Void
    var showOpenPanel: (_ completion: @escaping (_ newFontInfo: [FontInfo]) -> Void) -> Void
    let updateFontDirectories: () -> Void
    let showCustomDirectoryOpenPanel: () -> Void
    let removeCustomDirectory: (String) -> Void
    var selectedStyleBinding: Binding<FontStyle>
    var systemDirectories: Binding<[URL]>
    var customDirectories: Binding<[URL]>
    var selectedFontFamily: Binding<String?>
    var fontLoader: FontLoader
    var selectedFontStyle: Binding<FontStyle>
    var fontInfoManager: FontInfoManager
    var onSearchTextChange: (String) -> Void
    var fontInfo: Binding<[FontInfo]> {
            Binding(get: { fontInfoManager.fontInfo }, set: { fontInfoManager.fontInfo = $0 })
        }
    
    
    // Computed properties for bindings
    var fontSizeBinding: Binding<CGFloat> {
        fontSize
    }
    
    var customPreviewTextBinding: Binding<String> {
        customPreviewText
    }
    
    var pressedBoxBinding: Binding<String?> {
        pressedBox
    }
}

//
//  SidebarBindings.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI


class SidebarBindings: ObservableObject {
    var searchText: Binding<String>
    var fontSize: Binding<CGFloat>
    var customPreviewText: Binding<String>
    var fontDirectories: Binding<[URL]>
    var pressedBox: Binding<String?>
    var filterFonts: (String) -> [FontInfo]
    var showOpenPanel: (_ completion: @escaping (_ newFontInfo: [FontInfo]) -> Void) -> Void
    let updateFontDirectories: () -> Void
    let showCustomDirectoryOpenPanel: () -> Void
    let removeCustomDirectory: (String) -> Void
    var selectedStyleBinding: Binding<FontStyle>
    var systemDirectories: [FontDirectory]
    var customDirectories: [FontDirectory]
    var selectedFontFamily: Binding<String?>
    var fontLoader: FontLoader
    var selectedFontStyle: Binding<FontStyle>
    var fontInfoManager: FontInfoManager
    var onSearchTextChange: (String) -> Void
    
    var fontInfo: Binding<[FontInfo]> {
        Binding(get: { [self] in fontInfoManager.fontInfo }, set: { self.fontInfoManager.fontInfo = $0 })
    }
    @Published var isDirectoryListActive: Bool = false
    
    var selectedFont: Binding<String>
    

    
    
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
    
    
    init(
        searchText: Binding<String>,
        fontSize: Binding<CGFloat>,
        customPreviewText: Binding<String>,
        fontDirectories: Binding<[URL]>,
        pressedBox: Binding<String?>,
        filterFonts: @escaping (String) -> [FontInfo],
        showOpenPanel: @escaping (_ completion: @escaping (_ newFontInfo: [FontInfo]) -> Void) -> Void,
        updateFontDirectories: @escaping () -> Void,
        showCustomDirectoryOpenPanel: @escaping () -> Void,
        removeCustomDirectory: @escaping (String) -> Void,
        selectedStyleBinding: Binding<FontStyle>,
        systemDirectories: [URL],
        customDirectories: [URL],
        selectedFontFamily: Binding<String?>,
        fontLoader: FontLoader,
        selectedFontStyle: Binding<FontStyle>,
        fontInfoManager: FontInfoManager,
        onSearchTextChange: @escaping (String) -> Void,
        selectedFont: Binding<String>
    ) {
        self.searchText = searchText
        self.fontSize = fontSize
        self.customPreviewText = customPreviewText
        self.fontDirectories = fontDirectories
        self.pressedBox = pressedBox
        self.filterFonts = filterFonts
        self.showOpenPanel = showOpenPanel
        self.updateFontDirectories = updateFontDirectories
        self.showCustomDirectoryOpenPanel = showCustomDirectoryOpenPanel
        self.removeCustomDirectory = removeCustomDirectory
        self.selectedStyleBinding = selectedStyleBinding
        self.systemDirectories = systemDirectories.map { FontDirectory(path: $0.path) }
        self.customDirectories = customDirectories.map { FontDirectory(path: $0.path) }
        self.selectedFontFamily = selectedFontFamily
        self.fontLoader = fontLoader
        self.selectedFontStyle = selectedFontStyle
        self.fontInfoManager = fontInfoManager
        self.onSearchTextChange = onSearchTextChange
        self.selectedFont = selectedFont
        
    }
}

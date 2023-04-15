//
//  directoriesList.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import SwiftUI
import Foundation

struct DirectoryList: View {
    @Binding var searchText: String
    var directories: [FontDirectory] = []
    @Binding var isDirectoryListActive: Bool
    @Binding var selectedFont: String
    @StateObject var customDirectoriesManager = CustomDirectoriesManager()
    @State private var currentSearchText: String = ""
    
    init(searchText: Binding<String>, directories: [FontDirectory], isDirectoryListActive: Binding<Bool>, selectedFont: Binding<String>) {
        _searchText = searchText
        self.directories = directories
        _isDirectoryListActive = isDirectoryListActive
        _selectedFont = selectedFont
    }
    
    
    
    
    var body: some View {
        
        ForEach(directories) { directory in
            DisclosureGroup(directory.name) {
                DirectoryView(
                    // Pass currentSearchText instead of searchText
                    directory: directory,
                    isDirectoryListActive: $isDirectoryListActive,
                    selectedFont: $selectedFont)
            }
        }
        .onChange(of: searchText) { newValue in
            if !newValue.isEmpty {
                currentSearchText = newValue
            }
        }
        }
    
    

    
    func addDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.begin { response in
            if response == .OK {
                for url in openPanel.urls {
                    customDirectoriesManager.addDirectory(url)
                }
            }
        }
    }
}




struct DirectoryView: View {
    
//    @Binding var searchText: String
    let directory: FontDirectory
    @Binding var isDirectoryListActive: Bool
    @Binding var selectedFont: String
    
    
    
    // Show fonts in ABC order
//    private var uniqueFilteredFonts: [FontInfo] {
//        let filteredFonts = directory.fonts().filter {
//            searchText.isEmpty || $0.fontFamily.localizedCaseInsensitiveContains(searchText)
//        }
//        let uniqueFonts = fontInfoManager.uniqueAndSortedFontInfos(filteredFonts) // Use fontInfoManager instance
//        return uniqueFonts
//    }
    
    var body: some View {
        //@ObservedObject var fontInfoManager: FontInfoManager
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(directory.fonts(), id: \.id) { font in
                    Text(font.fontFamily)
                        .padding(.leading)
                        .onTapGesture {
                            selectedFont = font.fontFamily
                            //searchText = font.fontFamily
                            print("Clicked on font: \(selectedFont)")
                        }
                        .onAppear {
                            if font.fontFamily == selectedFont {
                                //searchText = selectedFont
                            }
                        }
                }
            }
        }
    }
}




struct FontDirectory: Identifiable, Equatable {
    let id = UUID()
    let path: String
    let url: URL
    let isCustom: Bool
    let name: String
    
    
    init(path: String, isCustom: Bool = false) {
        self.path = path
        self.url = URL(fileURLWithPath: path)
        self.isCustom = isCustom
        self.name = url.deletingPathExtension().lastPathComponent
        
    }
    func font() -> [FontInfo] {
        return fontsInDirectory(directory: url)
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
        
        return Array(Set(defaultDirectories + customDirectories)).sorted { $0.path < $1.path } // Remove duplicates and sort
    }
    
    private var customDirectories: [URL] {
        if let customDirectoryPaths = UserDefaults.standard.stringArray(forKey: "customDirectories") {
            return customDirectoryPaths.map { URL(fileURLWithPath: $0) }
        }
        return []
    }
}

struct CustomDirectory: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}


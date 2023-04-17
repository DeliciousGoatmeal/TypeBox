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
            DirectoryView(
                directory: directory,
                isDirectoryListActive: $isDirectoryListActive,
                selectedFont: $selectedFont,
                isExpanded: true
            )
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
    let directory: FontDirectory
    @Binding var isDirectoryListActive: Bool
    @Binding var selectedFont: String
    @State private var isExpanded: Bool
    
    init(directory: FontDirectory, isDirectoryListActive: Binding<Bool>, selectedFont: Binding<String>, isExpanded: Bool = false) {
        self.directory = directory
        _isDirectoryListActive = isDirectoryListActive
        _selectedFont = selectedFont
        _isExpanded = State(initialValue: isExpanded)
    }
    
    var body: some View {
        DisclosureGroup(directory.path, isExpanded: $isExpanded) {
              ScrollView {
                  VStack(alignment: .leading, spacing: 8) {
                      ForEach(uniqueFontFamilies(directory.fonts()).sorted(by: { $0.fontFamily < $1.fontFamily }), id: \.id) { font in
                          Text(font.fontFamily)
                              .padding(.leading)
                              .onTapGesture {
                                  selectedFont = font.fontFamily
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
    
    func uniqueFontFamilies(_ fonts: [FontInfo]) -> [FontInfo] {
        var uniqueFontFamilies = [FontInfo]()
        var fontFamilyNames = Set<String>()
        
        for font in fonts {
            if !fontFamilyNames.contains(font.fontFamily) {
                uniqueFontFamilies.append(font)
                fontFamilyNames.insert(font.fontFamily)
            }
        }
        
        return uniqueFontFamilies
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


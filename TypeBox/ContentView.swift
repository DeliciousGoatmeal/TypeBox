//
//  ContentView.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import SwiftUI
import CoreText
import AppKit
import Combine
import UserNotifications

@main
struct FontListerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(isSidebarVisible: State(wrappedValue: true), isDirectoryListActive: .constant(false), sidebarView: { _ in }, onSearchTextChange: {_ in })
        }
        .commands {
            SidebarCommands()
            CommandMenu("Custom") {
                ClearDefaultsMenuItem()
            }
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}


class TitleTextField: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct ContentView:
    View {
    @State private var fontInfo: [FontInfo] = []
    @State private var fontSize: CGFloat = 20
    @State private var fontDirectory: URL?
    @State private var fontFiles: [String] = []
    @State private var pressedBox: String? = nil
    @State private var isSidebarVisible: Bool = true {
        didSet {
            print("isSidebarVisible changed to \(isSidebarVisible)")
        }
    }
    @State private var searchText = ""
    @State private var sliderValue = 50.0
    @State private var customPreviewText: String = ""
    @State private var fontDirectories: [URL] = []
    @State private var directories: [String] = []
    @State private var selectedStyles: FontStyle = .regular
    @State private var fontInfoManager = FontInfoManager()
    @State private var customDirectoriesManager = CustomDirectoriesManager()
    @State private var systemDirectories: [URL] = []
    @State private var customDirectories: [URL] = []
    @State private var selectedFontFamily: String? = ""
    @ObservedObject var fontLoader: FontLoader
    @State private var fontsLoaded: Bool = false
    @Binding var isDirectoryListActive: Bool
    @State private var selectedFont: String = ""
    @State private var nonOptionalSelectedFontFamily: String = ""
    
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    @State private var sidebarWidth: CGFloat = 500
    
    
    let sidebarView: (String) -> Void
    let onSearchTextChange: (String) -> Void
    
    
    
    
    init(isSidebarVisible: State<Bool>, isDirectoryListActive: Binding<Bool>, sidebarView: @escaping (String) -> Void, onSearchTextChange: @escaping (String) -> Void) {
        _isSidebarVisible = isSidebarVisible
        _isDirectoryListActive = isDirectoryListActive
        self.sidebarView = sidebarView
        self.onSearchTextChange = onSearchTextChange
        self.fontLoader = FontLoader()
        //self.updateFontDirectories()
        
    }
    
    
    
    private func updateFontDirectories() {
        print("updateFontDirectories Called")
        let defaultDirectories = [
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .localDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask).first!.appendingPathComponent("Fonts"),
            //FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("Adobe/CoreSync/plugins/livetype/.r")
        ]
        
        let customDirectories: [URL] = {
            if let customDirectoryPaths = UserDefaults.standard.stringArray(forKey: "customDirectories") {
                return customDirectoryPaths.map { URL(fileURLWithPath: $0) }
            }
            return []
        }()
        
        systemDirectories = defaultDirectories
        fontDirectories = (defaultDirectories + customDirectories).sorted(by: { $0.path < $1.path })
        
        fontLoader.loadFontsFromDirectories(fontDirectories)
    }
    
    private func showCustomDirectoryOpenPanel() {
        print("Load NSOpenPanel")
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Choose a custom font directory"
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                let directoryPath = url.path
                
                // Save custom directory to UserDefaults
                if var customDirectories = UserDefaults.standard.stringArray(forKey: "customDirectories") {
                    customDirectories.append(directoryPath)
                    UserDefaults.standard.set(customDirectories, forKey: "customDirectories")
                } else {
                    UserDefaults.standard.set([directoryPath], forKey: "customDirectories")
                }
                
                // Update fontDirectories
                updateFontDirectories()
                print("Update Font Directories")
            }
        }
    }
    
    private func getDirectories() -> [String] {
        let fontDirectories = [
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .localDomainMask).first!.appendingPathComponent("Fonts"),
            FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask).first!.appendingPathComponent("Fonts"),
            //FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("Adobe/CoreSync/plugins/livetype/.r")
        ]
        let customDirectories = UserDefaults.standard.stringArray(forKey: "customDirectories") ?? []
        return fontDirectories.map { $0.path } + customDirectories
    }
    
    private func removeCustomDirectory(directory: String) {
        if var customDirectories = UserDefaults.standard.stringArray(forKey: "customDirectories") {
            if let index = customDirectories.firstIndex(of: directory) {
                customDirectories.remove(at: index)
                UserDefaults.standard.set(customDirectories, forKey: "customDirectories")
                
                // Update fontDirectories
                updateFontDirectories()
            }
        }
    }
    
    private func showOpenPanel(completion: @escaping ([FontInfo]) -> Void) {
        print("showOpenPanel called")
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.directoryURL = UserDefaults.standard.url(forKey: "lastOpenedDirectory")
        
        let window = NSApplication.shared.windows.first
        openPanel.beginSheetModal(for: window!) { (result) in
            if result == .OK, let url = openPanel.url {
                guard openPanel.url != nil else { return }
                print("Selected folder URL: \(url)") // Add this print statement
                UserDefaults.standard.set(url, forKey: "lastOpenedDirectory")
                DispatchQueue.global(qos: .userInitiated).async {
                    let newFontInfo = fontsInDirectory(directory: url).map { FontInfo(path: $0.path, fontFamily: $0.fontFamily) }
                    print("New font info: \(newFontInfo)") // Add this print statement
                    DispatchQueue.main.async {
                        completion(newFontInfo)
                        updateFontDirectories() // Call updateFontDirectories() after getting the new font info
                    }
                }
            }
        }
    }
    
    
    
    private func filteredFontTuples(_ searchText: String) -> [(path: String, fontFamily: String)] {
        let filteredFonts = fontInfo.filter { font in
            let fontFamily = font.fontFamily
            if !searchText.isEmpty && !fontFamily.localizedCaseInsensitiveContains(searchText) {
                print("Filtering out font \(fontFamily) because it doesn't match search text: \(searchText)")
                return false
            }
            return true
        }
        
        return filteredFonts.sorted(by: { $0.fontFamily < $1.fontFamily }).map {
            (path: $0.path, fontFamily: $0.fontFamily)
        }
    }
    
    private func filteredFontInfo(_ searchText: String) -> [FontInfo] {
        return fontInfo.filter { font in
            let fontFamily = font.fontFamily
            if !searchText.isEmpty && !fontFamily.localizedCaseInsensitiveContains(searchText) {
                print("Filtering out font \(fontFamily) because it doesn't match search text: \(searchText)")
                return false
            }
            return true
        }
    }
    
    func getUniqueDirectories(fontInfo: [(path: String, fontFamily: String)]) -> [String] {
        let directories = fontInfo.map { $0.path }.map { URL(fileURLWithPath: $0).deletingLastPathComponent().path }
        return Array(Set(directories)).sorted()
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(isSidebarVisible: State(wrappedValue: true), isDirectoryListActive: .constant(false), sidebarView: { _ in }, onSearchTextChange: { _ in })
        }
    }
    
    
    
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                SidebarView(
                    bindings: SidebarBindings(
                        searchText: $searchText,
                        fontSize: $fontSize,
                        customPreviewText: $customPreviewText,
                        fontDirectories: $fontDirectories,
                        pressedBox: $pressedBox,
                        filterFonts: filteredFontInfo,
                        showOpenPanel: showOpenPanel,
                        updateFontDirectories: updateFontDirectories,
                        showCustomDirectoryOpenPanel: showCustomDirectoryOpenPanel,
                        removeCustomDirectory: removeCustomDirectory,
                        selectedStyleBinding: $selectedStyles,
                        systemDirectories: systemDirectories,
                        customDirectories: customDirectories,
                        selectedFontFamily: $selectedFontFamily,
                        fontLoader: fontLoader,
                        selectedFontStyle: $selectedStyles,
                        fontInfoManager: FontInfoManager(),
                        onSearchTextChange: { searchText in
                            self.searchText = searchText
                        }, selectedFont: Binding<String>(
                            get: { selectedFontFamily ?? "" },
                            set: { nonOptionalSelectedFontFamily = $0 }
                        )
                    ),
                    isSidebarVisible: $isSidebarVisible,
                    fontLoader: fontLoader,
                    customPreviewText: $customPreviewText,
                    isDirectoryListActive: $isDirectoryListActive,
                    selectedFont: $selectedFont,
                    sidebarWidth: $sidebarWidth
                )
            }
            
            
            
            
            .toolbar {
                ToolbarItem {
                    TitleView(title: "TypeBox", fontSize: 20)
                        .padding()
                }
                
                ToolbarItem {
                    
                    
                }
                
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        isSidebarVisible.toggle()
                    }) {
                        Image(systemName: "sidebar.leading")
                    }
                }
                
            }
            
            
            VStack {
                
                VStack {
                    
                    HStack {
                        Spacer()
                        Slider(value: $fontSize, in: 10...50)
                            .frame(width: 150)
                            .padding(.trailing, 12)
                        
                        Text(" \(Int(fontSize)) px")
                            .multilineTextAlignment(.trailing)
                            .minimumScaleFactor(0.5)
                            .padding(.trailing, 32.0)
                    }
                    
                    .toolbar  {
                        ToolbarItem(placement: .principal)  {
                            TextField("Custom Preview Text", text: $customPreviewText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                                .padding()
                        }
                        
                        
                        
                        
                        
                        ToolbarItemGroup {
                            Spacer()
                            SearchBar(searchText: $searchText, selectedFont: $selectedFont, onSearchTextChange: { searchText in
                                print("Search text changed: \(searchText)")
                                onSearchTextChange(searchText)
                            })
                            .onChange(of: selectedFont) { newValue in
                                searchText = newValue
                            }
                            Button(action: {
                                showOpenPanel() { newFontInfo in
                                    fontInfoManager.fontInfo = newFontInfo.map { FontInfo(path: $0.path, fontFamily: $0.fontFamily) }
                                }
                            }) {
                                Image(systemName: "folder").help("Select Folder")
                            }
                            
                        }
                    }
                }
                
                
                
                GeometryReader { geometry in
                    
                    let uniqueFilteredFonts: [FontInfo] = {
                        let filteredFonts = fontLoader.fontInfo.filter {
                            searchText.isEmpty || $0.fontFamily.localizedCaseInsensitiveContains(searchText)
                        }
                        let uniqueFonts = fontInfoManager.uniqueAndSortedFontInfos(filteredFonts)
                        return uniqueFonts
                    }()
                    
                    
                    let minColumnWidth: CGFloat = 300
                    let columnSpacing: CGFloat = 20
                    let numberOfColumns = max(1, Int((geometry.size.width - columnSpacing) / (minColumnWidth + columnSpacing)))
                    
                    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: numberOfColumns)
                    
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(uniqueFilteredFonts, id: \.self) { fontInfo in
                                FontBox(path: fontInfo.path, fontFamily: fontInfo.fontFamily, fontSize: $fontSize, onPress: {}, pressedBox: $pressedBox, customPreviewText: customPreviewText, selectedFontStyle: $selectedStyles, systemDirectories: $systemDirectories, customDirectories: $customDirectories)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                }
                
                .onChange(of: fontInfo) { newFontInfo in
                    fontInfoManager.fontInfo = newFontInfo
                    print("fontInfoManager.fontInfo updated: \(fontInfoManager.fontInfo)")
                }
            }
        }
    }
    
}


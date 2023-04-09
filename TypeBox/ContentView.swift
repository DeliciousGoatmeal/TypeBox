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
            ContentView(isSidebarVisible: State(wrappedValue: true), sidebarView: { _ in })
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


struct ContentView: View {
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
    
    
    
    
    let sidebarView: (String) -> Void
    
    init(isSidebarVisible: State<Bool>, sidebarView: @escaping (String) -> Void) {
        _isSidebarVisible = isSidebarVisible
        self.sidebarView = sidebarView
        self.fontLoader = FontLoader()
        self.updateFontDirectories()
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
    
    private func filterFonts(_ searchText: String) -> [(path: String, fontFamily: String)] {
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
    
    private func copyToClipboard(_path: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(_path, forType: .string)
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
    
    
    var body: some View {
        VStack {
            SidebarView(
                bindings: SidebarBindings(
                    searchText: .constant(""),
                    fontSize: $fontSize,
                    customPreviewText: $customPreviewText,
                    fontDirectories: $fontDirectories,
                    pressedBox: $pressedBox,
                    filterFonts: filteredFontInfo,
                    copyToClipboard: copyToClipboard,
                    showOpenPanel: showOpenPanel,
                    updateFontDirectories: updateFontDirectories,
                    showCustomDirectoryOpenPanel: showCustomDirectoryOpenPanel,
                    removeCustomDirectory: removeCustomDirectory,
                    selectedStyleBinding: $selectedStyles,
                    systemDirectories: $systemDirectories,
                    customDirectories: $customDirectories,
                    selectedFontFamily: $selectedFontFamily,
                    fontLoader: fontLoader,
                    selectedFontStyle: $selectedStyles,
                    fontInfoManager: FontInfoManager(),
                    onSearchTextChange: { searchText in
                        self.searchText = searchText
                    }
                ),
                isSidebarVisible: $isSidebarVisible,
                fontLoader: fontLoader,
                customPreviewText: $customPreviewText
            )
            
            // Add FontBox here
            Text("Filtered fonts: \(fontInfoManager.fontInfo.filter { $0.fontFamily.localizedCaseInsensitiveContains(searchText) }.count)")

            
            let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
            LazyVGrid(columns: columns, spacing: 20){
                Text("I am  not a scroll view lol")
                ForEach(fontLoader.fontInfo.filter { $0.fontFamily.localizedCaseInsensitiveContains($searchText.wrappedValue) }, id: \.self) { fontInfo in
                    FontBox(path: fontInfo.path, fontFamily: fontInfo.fontFamily, fontSize: $fontSize, onPress: {}, pressedBox: $pressedBox, customPreviewText: $customPreviewText.wrappedValue, selectedFontStyle: $selectedStyles, systemDirectories: $systemDirectories, customDirectories: $customDirectories)
                    
                        .onAppear {
                            // Add a print statement here
                            print("Inside ForEach loop for font family: \(fontInfo.fontFamily)")
                        }
                }
            }

        }
        .onChange(of: fontInfo) { newFontInfo in
            fontInfoManager.fontInfo = newFontInfo
            print("fontInfoManager.fontInfo updated: \(fontInfoManager.fontInfo)")
        }
    }

    
    
    
    
    struct TitleView: NSViewRepresentable {
        let title: String
        let fontSize: CGFloat
        
        init(title: String, fontSize: CGFloat) {
            self.title = title
            self.fontSize = fontSize
        }
        
        func makeNSView(context: Context) -> TitleTextField {
            makeTitleTextField(title: title, fontSize: fontSize)
        }
        
        func updateNSView(_ nsView: TitleTextField, context: Context) {
            nsView.stringValue = title
            nsView.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
            nsView.sizeToFit()
        }
        
        private func makeTitleTextField(title: String, fontSize: CGFloat) -> TitleTextField {
            let textField = TitleTextField()
            textField.stringValue = title
            textField.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
            textField.sizeToFit()
            return textField
        }
    }
    
    private func getUniqueDirectories(fontInfo: [(path: String, fontFamily: String)]) -> [String] {
        let directories = fontInfo.map { $0.path }.map { URL(fileURLWithPath: $0).deletingLastPathComponent().path }
        return Array(Set(directories)).sorted()
    }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isSidebarVisible: State(wrappedValue: true), sidebarView: { _ in })
    }
}

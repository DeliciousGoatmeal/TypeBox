//
//  SidebarView.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI
import CoreText
import AppKit
import Combine
import UserNotifications



//MARK: - SidebarBindings struct to hold various bindings and functions
struct SidebarView: View {
    var bindings: SidebarBindings
    @Binding var isSidebarVisible: Bool
    @Binding var isDirectoryListActive: Bool
    @Binding private var selectedFont: String
    let fontLoader: FontLoader
    var customPreviewText: Binding<String>
    @State private var fontInfos: [FontInfo] = []
    @Binding var fontInfosBinding: [FontInfo]
    @State private var isDirectoriesExpanded: Bool = true
    @StateObject private var customDirectoriesManager = CustomDirectoriesManager()
    @State private var fontSize: CGFloat = 20
    @Binding var sidebarWidth: CGFloat
    
    
    
    init(bindings: SidebarBindings, isSidebarVisible: Binding<Bool>, fontLoader: FontLoader, customPreviewText: Binding<String>, isDirectoryListActive: Binding<Bool>, selectedFont: Binding<String>, sidebarWidth: Binding<CGFloat>) {
        self.bindings = bindings
        _isSidebarVisible = isSidebarVisible
        self.fontLoader = fontLoader
        self.customPreviewText = customPreviewText
        _fontInfosBinding = bindings.fontInfo
        _isDirectoryListActive = isDirectoryListActive
        _selectedFont = selectedFont
        _sidebarWidth = sidebarWidth
        
        bindings.fontInfoManager.loadFonts(fontDirectories: bindings.fontDirectories.wrappedValue)
    }
    
    func filteredFontInfo(_ searchText: String) -> [FontInfo] {
        return bindings.filterFonts(searchText)
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // Font Style section
            ForEach(FontStyle.allCases, id: \.self) { style in
                Button(action: {
                    bindings.selectedStyleBinding.wrappedValue = style
                }) {
                    HStack {
                        Text(style.rawValue)
                        Spacer()
                        if bindings.selectedStyleBinding.wrappedValue == style {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                    .padding(.horizontal)
                    
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 0.5)
            }
            
            Button(action: {
                customDirectoriesManager.showDirectoryPicker()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill").help("Add Custom Folder")
                    Text("Add Custom Folder")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .padding(.horizontal)
                
            }
            .buttonStyle(.borderless)
            .padding(.top, 0.5)
            
            Text("Directories")
                .font(.headline)
                .padding(.top, 8)
                .padding(.left, 16)
           
                
                
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DirectoryList(
                        searchText: bindings.searchText,
                        directories: bindings.systemDirectories.map { FontDirectory(path: $0.path) },
                        isDirectoryListActive: $isDirectoryListActive,
                        selectedFont: $selectedFont
                    )
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
                    .padding(.horizontal)
                    
                    DirectoryList(
                        searchText: bindings.searchText,
                        directories: bindings.customDirectories.map { FontDirectory(path: $0.path) },
                        isDirectoryListActive: $isDirectoryListActive,
                        selectedFont: $selectedFont
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
                    .padding(.horizontal)
                }
            }
        }
    }
}

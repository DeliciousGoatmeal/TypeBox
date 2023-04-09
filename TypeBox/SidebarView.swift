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



// SidebarBindings struct to hold various bindings and functions


struct SidebarView: View {
    var bindings: SidebarBindings
    @Binding var isSidebarVisible: Bool
    
    @State private var selectedFontFamily: String = ""
    let fontLoader: FontLoader
    
    var customPreviewText: Binding<String>
    @State private var fontInfos: [FontInfo] = []
    @Binding var fontInfosBinding: [FontInfo]
   
    
    init(bindings: SidebarBindings, isSidebarVisible: Binding<Bool>, fontLoader: FontLoader, customPreviewText: Binding<String>) {
        self.bindings = bindings
        _isSidebarVisible = isSidebarVisible
        self.fontLoader = fontLoader
        self.customPreviewText = customPreviewText
        _fontInfosBinding = bindings.fontInfo
        
        
        
        
        bindings.fontInfoManager.loadFonts(fontDirectories: bindings.fontDirectories.wrappedValue)
        
        
    }
    
    
    
    // MARK: - Main body of the SidebarView
    
    var body: some View {
        HStack {
            List {
                // Font Style section
                Section(header: Text("Font Style")) {
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
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } //End Font Style Section
                
                //Font Directories Section
                Section(header: Text("Font Directories")) {
                    Button(action: {
                        bindings.showOpenPanel() { newFontInfo in
                            bindings.fontInfoManager.fontInfo = newFontInfo.map { FontInfo(path: $0.path, fontFamily: $0.fontFamily) }
                        }
                    }) {
                        Image(systemName: "folder").help("Select Folder")
                    }
                    DirectoryList(
                        setSearchText: { searchText in
                            bindings.searchText.wrappedValue = searchText
                        },
                        systemDirectories: bindings.systemDirectories,
                        customDirectories: bindings.customDirectories,
                        selectedFontFamily: bindings.selectedFontFamily
                        
                    )
                }// End Font Directories Section
            }
            .listStyle(SidebarListStyle()) // Use this to style the List as a sidebar
            .frame(minWidth: 200) // Adjust this value to change the width of the sidebar
        }
        //---------
        
        VStack {
            HStack {
                //Slider Font Resizer
                Slider(value: bindings.fontSizeBinding, in: 10...50)
                    .frame(width: 200)
                    .padding(.left, 16)
                
                Text("Font size: \(Int(bindings.fontSizeBinding.wrappedValue))")
                    .minimumScaleFactor(0.5)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                //End Slider Font Resizer
                
                Spacer()
                
                //Custom Preview Text Field
                TextField("Custom Preview Text", text: bindings.customPreviewTextBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .frame(width: 200)
            } //End Custom Preview Text Field
            
        }
    }
}
    

//
//  directoriesList.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import SwiftUI
import Foundation

struct DirectoryView: View {
    let setSearchText: (String) -> Void
    let directory: URL
    let isCustom: Bool
    let customDirectories: Binding<[URL]>
    @Binding var selectedFontFamily: String?
    let systemDirectories: Binding<[URL]>

    @State private var isExpanded: Bool = false

    init(directory: URL, isCustom: Bool, customDirectories: Binding<[URL]>, selectedFontFamily: Binding<String?>, setSearchText: @escaping (String) -> Void, systemDirectories: Binding<[URL]>) {
        self.directory = directory
        self.isCustom = isCustom
        self.customDirectories = customDirectories
        _selectedFontFamily = selectedFontFamily
        self.setSearchText = setSearchText
        self.systemDirectories = systemDirectories
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            ForEach(fontsInDirectory(directory: directory), id: \.id) { font in
                Text(font.fontFamily)
                    .padding(.leading)
                    .onTapGesture {
                        selectedFontFamily = font.fontFamily
                        setSearchText(font.fontFamily)
                    }
            }
        }, label: {
            Text(isCustom ? "Custom Directory: \(directory.path)" : "System Directory: \(directory.path)")
        })
    }
}


struct DirectoryList: View {
    let setSearchText: (String) -> Void
    let systemDirectories: Binding<[URL]>
    let customDirectories: Binding<[URL]>
    @Binding var selectedFontFamily: String?
    @State private var searchText: String = ""

    @State private var isExpanded: Bool = false

    var body: some View {
        print("Search text inside DirectoryList: \(searchText)")
        print("DirectoryList called") // Add this debug print statement
        return VStack(alignment: .leading, spacing: 0) {
            Text("Search text inside DirectoryList: \(searchText)")
            // Display system directories
            ForEach(systemDirectories.wrappedValue, id: \.self) { directory in
                DirectoryView(
                    directory: directory,
                    isCustom: false,
                    customDirectories: customDirectories,
                    selectedFontFamily: $selectedFontFamily,
                    setSearchText: setSearchText,
                    systemDirectories: systemDirectories
                )
            }

            // Display custom directories
            ForEach(customDirectories.wrappedValue, id: \.self) { url in
                DirectoryView(
                    directory: url,
                    isCustom: true,
                    customDirectories: customDirectories,
                    selectedFontFamily: $selectedFontFamily,
                    setSearchText: setSearchText,
                    systemDirectories: systemDirectories
                )
            }
        }
    }
}








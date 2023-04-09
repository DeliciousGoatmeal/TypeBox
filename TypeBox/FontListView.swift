//
//  FontListView.swift
//  TypeBox
//
//  Created by Goat on 4/8/23.
//

import SwiftUI

struct FontListView: View {
    @Binding var fontInfos: [FontInfo]
    @Binding var searchText: String
    @Binding var fontSize: CGFloat
    @Binding var pressedBox: String?
    @Binding var customPreviewText: String
    @Binding var selectedFontStyle: FontStyle
    @Binding var systemDirectories: [URL]
    @Binding var customDirectories: [URL]

    var body: some View {
        LazyVStack {
            ForEach(fontInfos.filter { $0.fontFamily.localizedCaseInsensitiveContains(searchText) }, id: \.self) { fontInfo in
                FontBox(path: fontInfo.path, fontFamily: fontInfo.fontFamily, fontSize: $fontSize, onPress: {}, pressedBox: $pressedBox, customPreviewText: customPreviewText, selectedFontStyle: $selectedFontStyle, systemDirectories: $systemDirectories, customDirectories: $customDirectories)
            }
        }
    }
}


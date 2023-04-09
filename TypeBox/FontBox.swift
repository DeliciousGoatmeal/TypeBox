//
//  FontBox.swift
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


struct FontBox: View {
    let path: String
    let fontFamily: String
    @Binding var fontSize: CGFloat
    let onPress: () -> Void
    @Binding var pressedBox: String?
    let customPreviewText: String
    @Binding var selectedFontStyle: FontStyle {
        didSet {
            print("Selected font style: \(selectedFontStyle.rawValue), uiFontSymbolicTrait: \(selectedFontStyle.uiFontSymbolicTrait.rawValue)")
        }
    }
    
    // Add the missing variables with appropriate types
    @Binding var systemDirectories: [URL]
    @Binding var customDirectories: [URL]

    
    var body: some View {
        VStack {
            Text("Im I getting iterated?")
            Text(!customPreviewText.isEmpty ? customPreviewText : fontFamily)
                .font(.custom(fontFamily, size: fontSize))
                .fontWeight(selectedFontStyle.uiFontSymbolicTrait.contains(.traitBold) ? .bold : .regular)
                .italic(selectedFontStyle.uiFontSymbolicTrait.contains(.traitItalic))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.all, 14.0)
            Text(path)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.all, 14.0)
        }
        .frame(maxWidth: .infinity)
         .padding(.all, 6.0)
         .background(pressedBox == path ? Color(.lightGray) : Color(.clear))
         .onTapGesture {
             // Your onTapGesture code here...
         }
         .onChange(of: selectedFontStyle) { _ in
             print("Selected font style updated to: \(selectedFontStyle.rawValue), uiFontSymbolicTrait: \(selectedFontStyle.uiFontSymbolicTrait.rawValue)")
             print("Inside onChange of FontBox for font family: \(fontFamily)")
         }
         .onAppear {
             print("onAppear Font family: \(fontFamily), onAppear Font path: \(path)")
             print("Inside onAppear of FontBox for font family: \(fontFamily)")
             print("Custom preview text: \(customPreviewText)")
             print("Selected font style raw value: \(selectedFontStyle.rawValue)")
             print("Inside second onAppear of FontBox for font family: \(fontFamily)")
             print("FontBox onAppear for font family: \(fontFamily)")
         }
     }

 }




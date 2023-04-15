//
//  TitleView.swift
//  TypeBox
//
//  Created by Goat on 4/12/23.
//

import Foundation
import SwiftUI

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

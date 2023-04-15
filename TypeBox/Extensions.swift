//
//  Extensions.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI
import CoreText
import AppKit
import Combine

enum NoFlipEdge {
    case left, right
}

struct NoFlipPadding: ViewModifier {
    let edge: NoFlipEdge
    let length: CGFloat?
    @Environment(\.layoutDirection) var layoutDirection
    
    private var computedEdge: Edge.Set {
        if layoutDirection == .rightToLeft {
            return edge == .left ? .trailing : .leading
        } else {
            return edge == .left ? .leading : .trailing
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(computedEdge, length)
    }
}

extension View {
    func padding(_ edge: NoFlipEdge, _ length: CGFloat? = nil) -> some View {
        self.modifier(NoFlipPadding(edge: edge, length: length))
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen: Set<Element> = []
        return self.filter { item in
            if seen.insert(item).inserted {
                return true
            } else {
                return false
            }
        }
    }
}

extension Binding where Value == [FontStyle] {
    func binding(at index: Int) -> Binding<FontStyle> {
        return Binding<FontStyle>(
            get: { self.wrappedValue[index] },
            set: { self.wrappedValue[index] = $0 }
        )
    }
}

extension FontListerApp {
    func makeTitleTextField(title: String, fontSize: CGFloat) -> TitleTextField {
        let textField = TitleTextField()
        textField.stringValue = title
        textField.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        textField.sizeToFit()
        return textField
    }
}

extension FontDirectory {
    func fonts() -> [FontInfo] {
        return fontsInDirectory(directory: self.url)
    }
}

extension Array where Element == URL {
    func toFontDirectories() -> [FontDirectory] {
        return self.map { FontDirectory(path: $0.path) }
    }
}

//
//  configElements.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI

struct SearchBar: NSViewRepresentable {
    @Binding var text: String {
        didSet {
            print("SearchBar text didSet: \(text)")
        }
    }
    var onTextChange: (String) -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(self)

    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        searchField.delegate = context.coordinator
        searchField.placeholderString = "Search" // Add a placeholder string
        searchField.translatesAutoresizingMaskIntoConstraints = false
        print("Search field initialized")
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
        print("Search text updated: \(text)")
        NSLayoutConstraint.activate([
            nsView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200) // Add a minimum width constraint
        ])
    }
    
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let control: SearchBar
        
        init(_ control: SearchBar) {
            self.control = control
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let searchField = obj.object as? NSSearchField {
                control.onTextChange(searchField.stringValue)
                print("controlTextDidChange called: \(searchField.stringValue)")
            }
        }
    }
}

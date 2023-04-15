//
//  configElements.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import SwiftUI
import Combine

struct SearchBar: NSViewRepresentable {
    @Binding var searchText: String
    @Binding var selectedFont: String
    
    @State private var previousSelectedFont: String = ""
    
    var onSearchTextChange: (String) -> Void
    
    init(searchText: Binding<String>, selectedFont: Binding<String>, onSearchTextChange: @escaping (String) -> Void) {
        _searchText = searchText
        _selectedFont = selectedFont
        self.onSearchTextChange = onSearchTextChange
    }
    

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        searchField.delegate = context.coordinator
        searchField.placeholderString = "Search"
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        DispatchQueue.main.async {
            if !self.searchText.isEmpty && self.previousSelectedFont != self.selectedFont {
                nsView.stringValue = self.selectedFont
                self.previousSelectedFont = self.selectedFont
            }
        }
        
        NSLayoutConstraint.activate([
            nsView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let searchBar: SearchBar
        
        init(_ searchBar: SearchBar) {
            self.searchBar = searchBar
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let searchField = obj.object as? NSSearchField {
                searchBar.searchText = searchField.stringValue
                
                // Call onSearchTextChange only when the search text is non-empty
                if !searchField.stringValue.isEmpty {
                    searchBar.onSearchTextChange(searchField.stringValue)
                }
            }
        }
                
//                // Call this function when the search bar is cleared
//                if searchField.stringValue.isEmpty {
//                    searchBarCleared()
//                }
//            }
//        }
        
        // Function to reset the view when the search bar is cleared
        func searchBarCleared() {
            searchBar.selectedFont = ""
        }
    }
}









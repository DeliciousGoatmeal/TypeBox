import SwiftUI

struct ClearDefaultsMenuItem: View {
    var body: some View {
        Button("Clear UserDefaults") {
            clearUserDefaults()
        }
    }
    
    func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

struct ClearDefaultsMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        ClearDefaultsMenuItem()
    }
}

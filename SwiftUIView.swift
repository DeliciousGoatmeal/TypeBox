import SwiftUI

struct NewContentView: View {
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                VStack {
                    
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.2, height: geometry.size.height)
                .background(Color.green)

                VStack {
                    HStack {
                        VStack {
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.2)
                        .background(Color.red)

                        Spacer()
                    }

                    HStack {
                        VStack {
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                        .background(Color.blue)

                        Spacer()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewContentView()
            .frame(width: 800, height: 600)
    }
}

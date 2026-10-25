import SwiftUI
import Playgrounds

struct ContentView: View {
    
    var body: some View {
        ZStack{
            Color.black
            Text("Press Cmd(⌘)+Opt(⌥)+Shift(⇧)+Q to exit")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
        }
        .onAppear {
            SystemInputLock.shared.enable()
        }
        .onDisappear {
            SystemInputLock.shared.disable()
        }
    }
}


#Preview {
    ContentView()
}

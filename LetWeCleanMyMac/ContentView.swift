import SwiftUI
import Playgrounds

struct ContentView: View {
    
    var body: some View {
        let systemInputLock = SystemInputLock()
        let basicText = "Press Cmd(⌘)+Opt(⌥)+Shift(⇧)+Q to exit"
        let noPermission = "Grant Accessibility + Input Monitoring, then relaunch the app"
        ZStack{
            Color.black
            Text(systemInputLock.hasPermissions ? basicText : noPermission)
                .font(.title)
                .padding()
                .foregroundColor(.white)
        }
        .onAppear {
            systemInputLock.enable()
        }
        .onDisappear {
            systemInputLock.disable()
        }
    }
}


#Preview {
    ContentView()
}

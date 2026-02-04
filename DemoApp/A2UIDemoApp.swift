import SwiftUI
import A2UIRuntime

@main
struct A2UIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(engine: A2UIRuntime.defaultEngine())
        }
    }
}

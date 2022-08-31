import ArgumentParser
import Dispatch
import Foundation
import RoboClient

@main
struct RoboClientDemo: ParsableCommand {
    @Argument(help: "The URL of the Robo server")
    var url: URL

    func runAsync() async throws {
        let client = try await RoboClient.connect(to: url)
        try await client.send(action: .keySequence(text: "Hello world!"))
    }

    func run() {
        let task = Task {
            try await withTaskCancellationHandler {
                try await runAsync()
            } onCancel: {
                print("Cancelled")
            }
        }

        // Register interrupt (ctrl-c) handler
        let source = DispatchSource.makeSignalSource(signal: SIGINT)
        source.setEventHandler {
            task.cancel()
            Self.exit()
        }
        source.resume()

        dispatchMain()
    }
}

import ArgumentParser
import Dispatch
import Foundation
import Logging
import RoboClient

private let log = Logger(label: "RoboClientDemo")

@main
struct RoboClientDemo: ParsableCommand {
    @Argument(help: "The URL of the Robo server")
    var url: URL = URL(string: "ws://localhost:19877")!

    @Option(help: "A Base64-encoded ChaCha20-Poly1305 key to encrypt messages with")
    var key: String?

    func runAsync<Security>(security: Security) async throws where Security: SecurityLayer {
        log.info("Running with \(security)")

        let client = try await RoboClient.connect(to: url, security: security)

        let commands: [String: ([String]) async throws -> Void] = [
            "keys": { args in
                let text = args.joined(separator: " ")
                try await client.send(action: .keySequence(text: text))
            },
            "moveto": { args in
                guard args.count == 2,
                      let x = Int(args[0]),
                      let y = Int(args[1]) else {
                    print("Syntax: [x] [y]")
                    return
                }
                try await client.send(action: .mouseMoveTo(point: .init(x: x, y: y)))
            },
            "moveby": { args in
                guard args.count == 2,
                      let dx = Int(args[0]),
                      let dy = Int(args[1]) else {
                    print("Syntax: [dx] [dy]")
                    return
                }
                try await client.send(action: .mouseMoveBy(delta: .init(x: dx, y: dy)))
            },
        ]

        log.info("Available commands: \(commands.keys.sorted().joined(separator: ", "))")
        log.info("Entered REPL, press Ctrl-D to exit.")

        while let line = readLine() {
            guard !line.isEmpty else { continue }
            let parsed = line.split(separator: " ").map(String.init)
            let command = parsed[0]
            let args = Array(parsed.dropFirst())
            guard let command = commands[command] else {
                log.warning("Command '\(command)' not found!")
                continue
            }
            try await command(args)
        }
    }

    func run() {
        Task {
            if let key = key, let keyData = Data(base64Encoded: key) {
                try! await runAsync(security: ChaChaPolySecurityLayer(key: keyData))
            } else {
                try! await runAsync(security: EmptySecurityLayer())
            }
            Self.exit()
        }

        dispatchMain()
    }
}

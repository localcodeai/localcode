import Foundation
import FoundationModels

struct Response: Codable {
    let content: String
    let error: String?
}

func generateResponse(prompt: String) async -> Response {
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
        let session = LanguageModelSession(instructions: {
            """
            You are LocalCode, an AI assistant that helps with coding tasks and CLI commands.
            Keep responses concise and helpful. Focus on being practical and direct.
            """
        })

        do {
            let result = try await session.respond(to: prompt)
            return Response(content: result.content, error: nil)
        } catch {
            return Response(content: "", error: error.localizedDescription)
        }

    case .unavailable(let reason):
        return Response(content: "", error: "Model unavailable: \(reason)")
    @unknown default:
        return Response(content: "", error: "Unknown model state")
    }
}

actor App {
    func run(prompt: String) async {
        let response = await generateResponse(prompt: prompt)
        if let data = try? JSONEncoder().encode(response) {
            print(String(data: data, encoding: .utf8) ?? "")
        }
    }
}

if CommandLine.arguments.count < 2 {
    let response = Response(content: "", error: "No prompt provided")
    if let data = try? JSONEncoder().encode(response) {
        print(String(data: data, encoding: .utf8) ?? "")
    }
    exit(1)
}

let prompt = CommandLine.arguments[1]

let app = App()
Task {
    await app.run(prompt: prompt)
    exit(0)
}

dispatchMain()
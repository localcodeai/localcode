import Foundation
import FoundationModels

struct Response: Codable {
    let content: String
    let error: String?
    let command: String?
}

func generateResponse(prompt: String) async -> Response {
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
        let session = LanguageModelSession(instructions: {
            """
            You are LocalCode, a CLI command translator powered by Apple's on-device AI.
            Convert natural language requests into shell commands.

            Examples:
            - "list all python files" → find . -name "*.py"
            - "find processes named python" → ps aux | grep python
            - "show my git status" → git status
            - "grep for hello in this directory" → grep -r "hello" .

            IMPORTANT: Output ONLY the raw command, no shell name prefix like "bash" or "sh".
            Put the command in a single code block. Nothing else.
            """
        })

        do {
            let result = try await session.respond(to: prompt)

            // Extract command from response
            let command = extractCommand(from: result.content)

            return Response(content: result.content, error: nil, command: command)
        } catch {
            return Response(content: "", error: error.localizedDescription, command: nil)
        }

    case .unavailable(let reason):
        return Response(content: "", error: "Model unavailable: \(reason)", command: nil)
    @unknown default:
        return Response(content: "", error: "Unknown model state", command: nil)
    }
}

func extractCommand(from text: String) -> String? {
    // Look for code blocks with backticks
    let pattern = "`([^`]+)`"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return nil
    }

    let range = NSRange(text.startIndex..., in: text)
    let matches = regex.matches(in: text, options: [], range: range)

    // Get the last match (the actual command)
    guard let lastMatch = matches.last else {
        return nil
    }

    if let cmdRange = Range(lastMatch.range(at: 1), in: text) {
        let cmd = String(text[cmdRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        if cmd.isEmpty {
            return nil
        }
        return cmd
    }
    return nil
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
    let response = Response(content: "", error: "No prompt provided", command: nil)
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
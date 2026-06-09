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
            You are LocalCode, an AI assistant that helps with coding tasks and suggests shell commands.
            When users ask you to do something like "grep my files for hello.py", respond with the suggested command.
            Format commands in code blocks using backticks.
            Example responses:
            - "Here's the command: `grep -r \"hello.py\" .`"
            - "To list all Python files: `find . -name \"*.py\"`"
            Keep responses concise and helpful.
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

    for match in matches {
        if let cmdRange = Range(match.range(at: 1), in: text) {
            let cmd = String(text[cmdRange])
            // Check if it looks like a shell command
            if cmd.contains(" ") || cmd.contains("/") || isKnownCommand(cmd) {
                return cmd
            }
        }
    }
    return nil
}

func isKnownCommand(_ cmd: String) -> Bool {
    let known = ["ls", "cd", "git", "grep", "find", "cat", "echo", "pwd", "swift", "go", "python", "node", "rm", "cp", "mv", "mkdir", "chmod", "sudo"]
    return known.contains { cmd.hasPrefix($0) }
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
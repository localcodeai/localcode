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
    if let lastMatch = matches.last,
       let cmdRange = Range(lastMatch.range(at: 1), in: text) {
        let cmd = String(text[cmdRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        if !cmd.isEmpty {
            return cmd
        }
    }

    // No backticks found - check if content itself looks like a command
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if isLikelyCommand(trimmed) {
        return trimmed
    }

    return nil
}

func isLikelyCommand(_ text: String) -> Bool {
    let knownCommands = ["find", "grep", "ls", "cd", "git", "cat", "echo", "pwd", "ps", "kill", "rm", "cp", "mv", "mkdir", "chmod", "sudo", "brew", "swift", "go", "python", "node", "curl", "wget", "ssh", "tar", "zip", "unzip"]
    let words = text.split(separator: " ")
    if let first = words.first {
        return knownCommands.contains(String(first))
    }
    return false
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
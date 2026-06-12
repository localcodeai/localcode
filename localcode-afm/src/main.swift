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

            Common patterns:
            - "list all [type] files" → find . -name "*.[ext]"
            - "find files named [name]" → find . -name "*[name]*"
            - "show largest files" → find . -type f -exec ls -lS {} + | head -n 5
            - "count lines of code" → find . -name "*.py" -o -name "*.go" | xargs wc -l
            - "check if port is in use" → lsof -i :8080
            - "show git status" → git status
            - "show recent changes" → git log --oneline -5

            IMPORTANT:
            - Output ONLY the raw command in a code block
            - No shell prefixes like "bash" or "sh"
            - Use standard unix commands (find, grep, ls, ps, lsof, netstat, git)
            - Keep commands practical and one-line
            """
        })

        do {
            let result = try await session.respond(to: prompt)
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
    let pattern = "`([^`]+)`"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return nil
    }

    let range = NSRange(text.startIndex..., in: text)
    let matches = regex.matches(in: text, options: [], range: range)

    if let lastMatch = matches.last,
       let cmdRange = Range(lastMatch.range(at: 1), in: text) {
        let cmd = String(text[cmdRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        if !cmd.isEmpty {
            let lines = cmd.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            let knownShellPrefixes = ["bash", "sh", "zsh", "fish", "dash"]
            if lines.count > 1 && knownShellPrefixes.contains(lines[0].trimmingCharacters(in: .whitespaces)) {
                return lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return cmd
        }
    }

    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if isLikelyCommand(trimmed) {
        return trimmed
    }

    return nil
}

func isLikelyCommand(_ text: String) -> Bool {
    let knownCommands = ["find", "grep", "ls", "cd", "git", "cat", "echo", "pwd", "ps", "kill", "rm", "cp", "mv", "mkdir", "chmod", "sudo", "brew", "swift", "go", "python", "node", "curl", "wget", "ssh", "tar", "zip", "unzip", "touch", "head", "tail", "sort", "uniq", "wc", "awk", "sed", "cut", "tree", "open", "xdg-open"]
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
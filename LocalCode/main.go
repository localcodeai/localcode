package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	"charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
)

type Message struct {
	role    string
	content string
}

type responseMsg struct {
	response string
}

type commandResultMsg struct {
	output string
	err    error
}

type confirmCmdMsg struct {
	cmd string
}

type Model struct {
	messages       []Message
	input          string
	pendingCmd     string
	pendingConfirm bool
	width          int
	height         int
}

func initialModel() Model {
	return Model{
		messages: []Message{
			{
				role:    "assistant",
				content: "Welcome to LocalCode! I'm powered by Apple's Foundation Models for on-device AI.\n\nI can help you with coding tasks and run CLI commands on your behalf.\n\nTry:\n- Type `!ls -la` to run a command\n- Ask me about your code\n- Ask for help\n\nNote: This POC uses mocked AI responses. Real AFM integration requires macOS 26.",
			},
		},
	}
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		return m, nil

	case responseMsg:
		m.messages = append(m.messages, Message{
			role:    "assistant",
			content: msg.response,
		})
		return m, nil

	case confirmCmdMsg:
		m.pendingCmd = msg.cmd
		m.pendingConfirm = true
		return m, nil

	case commandResultMsg:
		var response string
		if msg.err != nil {
			response = fmt.Sprintf("Error: %v\n%s", msg.err, msg.output)
		} else {
			response = fmt.Sprintf("Output:\n%s", msg.output)
		}
		m.messages = append(m.messages, Message{
			role:    "assistant",
			content: response,
		})
		m.pendingCmd = ""
		m.pendingConfirm = false
		return m, nil

	case tea.KeyMsg:
		if m.pendingConfirm {
			return m.handleConfirm(msg)
		}
		return m.handleInput(msg)
	}
	return m, nil
}

func (m Model) handleInput(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.Key()
	switch key.String() {
	case "enter":
		if m.input == "" {
			return m, nil
		}
		userMsg := m.input
		m.messages = append(m.messages, Message{role: "user", content: userMsg})
		m.input = ""
		return m, m.generateResponse(userMsg)

	case "backspace":
		if len(m.input) > 0 {
			m.input = m.input[:len(m.input)-1]
		}

	case "ctrl+c":
		return m, tea.Quit

	default:
		if key.Text != "" {
			m.input += key.Text
		}
	}
	return m, nil
}

func (m Model) handleConfirm(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.Key().String() {
	case "y", "enter":
		m.pendingConfirm = false
		cmd := m.pendingCmd
		m.pendingCmd = ""
		return m, m.executeCommand(cmd)
	case "n", "q", "esc":
		m.messages = append(m.messages, Message{
			role:    "assistant",
			content: "Command cancelled.",
		})
		m.pendingCmd = ""
		m.pendingConfirm = false
	}
	return m, nil
}

func (m Model) generateResponse(input string) tea.Cmd {
	return func() tea.Msg {
		time.Sleep(200 * time.Millisecond)

		lowerInput := strings.ToLower(input)

		if strings.HasPrefix(input, "!") || isCommandRequest(lowerInput) {
			cmd := extractCommand(input)
			if cmd != "" {
				return confirmCmdMsg{cmd: cmd}
			}
		}

		response := generateMockResponse(input)
		return responseMsg{response: response}
	}
}

func (m Model) executeCommand(cmd string) tea.Cmd {
	return func() tea.Msg {
		output, err := runCommand(cmd)
		return commandResultMsg{output: output, err: err}
	}
}

func runCommand(cmdStr string) (string, error) {
	parts := strings.Fields(cmdStr)
	if len(parts) == 0 {
		return "", fmt.Errorf("empty command")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, parts[0], parts[1:]...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return string(output), err
	}
	return string(output), nil
}

func isCommandRequest(input string) bool {
	triggers := []string{"run ", "execute ", "command ", "shell ", "bash "}
	for _, t := range triggers {
		if strings.Contains(input, t) {
			return true
		}
	}
	return false
}

func extractCommand(input string) string {
	if strings.HasPrefix(input, "!") {
		return strings.TrimPrefix(input, "!")
	}

	markers := []string{"run `", "execute `", "command `", "`"}
	for _, marker := range markers {
		if idx := strings.Index(input, marker); idx != -1 {
			start := idx + len(marker)
			if end := strings.Index(input[start:], "`"); end != -1 {
				return input[start : start+end]
			}
		}
	}

	words := strings.Fields(input)
	if len(words) >= 2 && isKnownCommand(words[0]) {
		parts := strings.SplitN(input, " ", 2)
		if len(parts) == 2 {
			return parts[1]
		}
	}

	return ""
}

func isKnownCommand(cmd string) bool {
	known := []string{"ls", "git", "pwd", "echo", "cat", "head", "tail", "grep", "find", "swift", "go", "python", "node"}
	for _, k := range known {
		if cmd == k {
			return true
		}
	}
	return false
}

func generateMockResponse(input string) string {
	lower := strings.ToLower(input)

	if strings.Contains(lower, "hello") || strings.Contains(lower, "hi") || strings.Contains(lower, "hey") {
		return "Hello! I'm LocalCode, your on-device AI assistant. How can I help you today?"
	}

	if strings.Contains(lower, "who are you") || strings.Contains(lower, "what are you") {
		return "I'm LocalCode - an open source CLI tool that uses Apple's Foundation Models for privacy-first, on-device AI assistance. Everything runs locally on your Apple Silicon Mac."
	}

	if strings.Contains(lower, "architecture") || strings.Contains(lower, "how does this work") {
		return "LocalCode architecture:\n\n• TUI Layer: Go + Bubble Tea for the terminal interface\n• AI Layer: Apple FoundationModels framework (macOS 26+)\n• CLI Exec: Native command execution\n\nThe framework is designed to be transparent and extensible."
	}

	if strings.Contains(lower, "help") {
		return "LocalCode Commands:\n\n• Type normally - I'll respond with AI\n• Prefix with `!` - I'll run it as a shell command\n• Examples:\n  - `!ls -la` - list files\n  - `!git status` - check git state\n  - `!swift build` - build project\n\nJust ask questions or describe what you need!"
	}

	if strings.Contains(lower, "git status") {
		return "I can run `git status` for you! Just type `!git status` or should I do it automatically? (Type `!git status` to execute)"
	}

	if strings.Contains(lower, "build") || strings.Contains(lower, "test") {
		return "I can run build/test commands! Use `!swift build` or `!swift test` to execute. The project uses Swift Package Manager."
	}

	return fmt.Sprintf("I understand you're asking about: %s\n\nThis is a POC with mocked AI responses. When macOS 26 releases with the FoundationModels framework, I'll provide real on-device AI responses.\n\nTry running a command with `!ls` or ask me something else!", truncate(input, 50))
}

func truncate(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max] + "..."
}

func (m Model) View() tea.View {
	header := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("12")).
		Render("LocalCode - Apple Foundation Models CLI")

	var sb strings.Builder
	sb.WriteString("\n" + header + "\n")
	sb.WriteString(strings.Repeat("─", min(m.width, 80)) + "\n")

	for _, msg := range m.messages {
		if msg.role == "user" {
			sb.WriteString(fmt.Sprintf("\nYou: %s\n", msg.content))
		} else {
			sb.WriteString(fmt.Sprintf("\nLocalCode: %s\n", msg.content))
		}
	}

	if m.pendingConfirm {
		sb.WriteString(fmt.Sprintf("\n%s %s", lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("11")).Render("Confirm:"), m.pendingCmd))
		sb.WriteString(fmt.Sprintf("\n%s ", lipgloss.NewStyle().Faint(true).Render("[Y]es [N]o [Q]uit")))
	}

	sb.WriteString(fmt.Sprintf("\n\n%s%s ", lipgloss.NewStyle().Faint(true).Render(">"), m.input))

	if m.pendingConfirm {
		sb.WriteString(fmt.Sprintf("\n%s ", lipgloss.NewStyle().Faint(true).Render("Ctrl+C: Quit | Enter: Execute | Esc: Cancel")))
	} else {
		sb.WriteString(fmt.Sprintf("\n%s ", lipgloss.NewStyle().Faint(true).Render("Ctrl+C: Quit | !: Run command")))
	}

	v := tea.NewView(sb.String())
	v.AltScreen = true
	return v
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
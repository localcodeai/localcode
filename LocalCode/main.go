package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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
				content: "Welcome to LocalCode! I'm powered by Apple's Foundation Models for on-device AI.\n\nI can help you with coding tasks and run CLI commands on your behalf.\n\nTry:\n- Type `!ls -la` to run a command\n- Ask me about your code\n- Ask for help",
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
		lowerInput := strings.ToLower(input)

		if strings.HasPrefix(input, "!") || isCommandRequest(lowerInput) {
			cmd := extractCommand(input)
			if cmd != "" {
				return confirmCmdMsg{cmd: cmd}
			}
		}

		response := callAFMHelper(input)
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

func callAFMHelper(prompt string) string {
	helperPath := filepath.Join("Sources", "afmhelper", "afmhelper")

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, helperPath, prompt)
	output, err := cmd.Output()
	if err != nil {
		return fmt.Sprintf("Error calling AFM helper: %v", err)
	}

	var response struct {
		Content string `json:"content"`
		Error   string `json:"error"`
	}
	if err := json.Unmarshal(output, &response); err != nil {
		return fmt.Sprintf("Error parsing response: %v", err)
	}

	if response.Error != "" {
		return fmt.Sprintf("AFM Error: %s", response.Error)
	}

	return response.Content
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
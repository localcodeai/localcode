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
				content: "Welcome to LocalCode! I'm powered by Apple's Foundation Models for on-device AI.\n\nI can help you with coding tasks, explain code, or suggest commands.\n\nJust ask me anything!",
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
	case "enter", "y":
		m.pendingConfirm = false
		cmd := m.pendingCmd
		m.pendingCmd = ""
		return m, m.executeCommand(cmd)
	case "n", "q", "esc":
		m.messages = append(m.messages, Message{
			role:    "assistant",
			content: "Command cancelled. Let me know if you'd like to try something else.",
		})
		m.pendingCmd = ""
		m.pendingConfirm = false
	default:
		if msg.Key().String() == "backspace" && len(m.pendingCmd) > 0 {
			m.pendingCmd = m.pendingCmd[:len(m.pendingCmd)-1]
		} else if msg.Key().Text != "" {
			m.pendingCmd += msg.Key().Text
		}
	}
	return m, nil
}

func (m Model) generateResponse(input string) tea.Cmd {
	return func() tea.Msg {
		response, cmd := callAFMHelper(input)
		if cmd != "" {
			return confirmCmdMsg{cmd: cmd}
		}
		return responseMsg{response: response}
	}
}

func (m Model) executeCommand(cmd string) tea.Cmd {
	return func() tea.Msg {
		output, err := runCommand(cmd)
		var response string
		if err != nil {
			response = fmt.Sprintf("Error running command: %v\n%s", err, output)
		} else {
			response = fmt.Sprintf("Output:\n%s", output)
		}
		return responseMsg{response: response}
	}
}

func runCommand(cmdStr string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "/bin/sh", "-c", cmdStr)
	output, err := cmd.CombinedOutput()

	// Exit code 1 often means "nothing found" (e.g., lsof, grep, find with no matches)
	// This is a valid result, not an error
	if exitErr, ok := err.(*exec.ExitError); ok {
		if exitErr.ExitCode() == 1 {
			// Command ran but found nothing - not an error
			return string(output), nil
		}
	}

	if err != nil {
		return string(output), err
	}
	return string(output), nil
}

func callAFMHelper(prompt string) (string, string) {
	helperPath := filepath.Join("Sources", "afmhelper", "afmhelper")

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, helperPath, prompt)
	output, err := cmd.Output()
	if err != nil {
		return fmt.Sprintf("Error calling AFM helper: %v", err), ""
	}

	var response struct {
		Content string `json:"content"`
		Error   string `json:"error"`
		Command string `json:"command"`
	}
	if err := json.Unmarshal(output, &response); err != nil {
		return fmt.Sprintf("Error parsing response: %v", err), ""
	}

	if response.Error != "" {
		return fmt.Sprintf("AFM Error: %s", response.Error), ""
	}

	return response.Content, response.Command
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
		sb.WriteString(fmt.Sprintf("\n%s\n", lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("11")).Render("▶ Execute this command?")))
		sb.WriteString(fmt.Sprintf("%s\n", lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("12")).Render(m.pendingCmd)))
		sb.WriteString(fmt.Sprintf("\n%s ", lipgloss.NewStyle().Faint(true).Render("[Enter] Run | [N] Cancel | Edit command")))
	} else {
		sb.WriteString(fmt.Sprintf("\n\n%s%s ", lipgloss.NewStyle().Faint(true).Render(">"), m.input))
		sb.WriteString(fmt.Sprintf("\n%s ", lipgloss.NewStyle().Faint(true).Render("Ctrl+C: Quit")))
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
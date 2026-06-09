package main

import "testing"

func TestRunCommand(t *testing.T) {
	tests := []struct {
		name    string
		cmd     string
		wantErr bool
	}{
		{"simple echo", "echo hello", false},
		{"pwd", "pwd", false},
		{"list files", "ls -la .", false},
		{"find go files", "find . -name '*.go'", false},
		{"count files", "find . -type f | wc -l", false},
		{"git status", "git status", false},
		{"grep", "grep -r 'test' .", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := runCommand(tt.cmd)
			if (err != nil) != tt.wantErr {
				t.Errorf("runCommand(%q) error = %v, wantErr %v", tt.cmd, err, tt.wantErr)
			}
		})
	}
}

func TestMin(t *testing.T) {
	tests := []struct {
		a, b   int
		expect int
	}{
		{1, 2, 1},
		{2, 1, 1},
		{5, 5, 5},
		{0, 1, 0},
		{-1, 1, -1},
	}

	for _, tt := range tests {
		got := min(tt.a, tt.b)
		if got != tt.expect {
			t.Errorf("min(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.expect)
		}
	}
}

func TestMessageRoles(t *testing.T) {
	msg := Message{role: "user", content: "test"}
	if msg.role != "user" {
		t.Errorf("Message role = %q, want 'user'", msg.role)
	}

	asstMsg := Message{role: "assistant", content: "response"}
	if asstMsg.role != "assistant" {
		t.Errorf("Message role = %q, want 'assistant'", asstMsg.role)
	}
}
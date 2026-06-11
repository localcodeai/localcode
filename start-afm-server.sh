#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AFMHELPER="$SCRIPT_DIR/LocalCode/Sources/afmhelper/afmhelper"
SERVER_PORT=8080

if [ ! -f "$AFMHELPER" ]; then
    echo "Building AFM helper..."
    cd "$SCRIPT_DIR/LocalCode/Sources/afmhelper"
    swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0
    cd "$SCRIPT_DIR"
fi

echo "Starting AFM HTTP Server on http://localhost:$SERVER_PORT"

bun --eval '
import { spawn } from "bun";

const AFM_HELPER = "'"$AFMHELPER"'";

const server = Bun.serve({
  port: '"$SERVER_PORT"',
  async fetch(req) {
    const url = new URL(req.url);
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    };

    if (req.method === "OPTIONS") {
      return new Response(null, { status: 200, headers: cors });
    }

    if (url.pathname === "/v1/models" && req.method === "GET") {
      return Response.json({
        object: "list",
        data: [{
          id: "afm",
          object: "model",
          created: Date.now(),
          name: "Apple Foundation Models",
          owned_by: "local"
        }]
      }, { headers: { ...cors, "Content-Type": "application/json" } });
    }

    if (url.pathname === "/v1/chat/completions" && req.method === "POST") {
      try {
        const body = await req.json();
        const messages = body.messages || [];
        const content = messages[messages.length - 1]?.content || "";
        const stream = body.stream === true;

        const proc = spawn({
          cmd: [AFM_HELPER, content],
          stdout: "pipe",
          stderr: "pipe",
        });

        const [stdout, stderr, exitCode] = await Promise.all([
          new Response(proc.stdout).text(),
          new Response(proc.stderr).text(),
          proc.exited,
        ]);

        if (exitCode !== 0) {
          return Response.json({
            error: { message: "AFM error: " + stderr, type: "internal_error", code: 500 }
          }, { status: 500, headers: { ...cors, "Content-Type": "application/json" } });
        }

        let afmResponse;
        try {
          afmResponse = JSON.parse(stdout);
        } catch {
          return Response.json({
            error: { message: "Invalid JSON from AFM: " + stdout, type: "internal_error", code: 500 }
          }, { status: 500, headers: { ...cors, "Content-Type": "application/json" } });
        }

        const text = afmResponse.command || afmResponse.content || "";
        const id = "chatcmpl-" + Date.now();

        if (stream) {
          const encoder = new TextEncoder();
          const sse = new ReadableStream({
            start(controller) {
              const chunk = JSON.stringify({
                id,
                object: "chat.completion.chunk",
                created: Date.now(),
                model: "afm",
                choices: [{ index: 0, delta: { content: text }, finish_reason: null }]
              });
              controller.enqueue(encoder.encode("data: " + chunk + "\n\n"));
              const finalChunk = JSON.stringify({
                id,
                object: "chat.completion.chunk",
                created: Date.now(),
                model: "afm",
                choices: [{ index: 0, delta: {}, finish_reason: "stop" }]
              });
              controller.enqueue(encoder.encode("data: " + finalChunk + "\n\n"));
              controller.enqueue(encoder.encode("data: [DONE]\n\n"));
              controller.close();
            }
          });
          return new Response(sse, {
            headers: { ...cors, "Content-Type": "text/event-stream", "Transfer-Encoding": "chunked" }
          });
        }

        return Response.json({
          id,
          object: "chat.completion",
          created: Date.now(),
          model: "afm",
          choices: [{
            index: 0,
            message: { role: "assistant", content: text },
            finish_reason: "stop"
          }],
          usage: { prompt_tokens: content.length, completion_tokens: text.length, total_tokens: content.length + text.length }
        }, { headers: { ...cors, "Content-Type": "application/json" } });

      } catch (error) {
        return Response.json({
          error: { message: String(error), type: "internal_error", code: 500 }
        }, { status: 500, headers: { ...cors, "Content-Type": "application/json" } });
      }
    }

    if (req.method === "POST" && url.pathname === "/") {
      const body = await req.json();
      const message = body.message;
      if (!message) {
        return Response.json({ error: "No message provided" }, { status: 400, headers: cors });
      }
      const proc = spawn({ cmd: [AFM_HELPER, message], stdout: "pipe", stderr: "pipe" });
      const [stdout, stderr, exitCode] = await Promise.all([
        new Response(proc.stdout).text(),
        new Response(proc.stderr).text(),
        proc.exited,
      ]);
      if (exitCode !== 0) {
        return Response.json({ error: "AFM error: " + stderr }, { status: 500, headers: cors });
      }
      try {
        return Response.json(JSON.parse(stdout), { headers: cors });
      } catch {
        return Response.json({ error: "Invalid JSON", content: stdout }, { status: 500, headers: cors });
      }
    }

    return new Response("Not found", { status: 404 });
  },
});

console.log("AFM HTTP Server running on http://localhost:" + server.port);
'
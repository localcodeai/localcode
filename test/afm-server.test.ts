import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { spawn } from "bun";

const SERVER_URL = "http://localhost:8080";
const AFM_HELPER = "./LocalCode/Sources/afmhelper/afmhelper";

describe("AFM Server", () => {
  let serverProcess: any;

  beforeAll(async () => {
    const proc = Bun.spawn({
      cmd: ["./start-afm-server.sh"],
      cwd: process.cwd(),
      stdout: "pipe",
      stderr: "pipe",
    });
    serverProcess = proc;
    await new Promise((resolve) => setTimeout(resolve, 2000));
  });

  afterAll(() => {
    if (serverProcess) {
      serverProcess.kill();
    }
  });

  it("GET /v1/models returns model list", async () => {
    const res = await fetch(`${SERVER_URL}/v1/models`);
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.object).toBe("list");
    expect(data.data[0].id).toBe("afm");
  });

  it("POST /v1/chat/completions returns command suggestion", async () => {
    const res = await fetch(`${SERVER_URL}/v1/chat/completions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "afm",
        messages: [{ role: "user", content: "hello" }],
      }),
    });
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.choices[0].message.content).toBeDefined();
    expect(data.choices[0].message.role).toBe("assistant");
  });

  it("POST / legacy format still works", async () => {
    const res = await fetch(`${SERVER_URL}/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "test" }),
    });
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.command).toBeDefined();
  });
});
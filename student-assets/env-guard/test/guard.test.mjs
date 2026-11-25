import assert from "node:assert/strict";
import { inspectExecution, sensitivePathReason } from "../index.js";

let passed = 0;

function test(name, run) {
  try {
    run();
    passed += 1;
    console.log(`PASS ${name}`);
  } catch (error) {
    console.error(`FAIL ${name}`);
    throw error;
  }
}

test("blocks root .env through read", () => {
  const result = inspectExecution({
    name: "read",
    arguments: { file_path: ".env" },
  });
  assert.equal(result?.kind, "deny");
  assert.equal(result?.info?.code, "SENSITIVE_FILE_BLOCKED");
});

test("blocks nested environment file", () => {
  const result = inspectExecution({
    name: "read",
    arguments: { file_path: "services/api/.env.local" },
  });
  assert.equal(result?.kind, "deny");
});

test("allows placeholder .env.example", () => {
  assert.equal(sensitivePathReason("config/.env.example"), undefined);
  assert.equal(
    inspectExecution({
      name: "read",
      arguments: { file_path: "config/.env.example" },
    }),
    undefined,
  );
});

test("blocks private key writes and edits", () => {
  for (const name of ["write", "edit"]) {
    assert.equal(
      inspectExecution({
        name,
        arguments: { file_path: "fixtures/credential.demo.pem" },
      })?.kind,
      "deny",
    );
  }
});

test("blocks shell access to .env", () => {
  const result = inspectExecution({
    name: "pwsh",
    arguments: { command: "Get-Content .\\.env" },
  });
  assert.equal(result?.kind, "deny");
});

test("allows normal README reads", () => {
  assert.equal(
    inspectExecution({
      name: "read",
      arguments: { file_path: "README.md" },
    }),
    undefined,
  );
});

console.log(`${passed} passed`);


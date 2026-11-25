import assert from "node:assert/strict";

import {
  inspectExecution,
  sensitivePathReason,
} from "../index.js";

let passed = 0;

function test(name, fn) {
  try {
    fn();
    passed += 1;
    console.log(`PASS ${name}`);
  } catch (error) {
    console.error(`FAIL ${name}`);
    throw error;
  }
}

test("blocks root .env through read", () => {
  const decision = inspectExecution({
    name: "read",
    arguments: { file_path: ".env" },
  });
  assert.equal(decision?.kind, "deny");
  assert.equal(decision?.info?.code, "SENSITIVE_FILE_BLOCKED");
});

test("blocks nested environment file", () => {
  const decision = inspectExecution({
    name: "read",
    arguments: { file_path: "services/api/.env.local" },
  });
  assert.equal(decision?.kind, "deny");
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

test("blocks shell redirection around .env", () => {
  const decision = inspectExecution({
    name: "pwsh",
    arguments: { command: "Get-Content .\\.env" },
  });
  assert.equal(decision?.kind, "deny");
});

test("passes normal README reads to next", () => {
  assert.equal(
    inspectExecution({
      name: "read",
      arguments: { file_path: "README.md" },
    }),
    undefined,
  );
});

console.log(`${passed} passed`);


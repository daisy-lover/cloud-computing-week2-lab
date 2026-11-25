// Student implementation file.
// Search for TODO_STUDENT_IMPLEMENTATION and complete the exercise yourself.

const FILE_PATH_TOOLS = new Set([
  "read",
  "read_image",
  "write",
  "edit",
  "apply_patch",
  "str_replace_editor",
]);

const SHELL_TOOLS = new Set([
  "bash",
  "pwsh",
  "run_command",
  "persistent_bash",
  "persistent_pwsh",
]);

export function sensitivePathReason(value) {
  // TODO_STUDENT_IMPLEMENTATION: distinguish .env, .env.local, private keys,
  // and credential files from safe placeholders such as .env.example.
  return undefined;
}

export function inspectExecution(exec) {
  // TODO_STUDENT_IMPLEMENTATION: return a deny decision before the real tool
  // runs. For allowed calls, return undefined so the plugin can call next().
  return undefined;
}

export const name = "env-guard";
export const inject = ["tools"];

export function apply(ctx) {
  ctx.on("tools/pre-execute", async (exec, next) => {
    return inspectExecution(exec) ?? next();
  });
}


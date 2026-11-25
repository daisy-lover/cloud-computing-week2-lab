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

const BLOCKED_MESSAGE =
  "[env-guard] 已拦截：该路径属于环境文件或凭据文件，读取会把敏感内容写入模型上下文和会话记录。"
  + "请勿尝试通过其他工具绕过；如需完成代码分析，请读取 README.md、源码、配置模板或 .env.example 中的占位说明。";

const BLOCKED_INFO = Object.freeze({
  name: "EnvGuardDenied",
  code: "SENSITIVE_FILE_BLOCKED",
});

function asRecord(value) {
  return value && typeof value === "object" ? value : {};
}

function normalize(value) {
  return String(value ?? "").replaceAll("\\", "/").trim();
}

function pathCandidates(exec) {
  const args = asRecord(exec?.arguments);
  const candidates = [];
  for (const [key, value] of Object.entries(args)) {
    if (typeof value !== "string") continue;
    if (/path|file/i.test(key)) candidates.push(value);
  }
  return candidates;
}

/**
 * Return a human-readable reason when a path names a protected file.
 * `.env.example` is intentionally allowed because it contains placeholders,
 * not credentials.
 */
export function sensitivePathReason(value) {
  const normalized = normalize(value);
  if (!normalized) return undefined;

  const basename = normalized.split("/").at(-1)?.toLowerCase() ?? "";
  const isEnvFile =
    basename === ".env"
    || (basename.startsWith(".env.") && basename !== ".env.example");
  const segments = normalized.toLowerCase().split("/");
  const hasEnvSegment = segments.some(
    (segment) =>
      segment === ".env"
      || (segment.startsWith(".env.") && segment !== ".env.example"),
  );
  const isPrivateKey = /\.(pem|key|p12|pfx)$/i.test(basename);
  const isCredentialFile = /^(credentials?|secrets?)(\.[a-z0-9_-]+)?$/i.test(
    basename,
  );

  if (isEnvFile || hasEnvSegment) return `环境文件 ${basename}`;
  if (isPrivateKey) return `私钥或证书文件 ${basename}`;
  if (isCredentialFile) return `凭据文件 ${basename}`;
  return undefined;
}

function shellReferencesSensitiveFile(command) {
  const value = normalize(command);
  // This is a lab policy, not a complete command sandbox. It catches direct
  // path references while the filesystem/shell sandbox remains the real boundary.
  return /(^|[\s"'`/=])(\.env(?:\.[a-z0-9_-]+)?|\.?[a-z0-9_-]+\.(?:pem|key|p12|pfx))(?=$|[\s"'`/\\])/i.test(
    value,
  );
}

/**
 * Pure policy used by both the plugin and its no-model unit test.
 * Returns a deny decision, or undefined to let the normal tool pipeline proceed.
 */
export function inspectExecution(exec) {
  const name = String(exec?.name ?? "");
  const args = asRecord(exec?.arguments);

  if (FILE_PATH_TOOLS.has(name)) {
    for (const candidate of pathCandidates(exec)) {
      const reason = sensitivePathReason(candidate);
      if (reason) {
        return {
          kind: "deny",
          reason: `${BLOCKED_MESSAGE}\n命中：${reason}`,
          info: BLOCKED_INFO,
        };
      }
    }
  }

  if (SHELL_TOOLS.has(name)) {
    const command = [
      args.command,
      args.cmd,
      args.script,
      args.workdir,
    ].find((value) => typeof value === "string");
    if (command && shellReferencesSensitiveFile(command)) {
      return {
        kind: "deny",
        reason: `${BLOCKED_MESSAGE}\n命中：命令中直接引用了敏感文件`,
        info: BLOCKED_INFO,
      };
    }
  }

  return undefined;
}

export const name = "env-guard";
export const inject = ["tools"];

export function apply(ctx) {
  ctx.on("tools/pre-execute", async (exec, next) => {
    return inspectExecution(exec) ?? next();
  });
}


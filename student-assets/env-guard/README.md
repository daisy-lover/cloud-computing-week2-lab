# env-guard 学生任务

本目录是待完成的 DSH 安全插件。按实验指导 B3：

1. 在 `index.js` 中完成敏感路径识别；
2. 在 `tools/pre-execute` waterfall 中返回 `{ kind: "deny", reason, info }`；
3. 普通文件和非敏感命令调用 `next()`；
4. 允许 `.env.example`，拦截 `.env`、`.env.*`、私钥和凭据文件；
5. 运行测试：

```powershell
node .\test\guard.test.mjs
```

测试全部通过后，在材料包根目录运行：

```powershell
dsh plugin --profile web add .\plugins\env-guard
```

不要通过读取伪装成普通文件、改用 shell 命令或其他方式绕过拒绝结果。


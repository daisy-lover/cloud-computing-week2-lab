# dsh-env-guard

`dsh-env-guard` 是第 2 周实训使用的 DSH 组合包。它在
`tools/pre-execute` waterfall 中检查工具参数：

- 对文件工具，拦截 `.env`、`.env.local`、`.pem`、`.key`、credential/secret
  文件；
- 对 shell 工具，拦截命令字符串中直接引用上述敏感路径的调用；
- 允许读取 `.env.example` 等只含占位符的模板；
- 未命中时调用 `next()`，保留 DSH 原有执行流水线。

## 安装

在实验包根目录执行：

```powershell
dsh plugin --profile web add .\plugins\env-guard
dsh --profile web --dump-config | Select-String "dsh-env-guard"
```

安装后重启 `dsh web` 并新建会话。

## 单元测试

```powershell
Set-Location .\plugins\env-guard
node .\test\guard.test.mjs
```

预期输出 `6 passed`。测试不需要模型 API Key。

## 安全边界

这是课堂策略示例。静态路径和命令字符串检查不能代替真正的操作系统权限、
容器隔离或网关侧凭据隔离。生产系统还应限制 shell 命令、限制网络出口，并
禁止真实密钥与智能体工作区同机可读。


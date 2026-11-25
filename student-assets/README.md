# 第 2 周实验学生材料包

本包用于完成“Pi / DSH 双引擎对比”实验，只包含学生所需材料。

## 建议使用顺序

1. 阅读 `docs/学生环境自查.md`，把环境修到没有 `FAIL`。
2. 按 `docs/学生实验指导.md` 完成 A、B 两部分。
3. 使用 `docs/实验记录表模板.md` 记录真实数据。
4. 按 `docs/实验报告模板.md` 整理最终报告。

## 模型服务

本实验使用 [ChatECNU](https://chat.ecnu.edu.cn/)，每位学生使用自己的 Key。
Key 的获取步骤以教师另发的“ChatECNU Key 获取说明”为准。

固定连接参数：

| 参数 | 值 |
|---|---|
| Base URL | `https://chat.ecnu.edu.cn/open/api/v1` |
| API 协议 | `OpenAI Chat Completions` |
| Provider ID | `ecnu-chat` |
| 模型 ID | `ecnu-plus`、`ecnu-max` |
| Key 环境变量 | `ECNU_CHAT_API_KEY` |

不要把 Key 写进本材料包、实验报告、截图或 Git。

## 目录

```text
.
├─ docs/                    学生实验文档、自查文档和提交模板
├─ lab-repo/                本实验分析的示例代码仓库
├─ plugins/env-guard/       需要你补全的 DSH 插件骨架和测试
├─ config/                  ChatECNU 模型配置模板
└─ scripts/                 环境检查、模型配置和实验准备脚本
```

## 快速检查

在材料包根目录打开 PowerShell：

```powershell
pwsh -NoProfile -File .\scripts\check-student-env.ps1
```

插件尚未完成时，脚本会把插件测试标为 `PENDING`；完成 B3 后重新运行，应变为
`PASS`。


# 第 2 周实训：Pi / DSH 双引擎对比

本目录是助教可直接分发和验收的实验包。原来的
`2026-11-25_第2周实训指导文档.md` 保留作历史草稿；其中 `npm install -g pi`、
`/branch`、`dsh --profile code` 等命令已不适用于当前发行版，请以本 README
指向的新版材料为准。

## 学生入口

1. 阅读 [学生环境自查](docs/学生环境自查.md)，逐项修到全部通过。
2. 按 [学生实验指导](docs/学生实验指导.md) 完成 A、B 两部分。
3. 使用 [实验记录表](docs/实验记录表模板.md) 记录真实数据。
4. 按 [实验报告模板](docs/实验报告模板.md) 整理提交物。

## 助教入口

- [助教课前检查清单](docs/助教课前检查清单.md)
- [评分与验收说明](docs/评分与验收说明.md)
- [助教验收记录](docs/助教验收记录.md)
- 示例项目：[lab-repo](lab-repo)
- DSH 防线插件：[plugins/env-guard](plugins/env-guard)
- 自动检查：

```powershell
pwsh -NoProfile -File .\scripts\check-deliverables.ps1
pwsh -NoProfile -File .\scripts\check-student-env.ps1
```

第二条命令在当前机器未安装全局 `pi` / `dsh` 时会失败，这是预期结果；先把
环境补齐，再运行学生实验。

生成只含学生材料、不含助教内部文档和插件答案的压缩包：

```powershell
pwsh -NoProfile -File .\scripts\build-student-package.ps1
```

## 已验证的版本基线

核验日期：2026-11-25。

| 组件 | 固定版本 | 最低 Node.js |
|---|---|---|
| Pi CLI | `@earendil-works/pi-coding-agent@1.6.0` | 22.19.0 |
| DeepSeek Harness | `@deepseek-ai/dsh@0.2.2-rc.5` | 24.9.0 |

两个工具都要求 Node.js 版本满足各自条件。为了同时运行，建议使用
Node.js 24 LTS（本次验证时最新 LTS 为 24.22.3）。

## 模型服务说明

本课程统一使用 [ChatECNU](https://chat.ecnu.edu.cn/)：

- Base URL：`https://chat.ecnu.edu.cn/open/api/v1`
- API 协议：`OpenAI Chat Completions`
- 模型 ID：`ecnu-plus`、`ecnu-max`
- Key 环境变量：`ECNU_CHAT_API_KEY`

每位学生使用自己的 Key。请不要把 Key 放进 `README`、实验报告、截图或 Git。
仓库自带的环境检查不会打印 Key。

本项目发布前已检查该值不会出现在文件、Git 历史或待提交内容中。

## 发布状态

公开仓库地址：
`https://github.com/daisy-lover/cloud-computing-week2-lab`

助教已完成真实模型验收：Pi 精确/模糊/分叉流程、DSH 无插件泄漏、插件拦截、
README 反向放行和持久化日志均通过。细节见
[助教验收记录](docs/助教验收记录.md)。

如果当前网络无法访问 GitHub，也可使用本地实验包完成课堂实验。发布与更新方法
见 [助教课前检查清单](docs/助教课前检查清单.md#发布到-github)。


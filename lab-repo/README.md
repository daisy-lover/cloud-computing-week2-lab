# TicketFlow

TicketFlow 是一个用于课堂实验的小型客服工单分类服务。它读取客服消息，根据显式
关键词规则给出分类、优先级和可解释原因，并把结果追加到 JSONL 数据文件。

这个仓库故意保留了一些真实项目常见的工程风险，供代码分析与安全实验使用。
它不是生产级系统。

## 功能

- `add`：创建并保存一张工单；
- `classify`：对一段文本做分类；
- `summary`：按分类和优先级统计工单；
- `serve`：批量读取已有工单并输出分类结果（当前为最小演示实现）。

## 运行

需要 Python 3.10+，没有第三方运行依赖。

```powershell
python -m ticketflow --help
python -m ticketflow summary
python -m ticketflow --data data/tickets.jsonl summary
python -m ticketflow classify "支付成功后订单仍未发货"
python -m ticketflow add "登录时一直提示密码错误" --channel web
```

## 测试

```powershell
python -m unittest discover -s tests -v
```

## 配置

`config/tickets.json` 保存默认数据路径和渠道开关。课内演示的 `.env` 由
`scripts/setup-lab.ps1` 创建，全部是假值；不要提交 `.env`。

## 已知边界

- 分类规则是演示用关键词，不是机器学习模型；
- JSONL 存储没有事务和跨进程锁；
- `summary` 会一次性载入全部记录；
- 命令行错误信息可能包含用户输入，正式系统应做脱敏；
- 当前日志和测试没有覆盖并发写入。

这些边界会出现在“潜在风险清单”中，不要求在本实验内修复。


# Node.js 24 环境复核

验收日期：2026-11-25（Asia/Shanghai）

已安装官方 Node.js 24 LTS，并将新版本放在系统 PATH 的前面。

| 组件 | 版本 |
|---|---|
| Node.js | v24.22.3 |
| npm | 11.19.1 |
| Pi | 1.6.0 |
| DSH | 0.2.2-rc.5 |
| pnpm | 12.23.0 |

学生环境检查结果：

```text
PASS=11 WARN=2 FAIL=0
```

两个 WARN 分别是当前终端尚未注入模型凭据，以及 Git 工作区有本轮待提交文档；不是环境故障。

旧 Node.js 22 保留在 `D:\Software\Node` 作为回退，新版本位于 `D:\Software\Node24`。重新打开终端后应执行：

```powershell
node --version
npm --version
pi --version
dsh --version
pnpm --version
```

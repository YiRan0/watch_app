# macOS 应用后台守护安装脚本（AppleScript 隐藏版）

## 📌 功能说明

`install_watch_single.sh` 是一款用于 **macOS** 的自动化守护安装脚本，它可以：

- 自动监控指定应用是否在运行  
- **仅在应用未运行时启动**  
- 启动后立即 **隐藏窗口**，避免弹出到前台  
- 每个应用独立生成 plist 和监控脚本，便于单独管理  

---
## ⚙️ 文件结构

执行安装脚本后，将生成以下文件：

- `~/check_<AppName>.sh`  
  - 监控脚本，使用 AppleScript 启动应用并隐藏窗口  
  - 示例：`check_Notes.sh`  

- `~/Library/LaunchAgents/com.user.<AppName>.plist`  
  - `launchd` 配置文件  
  - 示例：`com.user.Notes.plist`  

- 日志文件（存放在 `/tmp` 目录）  
  - `check_<AppName>.out`  
  - `check_<AppName>.err`  

---

## 🚀 安装与使用

### 1. 下载脚本
```bash
chmod +x install_watch_single.sh
```
### 2. 运行安装
```bash
./install_watch_single.sh
```
脚本会提示输入：
1. 应用名（如 `Notes`）
2. 应用路径（如 `/System/Applications/Notes.app`）

安装完成后：
- 生成对应的监控脚本  
- 创建并加载对应 plist
- 立即开始监控应用，确保未运行时自动启动并隐藏窗口

## 🔄 开机自启

- plist 文件位于 `~/Library/LaunchAgents/`
- macOS 会在开机时自动加载，守护进程无需手动运行

## 🛠 卸载方法

如果需要移除某个应用的守护进程：
```bash
# 卸载守护进程
launchctl unload ~/Library/LaunchAgents/com.user.<AppName>.plist  
# 删除 plist 文件 
rm ~/Library/LaunchAgents/com.user.<AppName>.plist  
# 删除监控脚本 
rm ~/check_<AppName>.sh
```
示例：卸载 Notes
```bash
launchctl unload ~/Library/LaunchAgents/com.user.Notes.plist
rm ~/Library/LaunchAgents/com.user.Notes.plist
rm ~/check_Notes.sh
```

## ⚡ 特性说明

- **后台启动 & 隐藏窗口**
    - 使用 AppleScript `launch` 启动应用
    - `set visible to false` 隐藏窗口
- **只启动未运行的程序**
    - AppleScript 判断 `if not running then launch`
- **日志记录**
    - 输出到 `/tmp/check_<AppName>.out` 和 `/tmp/check_<AppName>.err`
- **独立管理**
    - 每个应用生成独立的 plist 和监控脚本，可单独卸载

## ❓ 常见问题

- **Q: 日志文件会自动清空吗？**
    - 不会，日志会累积。如果需要清空，请手动删除 `/tmp/check_<AppName>.out` 和 `/tmp/check_<AppName>.err`
    
- **Q: 如果应用已经在后台运行会怎么样？**
    - 守护脚本会检测到已运行，**不会重复启动**
    
- **Q: 多个程序如何监控？**
    - 目前版本需分别运行安装脚本，每个应用生成独立 plist

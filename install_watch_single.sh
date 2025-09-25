#!/bin/bash

echo "请输入应用名（如 Notes）："
read APP_NAME

echo "请输入应用路径（如 /System/Applications/Notes.app）："
read APP_PATH

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
SCRIPT_PATH="${USER_HOME}/check_${APP_NAME}.sh"
PLIST_PATH="${USER_HOME}/Library/LaunchAgents/com.user.${APP_NAME}.plist"

# 卸载旧的守护进程（如果存在）
launchctl unload "$PLIST_PATH" 2>/dev/null

# 生成新的监控脚本
cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
# 使用 AppleScript 判断程序是否运行，仅在未运行时启动并隐藏窗口
osascript <<APPLESCRIPT
tell application "$APP_NAME"
    if not running then
        launch
        set visible to false
    end if
end tell
APPLESCRIPT
EOL

chmod +x "$SCRIPT_PATH"

# 生成 plist
mkdir -p "${USER_HOME}/Library/LaunchAgents"
cat > "$PLIST_PATH" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.${APP_NAME}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_PATH}</string>
    </array>

    <key>StartInterval</key>
    <integer>300</integer>

    <key>StandardOutPath</key>
    <string>/tmp/check_${APP_NAME}.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/check_${APP_NAME}.err</string>
</dict>
</plist>
EOL

# 加载新的守护进程
launchctl load "$PLIST_PATH"

echo "✅ $APP_NAME 守护进程已创建，程序仅在未运行时启动并隐藏窗口"

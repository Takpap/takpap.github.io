#!/bin/bash

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
    echo "❌ 此脚本需要以 root 权限运行，请使用 sudo 运行！"
    exit 1
fi

# 检查包管理器
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="apt-get install -y"
else
    echo "❌ 不支持的包管理器！仅支持 apt-get。"
    exit 1
fi

# 检查 whiptail 是否存在，若不存在则安装
if ! command -v whiptail &> /dev/null; then
    $PKG_UPDATE
    $PKG_INSTALL whiptail
fi

# 用户选择安装的组件
CHOICES=$(whiptail --title "选择要安装的组件" --checklist \
"选择要安装的组件（使用空格键选择，Enter 确认）" 20 78 10 \
"proxychains4" "代理工具" ON \
"zsh" "Zsh Shell" ON \
"oh-my-zsh" "Oh My Zsh 框架" ON \
"zsh-plugins" "Zsh 插件（自动补全和高亮）" ON \
"nodejs" "Node.js 和 npm" ON \
"bun" "Bun 运行时" OFF \
"docker" "Docker 容器引擎" ON \
"caddy" "Caddy Web 服务器" ON 3>&1 1>&2 2>&3)

# 检查用户是否取消了选择
if [ $? -ne 0 ]; then
    echo "❌ 用户取消了操作，脚本退出！"
    exit 1
fi

# 检查代理（如果选择安装 proxychains4）
if [[ $CHOICES == *"proxychains4"* ]]; then
    echo "📡 检查代理配置..."
    PROXY="socks5h://127.0.0.1:1080"
    if ! curl --silent --connect-timeout 5 -x "$PROXY" https://www.google.com > /dev/null; then
        echo "❌ 代理不可用，请检查代理配置！"
        exit 1
    fi
fi

# 安装 proxychains4
if [[ $CHOICES == *"proxychains4"* ]]; then
    echo "📦 检查并安装 proxychains4..."
    if ! command -v proxychains4 &> /dev/null; then
        echo "🔧 proxychains4 未安装，开始安装..."
        $PKG_UPDATE || { echo "❌ 更新包管理器失败！"; exit 1; }
        $PKG_INSTALL proxychains4 git || { echo "❌ 安装 proxychains4 失败！"; exit 1; }
        sed -i 's/^socks4.*$/socks5 127.0.0.1 1080/' /etc/proxychains4.conf || { echo "❌ 修改 proxychains4 配置失败！"; exit 1; }
    else
        echo "✅ proxychains4 已安装"
    fi
fi

# 安装 zsh
if [[ $CHOICES == *"zsh"* ]]; then
    echo "📦 检查并安装 zsh..."
    if ! command -v zsh &> /dev/null; then
        $PKG_UPDATE || { echo "❌ 更新包管理器失败！"; exit 1; }
        $PKG_INSTALL zsh || { echo "❌ 安装 zsh 失败！"; exit 1; }
    else
        echo "✅ zsh 已安装"
    fi
fi

# 安装 oh-my-zsh
if [[ $CHOICES == *"oh-my-zsh"* ]]; then
    echo "✨ 安装 oh-my-zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || { echo "❌ 安装 oh-my-zsh 失败！"; exit 1; }
        else
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || { echo "❌ 安装 oh-my-zsh 失败！"; exit 1; }
        fi
    else
        echo "✅ oh-my-zsh 已安装"
    fi
fi

# 安装 zsh 插件
if [[ $CHOICES == *"zsh-plugins"* ]]; then
    echo "🔌 安装 zsh 插件..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions || { echo "❌ 安装 zsh-autosuggestions 失败！"; exit 1; }
        else
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions || { echo "❌ 安装 zsh-autosuggestions 失败！"; exit 1; }
        fi
    fi
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting || { echo "❌ 安装 zsh-syntax-highlighting 失败！"; exit 1; }
        else
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting || { echo "❌ 安装 zsh-syntax-highlighting 失败！"; exit 1; }
        fi
    fi

    # 备份并下载 .zshrc 配置
    echo "📁 备份并下载 .zshrc 配置..."
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ZSHRC_URL="https://raw.githubusercontent.com/Takpap/takpap.github.io/refs/heads/master/read.md"
    if [[ $CHOICES == *"proxychains4"* ]]; then
        if proxychains4 curl --output /tmp/.zshrc -fsSL "$ZSHRC_URL"; then
            mv /tmp/.zshrc "$HOME/.zshrc"
        else
            echo "❌ 下载 .zshrc 失败，使用默认配置！"
            cp /etc/skel/.zshrc "$HOME/.zshrc" || exit 1
        fi
    else
        if curl --output /tmp/.zshrc -fsSL "$ZSHRC_URL"; then
            mv /tmp/.zshrc "$HOME/.zshrc"
        else
            echo "❌ 下载 .zshrc 失败，使用默认配置！"
            cp /etc/skel/.zshrc "$HOME/.zshrc" || exit 1
        fi
    fi
fi

# 安装 Node.js
if [[ $CHOICES == *"nodejs"* ]]; then
    echo "⬇️ 安装 Node.js（n）..."
    if ! command -v n &> /dev/null; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n || { echo "❌ 下载 n 失败！"; exit 1; }
        else
            curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n || { echo "❌ 下载 n 失败！"; exit 1; }
        fi
        install -m 0755 /tmp/n /usr/local/bin/n || { echo "❌ 安装 n 失败！"; exit 1; }
        n lts || { echo "❌ 安装 Node.js LTS 失败！"; exit 1; }
        n latest || { echo "❌ 安装 Node.js 最新版本失败！"; exit 1; }
    else
        echo "✅ n 已安装"
    fi
    echo "🔍 验证 Node.js 安装..."
    node --version || { echo "❌ Node.js 未正确安装！"; exit 1; }
    npm --version || { echo "❌ npm 未正确安装！"; exit 1; }
fi

# 安装 Bun
if [[ $CHOICES == *"bun"* ]]; then
    echo "🍞 安装 Bun..."
    if ! command -v bun &> /dev/null; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 curl -fsSL https://bun.sh/install | bash || { echo "❌ 安装 Bun 失败！"; exit 1; }
        else
            curl -fsSL https://bun.sh/install | bash || { echo "❌ 安装 Bun 失败！"; exit 1; }
        fi
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$HOME/.zshrc"
    else
        echo "✅ Bun 已安装"
    fi
    bun --version || { echo "❌ Bun 未正确安装！"; exit 1; }
fi

# 安装 Docker
if [[ $CHOICES == *"docker"* ]]; then
    echo "🐳 安装 Docker..."
    if ! command -v docker &> /dev/null; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 curl -fsSL https://get.docker.com -o /tmp/get-docker.sh || { echo "❌ 下载 Docker 安装脚本失败！"; exit 1; }
            proxychains4 sh /tmp/get-docker.sh || { echo "❌ 安装 Docker 失败！"; exit 1; }
        else
            curl -fsSL https://get.docker.com -o /tmp/get-docker.sh || { echo "❌ 下载 Docker 安装脚本失败！"; exit 1; }
            sh /tmp/get-docker.sh || { echo "❌ 安装 Docker 失败！"; exit 1; }
        fi
        systemctl enable docker && systemctl start docker || { echo "❌ Docker 服务启动失败！"; exit 1; }
    else
        echo "✅ Docker 已安装"
    fi
fi

# 安装 Caddy
if [[ $CHOICES == *"caddy"* ]]; then
    echo "🚀 安装 Caddy..."
    if ! command -v caddy &> /dev/null; then
        if [[ $CHOICES == *"proxychains4"* ]]; then
            proxychains4 curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg || { echo "❌ 下载 Caddy GPG 密钥失败！"; exit 1; }
            proxychains4 curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list || { echo "❌ 配置 Caddy 源失败！"; exit 1; }
        else
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg || { echo "❌ 下载 Caddy GPG 密钥失败！"; exit 1; }
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list || { echo "❌ 配置 Caddy 源失败！"; exit 1; }
        fi
        $PKG_UPDATE || { echo "❌ 更新包管理器失败！"; exit 1; }
        $PKG_INSTALL caddy || { echo "❌ 安装 Caddy 失败！"; exit 1; }
        systemctl enable caddy && systemctl start caddy || { echo "❌ Caddy 服务启动失败！"; exit 1; }
    else
        echo "✅ Caddy 已安装"
    fi
fi

# 设置默认 shell 为 zsh（如果选择了 zsh）
if [[ $CHOICES == *"zsh"* ]]; then
    echo "⚙️ 设置默认 shell 为 zsh..."
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh) || { echo "❌ 设置默认 shell 失败！"; exit 1; }
    fi
fi

echo "✅ 所有选择安装的组件已完成！请在新终端中运行 'zsh' 以应用配置。"

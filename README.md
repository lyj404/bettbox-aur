# bettbox-bin

基于 Mihomo（Clash.Meta 内核）的多平台代理客户端 Bettbox 的 AUR 包。

## 安装

使用 AUR 助手（如 yay、paru）安装：

```bash
yay -S bettbox-bin
# 或
paru -S bettbox-bin
```

手动安装：

```bash
git clone https://aur.archlinux.org/bettbox-bin.git
cd bettbox-bin
makepkg -si
```

## 常见问题

### 安装失败：缺少 libkeybinder3 依赖

如果安装时提示缺少 `libkeybinder3` 依赖，可以尝试以下方法：

**方法 1：更新 pacman 数据库**
```bash
sudo pacman -Syu
```

**方法 2：手动安装依赖**
```bash
sudo pacman -S libkeybinder3
```

## 链接

- [上游项目](https://github.com/appshubcc/Bettbox)
- [AUR 页面](https://aur.archlinux.org/packages/bettbox-bin)

## 许可证

本项目（AUR 打包脚本）基于 [Apache License 2.0](LICENSE) 许可。

注意：被打包的 Bettbox 软件本身基于 [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.html) 许可。

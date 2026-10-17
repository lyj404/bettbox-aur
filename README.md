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

### TUN 模式的权限机制（v1.19.5 起）

自 v1.19.5 起，Bettbox 弃用 setuid，改为 setcap + polkit 规则提权：

- 安装/升级时由 [bettbox.install](bettbox.install) 为 `BettboxCore` 设置文件 capabilities（`cap_net_admin,cap_net_bind_service,cap_net_raw`），`setcap` 由 `libcap` 提供；
- polkit 规则作为**包内容**安装到 `/usr/share/polkit-1/rules.d/`，用于开启 TUN 后免密调用 `resolvectl` 修改系统 DNS；需要 `polkit`（可选依赖），未安装时无法使用系统 DNS 授权功能；
- 规则不通过安装脚本动态写入 polkit 的 `rules.d`——脚本写入的文件不进包清单，属于"无主"文件，`pacman -Qkk`、校验工具均不可见，绕过卸载路径时会残留一条免密规则。上游已通过 [PR #539](https://github.com/appshubcc/Bettbox/pull/539) 修复同类问题：自 v1.19.6 起 deb 自带 `90-bettbox.rules`（仅放行 4 个 `org.freedesktop.resolve1.*` action），本包直接从 deb 内取出安装，不再维护仓库副本。

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

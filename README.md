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

### 上游撤回版本时如何回退 AUR 包

自动更新每 6 小时检查 AUR 当前版本的 release 和两个架构的 deb；缺失资产、缺少 SHA-256 或上游候选版本低于 AUR 时，任务会失败并在 Actions 摘要中提示，不会自动回退。GitHub API 或 AUR 查询失败也会停止任务；失败通知取决于仓库和账号的 GitHub 通知设置。

确认上游撤包且需要回退后，在仓库 **Actions → 手动回退 AUR 版本 → Run workflow** 中选择 `main`，填写目标版本（如 `1.19.7`）和 AUR 页面上的当前完整版本（如 `1.19.8-2`，有 epoch 时包含 `1:`），然后运行。启动工作流即表示维护者已确认回退。若无可用旧版双架构 deb，不能使用该流程。

工作流会重新检查版本与 AUR 漂移，下载并校验两个 deb，在 Arch 容器内用当前 `package()` 检查它们的布局，再递增 epoch、更新版本和校验和、生成 `.SRCINFO`，依次推送 AUR 和 GitHub。旧版即使通过布局检查，也仍需维护者核实其功能及是否适合回退。用户需要通过 AUR 助手检查更新并安装，才会收到回退版本。

如果 AUR 推送成功而 GitHub 推送失败，先核对两边状态，再用 **Manual AUR sync** 的 `aur-to-github` 方向同步，或人工处理漂移；不要重复执行回退。需要配置现有的 `AUR_SSH_KEY`、`AUR_USERNAME` secrets，并允许 Actions 写入仓库。

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

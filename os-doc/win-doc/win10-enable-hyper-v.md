# 启用 Hyper-V 以在 Windows 10 上创建虚拟机。

## 检查要求
Windows 10 企业版、专业版或教育版
具有二级地址转换 (SLAT) 的 64 位处理器。
CPU 支持 VM 监视器模式扩展（Intel CPU 上的 VT-c）。
最小 4 GB 内存。

使用 PowerShell 启用 Hyper-V

以管理员身份打开 PowerShell 控制台。
运行以下命令：

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# 使用 CMD 和 DISM 启用 Hyper-V

DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V

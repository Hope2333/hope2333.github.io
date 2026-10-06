---
title: "更新指引"
lang: zh-TW
---

> [!NOTE]
> **說明**：本頁內容由簡體中文原文機械轉換為繁體（字級變體轉換，非翻譯）。簡體原文：[/wiki/guides/update](/zh_CN/wiki/guides/update.md)；根路徑 canonical：[/wiki/guides/update](/wiki/guides/update.md)。站點已完整中譯的內容從 [繁體 wiki 索引](/zh_TW/wiki/opencode-termux/) 進入。

# 更新指引

## 日常更新

pacman 客戶端：

```sh
pacman -Syu
```

apt 客戶端：

```sh
apt update && apt upgrade
```

`apt upgrade` 會連帶升級 hope2333-mirrorlist（源列表隨包更新）；pacman 客戶端同理。建議定期執行，保持軟件包爲最新版本。

## 版本發佈機制

各倉以 Push tag 形式發佈（如 Push260906），`releases/latest/download` 始終指向最新正式批次；統一源與頁面包由 site-rebuild 流程在發版後自動同步。因此無需關心 tag 名稱，`pacman -Syu` / `apt upgrade` 拉到的就是當前最新構建。

## 源同步

軟件源內容由 site-rebuild 流程觸發同步，倉庫更新後會自動反映到源中。

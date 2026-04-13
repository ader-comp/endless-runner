# Web Export 與 GitHub Pages 部署

> 目的：讓內部測試者打開瀏覽器網址就能玩到最新版本，每次 push 到 master 自動更新。

---

## 整體流程

```
本機 Godot 編輯器                  GitHub
─────────────────                ──────────────────────────────
push to master  ─────────────►  Actions 觸發
                                 │
                                 ├─ 下載 Godot ${GODOT_VERSION}
                                 ├─ 下載 export templates
                                 ├─ godot --headless --import
                                 ├─ godot --headless --export-release "Web" ...
                                 └─ 上傳 build/web → Pages
                                              │
                                              ▼
                            https://<user>.github.io/endless-runner/
```

---

## 一次性設定（首次部署前必做）

### 1. 啟用 GitHub Pages 並選 Actions 為 source

1. 進 GitHub repo → **Settings** → **Pages**
2. **Source** 選 `GitHub Actions`（**不是** `Deploy from a branch`）
3. 不需要選 branch，Actions 會用 artifact 的方式部署

### 2. 對齊 Godot 版本

`.github/workflows/deploy-web.yml` 目前固定為：

```yaml
env:
  GODOT_VERSION: "4.6.2"
```

對應本機 `Editor → Help → About` 顯示的 4.6.2-stable。**版本必須與本機完全一致**，否則 export 可能失敗或產生與本機不同的結果。本機升 / 降 Godot 版本時記得回來改這裡。

### 3. 確認 export templates 可下載

工作流程從 Godot GitHub Releases 下載 templates：
```
https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz
```

如果該版本不存在，CI 會在 Install Export Templates 步驟失敗。可以先進這個 URL 確認對應版本檔案存在。

---

## 為什麼不需要 COOP / COEP headers

GitHub Pages **不允許設定自訂 HTTP headers**。Godot 4 過去的 Web export 需要 `SharedArrayBuffer`，而 SAB 需要：

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

→ 這在 GitHub Pages 上做不到。

**解法**：`export_presets.cfg` 中設定 `variant/thread_support=false`。Godot 4.3+ 支援單執行緒 Web build，**完全不需要 SharedArrayBuffer**，可以直接放任何靜態主機（GitHub Pages / Netlify / Cloudflare Pages 都行）。

代價：遊戲跑在單執行緒上，物理與腳本不會被並行化。對這個 endless runner 等級的遊戲完全無感。

> 如果未來改用 Cloudflare Pages 或 Netlify，可以把 `thread_support=true` 開回來，並用 `_headers` 檔設定 COOP/COEP，效能會更好。

---

## 本機驗證 export

在本機開 Godot Editor → Project → Export → 應該會看到一個叫 `Web` 的 preset（從 `export_presets.cfg` 載入）。

第一次需要：
1. **Manage Export Templates** → Download（如果還沒下載過）
2. 點 `Web` preset → **Export Project**
3. 輸出路徑 `build/web/index.html`

本機測試（不能直接 file:// 開）：
```bash
# 用 Python 起 HTTP server
cd build/web && python -m http.server 8080
# 開瀏覽器 http://localhost:8080
```

因為 `thread_support=false`，本機 Python server 也不需要設 COOP/COEP，直接開就能跑。

---

## 觸發部署

| 方式 | 怎麼做 |
|---|---|
| 自動 | 任何 push 到 `master` 分支 |
| 手動 | GitHub repo → Actions → `Deploy Web Build to GitHub Pages` → Run workflow |

部署完成後，網址是：

```
https://<github-username>.github.io/endless-runner/
```

第一次部署可能要 1~2 分鐘 Pages 才會把 DNS 與內容準備好，之後每次更新 30 秒內就生效。

---

## 常見問題排查

### CI 卡在 "Install Godot"
- 檢查 `GODOT_VERSION` 是不是有對應的 Linux 64-bit release
- 進 https://github.com/godotengine/godot/releases 看版本是否存在

### Export 步驟失敗，看到 `ERROR: Project file not found`
- 通常是 `--import` 步驟沒跑完。我們已經加了 `godot --headless --import || true` 預先匯入

### 部署成功但網頁打開白屏
- 開 DevTools Console，看是否有 SharedArrayBuffer 相關錯誤
  - 如果有 → `export_presets.cfg` 的 `thread_support` 沒設成 `false`
- 如果有 404 找不到 `.wasm` / `.pck` → 可能是 GitHub Pages 還在 propagate，等 1 分鐘再試

### 本機 Editor 打開後 export_presets.cfg 被改動
- Godot 編輯器在開啟時會用最新格式重寫這個檔
- 如果 diff 只是順序、空白、補上預設欄位，正常 commit 即可
- 如果有實質設定變更（路徑、thread_support 等），確認沒有不小心改錯

### 想暫時關掉自動部署
- 註解掉 `.github/workflows/deploy-web.yml` 的 `on.push` 區塊
- 或在 GitHub Actions 頁面 Disable workflow

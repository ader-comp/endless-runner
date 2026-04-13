# GitHub Pages 部署 — Owner / Admin 設定指南

> **TL;DR**：請幫我打開這個 repo 的 GitHub Pages 並把 deployment source 設成 `GitHub Actions`。整個流程只需要 owner / admin 點幾下，**不需要寫任何程式或檔案**。下面是逐步說明。

---

## 背景

我們想讓內部測試者打開瀏覽器網址就能玩到最新版本的遊戲。

- 程式碼端：CI workflow（`.github/workflows/deploy-web.yml`）已經寫好，每次 push 到 `master` 會自動用 Godot 把遊戲 export 成 Web build
- 部署端：缺一個 owner / admin 才有權限做的設定 — **啟用 GitHub Pages 並讓它接受來自 Actions 的部署**

---

## 你需要做的事（共 2 項）

### ✅ 1. 啟用 GitHub Pages 並設定 Source

1. 進入 **這個 repo** 的頁面（不是個人帳號設定）
2. 點擊 repo 頁面上方橫向 tab 的最右邊：**`Settings`**
   - 如果看不到 Settings tab，代表你目前的角色不是 admin 以上
3. 左側 sidebar → `Code and automation` 區段 → **`Pages`**
4. 在 **Build and deployment** 區塊：
   - **Source** 下拉選單 → 選 **`GitHub Actions`**
   - **不要選** `Deploy from a branch`，那是舊的方式且不適用我們的 workflow
5. 選完之後不需要按 Save，GitHub 會自動套用

完成後畫面會顯示一段灰色提示：
> *GitHub Pages is currently disabled. Configure your workflow file to enable Pages...*

這是正常的 — 因為還沒跑過第一次部署，下面第 2 步做完之後再 push 一次就會變成可用狀態。

---

### ✅ 2. 確認 Actions 權限沒被鎖死

預設情況下不需要動，但保險起見確認一下：

1. 同樣在 repo 的 **`Settings`**
2. 左側 sidebar → `Code and automation` → **`Actions`** → **`General`**
3. **Actions permissions** 區塊：
   - 確認是 **`Allow all actions and reusable workflows`**（或至少是 `Allow ... actions and reusable workflows`，能讓我們的 workflow 跑）
4. **Workflow permissions** 區塊（往下捲）：
   - 預設是 `Read repository contents and packages permissions` — **這樣就夠了**
   - 我們的 workflow 在 YAML 內部已經透過 `permissions:` 區塊自己申請 `pages: write` 與 `id-token: write`，不需要在這邊改成 read/write

---

## 完成後會發生什麼

1. 我（或下次有人 push 到 master 的協作者）一旦推送 commit，**Actions 會自動觸發**
2. Actions tab 會看到一個叫 `Deploy Web Build to GitHub Pages` 的工作流程開始跑
3. 流程會：下載 Godot CLI → 下載 export templates → 把專案 export 成 Web build → 上傳 → 部署到 Pages
4. 部署成功後，Pages 設定頁面會顯示遊戲網址，類似：
   ```
   https://<owner-username>.github.io/endless-runner/
   ```
5. 任何人打開這個網址就能在瀏覽器裡玩遊戲

第一次部署完整流程約 1~2 分鐘，之後每次更新約 30 秒~1 分鐘。

---

## 常見疑問

### 這會不會花錢？
不會。GitHub Pages 對 public repo 完全免費，Actions 對 public repo 也有免費額度（這個 workflow 一次跑大約消耗 1~2 分鐘 runner 時間，遠低於免費額度）。

### 部署的內容會公開到網路上嗎？
**會**，這是 GitHub Pages 的本質 — 任何知道網址的人都能存取。如果之後需要限制存取，要改用其他方案（例如 Cloudflare Pages + Access、自架靜態主機 + 密碼）。

### 之後想關掉怎麼辦？
1. 同樣到 Settings → Pages，把 Source 改回 `None`
2. 或者直接到 Settings → Actions → 把 `Deploy Web Build to GitHub Pages` workflow disable

### 需要建立 `gh-pages` branch 嗎？
**不需要**。新版的 Pages 用 Actions artifact 直接部署，不再用 branch。整個 repo 不會多出任何分支或 commit。

### 會動到 master branch 嗎？
**不會**。Workflow 只會「讀取」master 的內容做 build，不會 commit 或 push 任何東西回 repo。

### 安全性如何？
- Workflow 用的是 GitHub 自己提供的 `actions/deploy-pages@v4` 與 `actions/upload-pages-artifact@v3`
- Workflow 只下載 Godot 官方 release（從 `github.com/godotengine/godot/releases`）
- 沒有引入任何第三方 marketplace action
- 沒有需要設定 secret，整個流程用內建的 `GITHUB_TOKEN`

---

## 設定完成後請通知我

設定好之後麻煩告知一聲（或在 repo 開個 issue / 在群組 ping 我），我會 push 一個 commit 觸發第一次部署，並把實際遊戲網址回報給大家。

如果上面任何步驟卡住，截圖給我，我幫你看。

---

## 附錄：相關檔案位置

| 檔案 | 用途 |
|---|---|
| `.github/workflows/deploy-web.yml` | CI 工作流程定義 |
| `export_presets.cfg` | Godot Web export 設定（已配置成相容 GitHub Pages） |
| `docs/web-deploy.md` | 開發者面向的詳細部署文件（你不需要看） |

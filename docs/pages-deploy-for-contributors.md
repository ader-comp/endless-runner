# GitHub Pages 部署 — 協作開發者指南

> 這份文件給**在自己 branch 上開發、想把當前版本部署到 GitHub Pages 測試**的工程師。
>
> 如果你只想把東西合進 master 並讓 master 自動部署,那不需要看這份,push/merge 到 master 就會自動觸發。
>
> 相關文件:
> - `docs/web-deploy.md` — Godot Web export 的技術細節、版本對齊、踩坑排查
> - `docs/owner-pages-setup.md` — Repo owner 首次啟用 Pages 的一次性設定

---

## 運作原理

```
你的 branch
  │
  │  git push
  ▼
GitHub Actions (.github/workflows/deploy-web.yml)
  │
  ├─ 下載 Godot CLI + export templates
  ├─ godot --headless --import
  ├─ godot --headless --export-release "Web"
  └─ 上傳 build/web artifact
         │
         ▼
   github-pages environment
   (有分支白名單保護)
         │
         ▼
   https://<owner>.github.io/endless-runner/
```

兩道「關卡」決定你的 branch 能不能部署:

1. **Workflow trigger**(在 `deploy-web.yml`):哪些 branch 被 push 時會觸發 workflow
2. **Environment protection rule**(在 repo Settings):哪些 branch 實際被允許把 artifact 部署到 Pages

兩道都放行,才會部署成功。只放行第 1 道會 build 成功、deploy 失敗(error: `Branch "xxx" is not allowed to deploy to github-pages due to environment protection rules`)。

---

## ⚠️ 重要前提:Pages 只有一份線上版本

GitHub Pages 對整個 repo **只有一個 URL**(`https://<owner>.github.io/endless-runner/`)。

- 不同 branch 部署會**互相覆蓋** — 最後成功跑完的 workflow 勝出
- 想同時保留多人各自的版本,GitHub Pages 做不到,需要另外用 Cloudflare Pages / Netlify 的 preview deployments
- 建議:跟團隊協調「這個網址目前給誰測」,或改合進 master 再部署

如果你只是想在自己機器快速預覽,其實**不一定要部署** — 本機用 Python HTTP server 跑 Godot Web export 會更快(見 `docs/web-deploy.md` 的「本機驗證 export」)。

---

## 要自己的 branch 也能部署,你需要做這兩件事

### 1. 把你的 branch 加進 workflow trigger

編輯 `.github/workflows/deploy-web.yml`:

```yaml
on:
  push:
    branches: [master, feature/billy/dev]   # ← 在這裡加你的 branch
  workflow_dispatch:
```

Commit + push 到你的 branch。

> 小技巧:可以用 pattern 例如 `feature/alice/*` 一次涵蓋你自己所有 feature branch。

### 2. 請 owner / admin 把你的 branch 加進 environment 白名單

這步**你自己做不了**,需要有 admin 權限的人操作(通常是 repo owner):

1. Repo → **Settings** → 左側 sidebar **Environments**
2. 點列表中的 **`github-pages`**
3. **Deployment branches and tags** 區塊:
   - 下拉選 **`Selected branches and tags`**
   - 點 **`Add deployment branch or tag rule`**
   - 輸入你的 branch 名稱(例如 `feature/alice/dev`),或 pattern 如 `feature/alice/*`
   - 儲存

如果 owner 懶得一個個加,可以改成 `All branches`(較寬鬆,任何 branch 都能部署)。

### 3. 觸發部署

再 push 一次到你的 branch,或到 **Actions** tab → 選 `Deploy Web Build to GitHub Pages` → **Run workflow** → 選你的 branch → Run。

部署完成後到 `https://<owner>.github.io/endless-runner/` 看結果。

---

## 排查:workflow 跑到一半失敗

### Deploy 步驟紅字:`Branch "xxx" is not allowed to deploy to github-pages`

→ 上面第 2 步沒做,請 admin 加進 environment 白名單。

Build 本身已經成功,加完白名單後**不用重 push**,到 Actions tab 找那筆失敗的 run → 右上 **Re-run failed jobs** 就行(只會重跑 deploy 步驟,約 10 秒)。

### Build(Export Web Build)步驟就失敗

跟 branch 保護無關,通常是 Godot 版本或專案設定問題。排查步驟見 `docs/web-deploy.md` 的「常見問題排查」。

### Workflow 根本沒被觸發

- 確認你的 branch 名稱有加進 `deploy-web.yml` 的 `on.push.branches`
- 確認 push 成功(`git push` 沒錯誤訊息)
- 到 repo → Actions tab 看是否有任何 run 記錄

### Node.js 20 deprecation 黃色警告

可以忽略。`actions/checkout@v4` 等會在 2026/6 後強制升 Node 24,屆時更新 action 版本即可。

---

## 部署完怎麼還原給別人測?

你 branch 的版本會一直掛在線上,直到下次有人(包含 master 的自動部署)觸發新的 workflow。

- 想把測試網址「還給 master」:到 Actions tab 手動 Run workflow,branch 選 `master`
- 或直接等下一次有人 push 到 master

---

## 小結:checklist

自己 branch 要部署,依序確認:

- [ ] `.github/workflows/deploy-web.yml` 的 `branches` 有你的 branch
- [ ] `github-pages` environment 白名單有你的 branch(請 admin 加)
- [ ] 跟團隊確認這個時段 Pages URL 給你用
- [ ] Push 或手動 Run workflow
- [ ] Actions 跑綠後開 URL 驗證

有任何步驟卡住,截圖 + 貼 Actions log 到群組。

# ETtodayTest

## iTunes Search API 使用說明

### API 規範

### URL
[https://itunes.apple.com/search](https://itunes.apple.com/search)

### 方法
`GET`

### 參數
- `term` (必填): 搜索的關鍵字。例如 `term=jason+mars`

### 回傳參數
`SearchResult`
- `resultCount`: Int
- `results`: [Track]

`Track`
- `trackName`: String?
- `trackTimeMillis`: Int?
- `longDescriptio`n: String?
- `artworkUrl100`: URL?
- `previewUrl`: URL?

### 範例請求
GET https://itunes.apple.com/search?term=jason+mars

## 功能敘述

### 搜索並顯示結果
根據使用者輸入的關鍵字進行搜索 API，Search bar 每輸入一個字都需顯示搜索結果。

### UI 設計
使用 `UICollectionView` 顯示搜索結果。

### Cell 顯示內容
`artworkUrl100` 圖片
`trackName`，最多顯示兩行
`trackTimeMillis`
`longDescription`

### 動態調整
如果 API 回應有 `longDescription`，需根據內容動態調整高度顯示完整文字。

### 播放和暫停音樂預覽
點擊 Cell 可播放/暫停 `previewUrl`，顯示「播放/暫停」的狀態，讓使用者區別正在播放的音訊。

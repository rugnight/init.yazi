-- ブックマーク（yamb プラグイン）の定義。
-- yazi 本体の中では `bb` で一覧（割当キーで飛ぶ）、`B` で fzf 検索。
-- 実行中に `<C-b>` で足したものは config/bookmark に保存され、ここの定義と合流する。
-- キーは重複させない（重複すると後から来た方が一覧に出ない）。
--   小文字 = 場所、大文字 = ドライブ、で住み分けている。
local bookmarks = {}

local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == "windows" and os.getenv("USERPROFILE") or os.getenv("HOME")

if ya.target_family() == "windows" then
  -- ドライブ。Windows では `h`（親へ）がドライブの根で止まり、ドライブをまたげない。
  -- ここに置いて `bb` → 大文字のドライブ文字 で飛べるようにしている。
  -- 一覧の作り直し: PowerShell で
  --   Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, DriveType, VolumeName
  -- （DriveType 3 = ローカル, 4 = ネットワーク。この PC は 2026-11-03 時点で C/D/E/Z）
  -- ここに無いドライブへは yazi の中で `g<Space>` から `D:\` のように直接打てば行ける。
  local drives = {
    { tag = "C: Windows", key = "C", path = "C:\\" },
    { tag = "D:",         key = "D", path = "D:\\" },
    { tag = "E:",         key = "E", path = "E:\\" },
    { tag = "Z: home",    key = "Z", path = "Z:\\" },
  }
  for _, drive in ipairs(drives) do
    table.insert(bookmarks, drive)
  end

  table.insert(bookmarks, {
    tag = "Scoop Local",
    path = (os.getenv("SCOOP") or home_path .. "\\scoop") .. "\\",
    key = "p",
  })
  table.insert(bookmarks, {
    tag = "Scoop Global",
    path = (os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop") .. "\\",
    key = "P",
  })
end

table.insert(bookmarks, {
  tag = "Desktop",
  path = home_path .. path_sep .. "Desktop" .. path_sep,
  key = "d",
})

-- この設定ディレクトリ自身（= init.yazi リポジトリ）。
-- 以前は実行中に `<C-b>` で足して config/bookmark に入れていたが、
-- あのファイルは git 管理外（マシンごとの状態）なので、ここに移した。
local config_dir = ya.target_family() == "windows" and (os.getenv("APPDATA") .. "\\yazi\\")
  or (home_path .. "/.config/yazi/")
table.insert(bookmarks, {
  tag = "yazi",
  path = config_dir,
  key = "y",
})

require("yamb"):setup {
  -- 末尾が区切り文字のパスはフォルダとして扱われる
  bookmarks = bookmarks,
  -- 飛んだときに通知を出す
  jump_notify = true,
  -- fzf の実行ファイル名
  cli = "fzf",
  -- `<C-b>` で足したブックマークに自動で割り当てるキーの候補（先頭が優先）
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  -- ブックマークの保存先
  path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
      (os.getenv("HOME") .. "/.config/yazi/bookmark"),
}

#!/bin/bash
# 個人用 OTel ヘッダーヘルパー
# newmo 1Password アカウントの UUID を直接指定（my.1password.com に複数アカウントがあるため）
echo "{\"dd-api-key\": \"$(op read --account=VNNXXZ6U4FDCFPPCQKGVKDSR4A 'op://Dev/Claude Code Dashboard/API Key')\"}"

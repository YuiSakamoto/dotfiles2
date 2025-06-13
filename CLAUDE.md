# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
英語で考えて日本語で返答して

## Repository Overview

This is a dotfiles repository containing personal configuration files for various development tools and environments. The repository uses symlinks to set up configurations in the appropriate locations on the system.

## Setup Commands

### Initial Setup

```bash
# Run the setup script to create symlinks
./setup.sh
```

This script will:

- Create symlinks for `.gitconfig`, `.gitignore`, and `.tmux.conf` in `$HOME`
- Create symlinks for `fish`, `nvim`, `karabiner`, `wezterm`, and `starship.toml` in `$HOME/.config/`
- Create symlinks for bin utilities (like `ssm`) in `/usr/local/bin/`

### Fish Shell

The repository uses Fish shell with various plugins and configurations:

- Custom aliases defined in `fish/conf.d/alias.fish`
- Path configurations in `fish/conf.d/path.fish`
- Theme: bobthefish with powerline fonts
- Key bindings: `Ctrl+R` for history search with peco

### Development Environment

- **Editor**: Neovim (aliased as `vi` and `v`)
- **Git**: Extensive git aliases configured in `.gitconfig`
- **Container tools**: Docker and docker-compose (aliased as `d` and `dc`)
- **Cloud tools**: kubectl (aliased as `k`), gcloud (aliased as `gcl`)
- **Infrastructure**: Terraform (aliased as `tf`)

## Architecture

The repository structure follows a modular approach:

- Each tool's configuration is contained in its own directory
- Fish shell configurations are split into multiple files under `conf.d/` for organization
- Neovim uses dein.vim for plugin management with configurations in TOML files
- Karabiner configurations for macOS keyboard customization
- WezTerm configuration for terminal emulator

## Important Notes from .cursorrules

- **技術スタックのバージョンは変更せず、必要があれば必ず承認を得る**
- **UI/UX デザインの変更（レイアウト、色、フォント、間隔など）は禁止**
- 重複実装の防止: 既存の類似機能や同名の関数・コンポーネントを確認する
- 明示的に指示されていない変更は行わない

## Git Workflow

The repository includes extensive git aliases for common operations:

- `g s` or `gs`: git status
- `g po`: push to origin
- `g up`: pull with rebase
- `g rbm`: rebase on master
- `g dmb`: delete merged branches
- See `.gitconfig` for the complete list of aliases

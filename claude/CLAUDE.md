# CLAUDE.md

This file provides comprehensive guidance to Claude Code (claude.ai/code) for maximum effectiveness across all development projects.

## 🎯 Core Context

### Who I Am

- **開発者**: Yui Sakamoto (YuiSakamoto)
- **作業スタイル**: 効率重視、自動化好き、最新技術に関心あり
- **言語**: 日本語でのコミュニケーション OK、コミットメッセージも日本語可

### Development Environment

- **Primary Shell**: Fish shell (`/opt/homebrew/bin/fish`) with custom aliases
- **Editor**: Neovim (aliased as `vi` and `v`)
- **Package Manager**: pnpm (JavaScript/TypeScript), Go modules, CocoaPods (iOS)
- **Version Manager**: fnm for Node.js
- **OS**: macOS (Darwin 24.5.0)

## 🧠 Thinking Strategy

### Complex Problem Approach

When facing complex tasks:

1. **Break it down**: Divide into smaller, manageable sub-tasks
2. **Research first**: Use Task tool to search for existing patterns/solutions
3. **Plan thoroughly**: Use TodoWrite to track all steps
4. **Iterate**: Don't try to solve everything at once
5. **Verify**: Always run tests/lints after changes

### Ultra-thinking Triggers

Enable detailed thinking for:

- Architecture decisions
- Performance optimizations
- Security implementations
- Complex refactoring
- API design

## 📋 Task Management Rules

### TodoWrite Usage

**ALWAYS** use TodoWrite when:

- Task involves 3+ steps
- Multiple files need modification
- Complex feature implementation
- Bug fixing with unknown scope
- Any non-trivial task

### Task Execution Pattern

```
1. Analyze & Plan → TodoWrite
2. Research → Task/Grep/Glob
3. Implement → Edit/MultiEdit
4. Verify → Bash (tests/lint)
5. Complete → Mark todo as done
```

## 🛠 Technical Specifications

### JavaScript/TypeScript Projects

- **Always use pnpm**, never npm or yarn
- **Monorepo**: Use `pnpm --filter` for package-specific commands
- **Common commands**:
  ```bash
  pnpm dev          # Start dev server
  pnpm build        # Build project
  pnpm test         # Run tests
  pnpm lint         # Run linter
  pnpm typecheck    # Type checking
  ```

### Git Workflow

```bash
# Feature development
git checkout -b feature/description
# Work on feature...
git add -A
git commit -m "実装内容を日本語で記述"
git push -u origin feature/description
# Create PR via GitHub
```

### Go Development

- Module-based development
- Always run `go mod tidy` after adding dependencies
- Test with `go test ./...`
- Build with proper tags: `go build -tags production`

## 🚨 Critical Constraints

### NEVER Change Without Permission

1. **Version updates** of any dependency
2. **UI/UX changes** (layout, colors, fonts, spacing)
3. **Project structure** reorganization
4. **Build tool** switches
5. **Framework migrations**

### Security Rules

- **NEVER** commit secrets, keys, or tokens
- Always use environment variables for sensitive data
- Check `.gitignore` before committing
- Use `~/.config/claude/settings.json` permissions

## 🎨 Code Style Preferences

### General

- Clean, readable code over clever one-liners
- Meaningful variable/function names
- Consistent formatting (use project's prettier/eslint)
- Comments only when truly necessary

### TypeScript Specific

```typescript
// ✅ Good
export const calculateTotal = (items: Item[]): number => {
  return items.reduce((sum, item) => sum + item.price, 0);
};

// ❌ Avoid
export const calc = (i: any[]) => i.reduce((s, x) => s + x.p, 0);
```

## 🔧 Common Patterns & Solutions

### File Search Strategy

```bash
# 1. Quick search for files
Glob("**/*.ts")

# 2. Search for content
Grep("pattern", "*.tsx")

# 3. Complex searches
Task("Search for all API endpoints and their usage")
```

### Error Handling Pattern

1. Check logs first: `pnpm dev` output
2. Search for similar errors in codebase
3. Verify dependencies: `pnpm list`
4. Check TypeScript errors: `pnpm typecheck`

## 🎵 Feedback Signals

### Success Notification

```bash
afplay /System/Library/Sounds/Glass.aiff
```

### Error/Attention Needed

```bash
afplay /System/Library/Sounds/Sosumi.aiff
```

### Approval Request Notification

承認が必要な場合は必ず音を鳴らしてください：
```bash
afplay /System/Library/Sounds/Hero.aiff
```

**承認を求める前に必ず実行**:
- バージョンアップデートの確認時
- 破壊的な変更の前
- 重要な設計判断時
- セキュリティ関連の変更時

## 🚀 Performance Tips

### For Claude Code

1. **Batch operations**: Multiple tool calls in one message
2. **Specific searches**: Use exact patterns in Grep/Glob
3. **Clear instructions**: Be explicit about expectations
4. **Context windows**: Start new threads with `/clear` when switching contexts

### Development Workflow

1. **Hot reload**: Keep `pnpm dev` running
2. **Parallel tasks**: Use `pnpm --parallel` for multiple packages
3. **Cache usage**: Leverage pnpm's cache system
4. **Incremental builds**: Use turbo for monorepos

## 📚 Quick Reference

### Essential Aliases

```bash
g      → git
k      → kubectl
d      → docker
dc     → docker-compose
tf     → terraform
v      → nvim
ij     → open IntelliJ IDEA
claude → プロジェクト単位で管理されたClaude Code（自動継続機能付き）
```

You can know more from `~/.config/fish/conf.d/alias.fish`

### Project Locations

```bash
~/src/                    # All git repositories (via ghq)
~/.config/               # Configuration files
~/dotfiles2/             # This dotfiles repo
```

### Emergency Commands

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~

# Fix permissions
chmod 755 file

# Kill process on port
lsof -ti:3000 | xargs kill -9

# Clear pnpm cache
pnpm store prune
```

## 🎯 Meta Instructions

### How to Use This File

1. **Reference frequently**: Check when starting new tasks
2. **Update regularly**: Add new patterns as discovered
3. **Share context**: Include relevant sections in prompts
4. **Evolve**: This is a living document

### When Stuck

1. Re-read the task requirements
2. Check this CLAUDE.md for patterns
3. Search existing code for examples
4. Ask for clarification before assuming

### TypeScript Tips

- 極力letは使わない！
- errorは極力throwせずにresult型を作ってreturnする
- pnpm -w run lint && pnpm typecheck && pnpm buildは必ず通るようにして。

Remember: "The more context you can give Claude, the more effective it'll be"

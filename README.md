# SAP Agent Skill (`sap-dev`)

Autonomous AI Agent Skill connecting modern AI IDEs and agents (Google Antigravity, Cursor, Windsurf, Claude Code) directly to SAP ABAP systems via the Model Context Protocol (MCP).

---

## 📦 Distribution & Releases

The `sap-dev` AI Skill is distributed as pre-packaged release archives published on GitHub Releases:

👉 **[Download the Latest Release from GitHub Releases](https://github.com/stud0709/sap-dev-release/releases)**

Each release contains the complete autonomous skill bundle, including cross-compiled binaries (`sap-bridge` for Windows, Linux, and macOS Intel / Apple Silicon), full reference guides, ATC remediation protocols, and developer manuals.

---

## 🚀 Installation & Setup

1. **Download Archive**: Download `sap-dev-v<version>.zip` from the latest [GitHub Release](https://github.com/stud0709/sap-dev-release/releases).
2. **Extract into Workspace**: Extract the archive directly into your project's `.agents/skills/` directory:
   ```text
   your-project/
   └── .agents/
       └── skills/
           └── sap-dev/
               ├── SKILL.md
               ├── bin/
               │   ├── sap-bridge.exe
               │   ├── sap-bridge
               │   ├── sap-bridge-darwin-arm64
               │   └── sap-bridge-darwin-amd64
               └── references/
   ```
3. **Configure & Launch**:
   - Follow the step-by-step setup and connection guide in the [Project Wiki](https://github.com/stud0709/sap-dev-release/wiki).
   - Configure your target SAP landscape credentials in the local web dashboard.

---

## 📚 Documentation & Resources

- 📖 **Documentation & Guides**: Visit the official [sap-dev-release Wiki](https://github.com/stud0709/sap-dev-release/wiki) for setup instructions, MCP tool references, permissions, and architecture overviews.
- 💬 **Community & Support**: Join the conversation on the [Discord Community](https://discord.gg/6EaVkJ9D) or file issue reports on [GitHub Issues](https://github.com/stud0709/sap-dev/issues).

---

## ⚠️ Important Notice

This toolset provides capabilities to inspect, generate, and activate source code in connected SAP systems. While the dashboard offers isolated version control and guard rails for agent actions, **always thoroughly review generated code and agent activities before productive transport.**

---

## 📄 License

This software is licensed under the terms described in [LICENSE.md](LICENSE.md).

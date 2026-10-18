# SAP Agent Skill (`sap-dev`)

**Give your AI coding agent the tools to work inside SAP.**

`sap-dev` connects your AI IDE to live SAP ABAP systems, enabling your agent to explore existing code, implement changes, validate them with SAP's own compiler, run tests, and investigate runtime behavior. It combines SAP tooling with workflow guidance and a dashboard where you control the agent's permissions.

Connect modern AI IDEs and agents such as Google Antigravity, Cursor, Windsurf, and Claude Code through the Model Context Protocol (MCP).

## What can your agent do?

- **Understand your SAP system:** Search source code, trace dependencies and where-used references, and explore DDIC objects, enhancements, and OData services. [Explore capabilities](https://github.com/stud0709/sap-dev-release/wiki/Explorative-Tools)
- **Develop with real SAP feedback:** Fetch, edit, syntax-check, push, and activate ABAP objects; run ABAP Unit tests and review version differences. [Development workflow](https://github.com/stud0709/sap-dev-release/wiki/Code-Editing)
- **Investigate runtime problems:** Set breakpoints, step through execution, inspect variables, and capture request traces. [Debugging](https://github.com/stud0709/sap-dev-release/wiki/Debugging)
- **Work through ATC findings:** Give the agent an imported ATC run to investigate and remediate, with progress visible in the dashboard. [ATC remediation](https://github.com/stud0709/sap-dev-release/wiki/Processing-ATC-Findings)
- **Maintain SAP Customizing:** Discover SPRO activities, inspect configuration, and apply approved changes with transport recording. [Customizing](https://github.com/stud0709/sap-dev-release/wiki/Customizing-Management)
- **Stay in control:** Approve object writes, API access, and GUI operations through dashboard guards, with encrypted connection settings and optional Cloudification API checks. [Permissions](https://github.com/stud0709/sap-dev-release/wiki/Permissions)

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

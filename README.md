# SAP Agent Skill (sap-dev)

Welcome to the SAP Agent environment! This skill provides a resilient Model Context Protocol (MCP) production bridge connecting your AI agents seamlessly to legacy SAP ABAP systems.

This software is in an early stage of development and will evolve rapidly. Feel free to open issues and feature requests on the [GitHub issues page](https://github.com/stud0709/sap-dev/issues).

⚠️ This toolset does **NOT** provide write access capabilities to the agent. It is intended for read-only operations such as code exploration, documentation and code generation, and ATC checks. If you want your agent to generate or modify ABAP code, your prompt should be: *"generate ... and save it to a local file"*. You can then review the code and manually upload it to SAP.

## Setup

### 0. Prerequisites

- Node.js (https://nodejs.org)
- AI IDE with MCP support
- SAP system to connect to

### 1. Setting Up Credentials

Before the bridge can orchestrate SAP tasks, you must generate your encrypted `.sap_credentials`. We provide a native interactive CLI wizard `sap-setup`to securely walk you through this (found in `bin` folder).

⚠️ SAP Credentials: You **must** launch the setup wizard strictly from the project's Root Directory. This ensures that the generated `.sap_credentials` file is anchored at the top-level scope correctly for the bridge to consume.

1. Open your terminal and navigate into the project's Root Directory.
2. Launch the compiled setup wizard:
   ```bash
   # Windows
   .\sap-setup.exe
   
   # macOS / Linux
   ./sap-setup
   ```
3. Follow the on-screen prompts to establish your SAP System connections (such as Host, Client, Scheme, and Port).
4. The wizard will write to `.sap_credentials` locally.

⚠️ **Credential Placement**: The bridge natively probes the **Current Working Directory (CWD)** for your `.sap_credentials` file. If you are registering this MCP Server globally in your system, ensure that the orchestrator executes the binary from the directory holding the credentials file.

*Note: .sap_credentials is a JSON file, you can enable / disable system entries as well as defining a standard entry by editing this file manually.*

### 2. Registering the Bridge

The `sap-bridge` operates natively as an orchestrator-agnostic MCP server, fully supporting modern AI IDEs and clients. 

It uses standard process `stdio` pipelines to communicate with your AI securely and silently in the background.

To register the bridge into your orchestrator's MCP config file, assign the absolute path to `sap-bridge` (found in `bin` folder) or follow your AI IDE's documentation. 

### Windows
```json
{
  "mcpServers": {
    "sap-bridge": {
      "command": "C:\\absolute\\path\\to\\sap-bridge.exe",
      "args": [],
      "env": {}
    }
  }
}
```

### macOS / Linux
```json
{
  "mcpServers": {
    "sap-bridge": {
      "command": "/absolute/path/to/sap-bridge",
      "args": [],
      "env": {}
    }
  }
}
```

### Registering the Skill

Place the contents of `sap-dev` folder into your AI IDE's skill directory.

*Note: Every AI IDE slightly differs in how it handles skill registration. Read the documentation of your AI IDE or ask your AI agent to help you with the registration process.*
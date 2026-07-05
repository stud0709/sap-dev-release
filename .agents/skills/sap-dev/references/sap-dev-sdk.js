const fs = require('fs');

/**
 * SAP-Bridge Agent-Centric SDK Helper
 * 
 * Provides utility functions for Standalone Plugins and Aspect Hooks to 
 * securely interact with the sap-bridge daemon via loopback APIs.
 */
class SapDevSDK {
    constructor() {
        this.env = {
            url: process.env.SAP_BRIDGE_URL || process.env.SAP_EXECUTION_URL,
            token: process.env.SAP_BRIDGE_TOKEN || process.env.SAP_EXECUTION_TOKEN,
            workspaceDir: process.env.SAP_WORKSPACE_DIR,
            systemID: process.env.SAP_SYSTEM_ID
        };
    }

    /**
     * Asserts that all required environment variables are present.
     * Throws an error with details if any are missing.
     */
    validateEnv() {
        const missing = [];
        if (!this.env.url) missing.push('SAP_BRIDGE_URL/SAP_EXECUTION_URL');
        if (!this.env.token) missing.push('SAP_BRIDGE_TOKEN/SAP_EXECUTION_TOKEN');
        if (!this.env.workspaceDir) missing.push('SAP_WORKSPACE_DIR');
        
        if (missing.length > 0) {
            throw new Error(`Missing active session environment: ${missing.join(', ')}. Ensure script is run via sap_execute_plugin.`);
        }
    }

    /**
     * Reads all data from standard input (stdin) and parses it as JSON.
     * Returns an empty object if stdin is empty.
     */
    async parseInput() {
        return new Promise((resolve, reject) => {
            let data = '';
            process.stdin.setEncoding('utf-8');
            
            // Non-blocking stream read
            process.stdin.on('readable', () => {
                let chunk;
                while ((chunk = process.stdin.read()) !== null) {
                    data += chunk;
                }
            });

            process.stdin.on('end', () => {
                if (!data.trim()) {
                    resolve({});
                    return;
                }
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    reject(new Error(`Failed to parse stdin input as JSON: ${e.message}`));
                }
            });

            process.stdin.on('error', (err) => {
                reject(err);
            });
            
            // Fast-path timeout check in case stdin is not attached/blocked
            setTimeout(() => {
                if (data === '') {
                    resolve({});
                }
            }, 100);
        });
    }

    /**
     * Terminate process with success output.
     * @param {Object} data 
     */
    success(data = {}) {
        console.log(JSON.stringify(data));
        process.exit(0);
    }

    /**
     * Terminate process with failure error output.
     * @param {string} message 
     * @param {number} code 
     */
    fail(message, code = 1) {
        console.error(JSON.stringify({
            isError: true,
            message: message
        }));
        process.exit(code);
    }

    /**
     * Private helper to dispatch a POST loopback request.
     */
    async _post(path, body) {
        this.validateEnv();
        const endpoint = `${this.env.url.replace(/\/$/, '')}${path}`;
        
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.env.token}`
            },
            body: JSON.stringify(body)
        });

        if (!response.ok) {
            const errText = await response.text();
            let parsedErr;
            try {
                parsedErr = JSON.parse(errText);
            } catch (e) {}

            const errMsg = (parsedErr && parsedErr.detail) || errText || `HTTP ${response.status}`;
            const err = new Error(errMsg);
            err.status = response.status;
            throw err;
        }

        return response.json();
    }

    /**
     * Call a registered MCP tool.
     * @param {string} rpcTool - e.g., "sap_execute_rfc"
     * @param {Object} payload - Arguments map for the target tool
     * @param {Array<Object>} [requiredPermissions] - Optional Object Guard whitelisting
     */
    async callRpc(rpcTool, payload, requiredPermissions) {
        return this._post('/api/guarded/rpc', {
            rpc_tool: rpcTool,
            payload: {
                tool: rpcTool,
                payload: payload
            },
            required_permissions: requiredPermissions
        });
    }

    /**
     * Dispatch a raw OData or HTTP request to the SAP backend.
     * @param {string} method - "GET" | "POST" | "PUT" | "DELETE"
     * @param {string} uri - ADT/OData path, e.g., "/sap/bc/adt/repository/nodestructure"
     * @param {string} [body] - Raw string body
     * @param {Object} [headers] - Key-value headers map
     * @param {Array<Object>} [requiredPermissions] - Optional Object Guard checks
     * @param {boolean} [bypassApiGuard] - Bypass standard URL API Guard checks
     */
    async callHttp(method, uri, body, headers, requiredPermissions, bypassApiGuard = false) {
        return this._post('/api/guarded/request', {
            method: method,
            uri: uri,
            body: body,
            headers: headers,
            required_permissions: requiredPermissions,
            bypass_api_guard: bypassApiGuard
        });
    }

    /**
     * Execute an OpenSQL statement against the database.
     * @param {string} anchorTable - Reference table to resolve schema
     * @param {string} query - OpenSQL query statement
     */
    async executeSql(anchorTable, query) {
        return this._post('/api/guarded/sql', {
            anchor_table: anchorTable,
            query: query
        });
    }
}

module.exports = new SapDevSDK();

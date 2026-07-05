/**
 * TypeScript Type Definitions for SAP-Bridge Extensibility & Customization SDK.
 */

export interface ScriptEnvironment {
  SAP_BRIDGE_URL: string;
  SAP_BRIDGE_TOKEN: string;
  SAP_SYSTEM_ID: string;
  SAP_WORKSPACE_DIR: string;
}

export interface RequiredPermission {
  object_name: string;
  object_type: string;
  package: string;
}

export interface GuardedRPCRequest {
  rpc_tool: string;
  payload: {
    tool: string;
    payload: Record<string, any>;
  };
  required_permissions?: RequiredPermission[];
}

export interface GuardedHTTPRequest {
  method: "GET" | "POST" | "PUT" | "DELETE";
  uri: string;
  body?: string;
  headers?: Record<string, string>;
  required_permissions?: RequiredPermission[];
  bypass_api_guard?: boolean;
}

export interface GuardedSQLRequest {
  anchor_table: string;
  query: string;
}

export interface HookFetchInput {
  object_name: string;
  object_type: string;
  aspect: string;
  active_dashboard_url: string;
  execution_token: string;
  workspace_dir: string;
}

export interface HookFetchOutput {
  success: boolean;
  content?: string;
  error_message?: string;
}

export interface HookPushInput {
  object_name: string;
  object_type: string;
  aspect: string;
  content: string;
  transport_request: string;
  active_dashboard_url: string;
  execution_token: string;
  workspace_dir: string;
}

export interface HookPushOutput {
  success: boolean;
  version_signature?: string;
  error_message?: string;
}

export interface SapDevSDK {
  env: {
    url: string | undefined;
    token: string | undefined;
    workspaceDir: string | undefined;
    systemID: string | undefined;
  };

  /**
   * Asserts that all required environment variables are present.
   */
  validateEnv(): void;

  /**
   * Reads all data from standard input (stdin) and parses it as JSON.
   */
  parseInput<T = any>(): Promise<T>;

  /**
   * Terminate process with success output.
   */
  success(data?: any): void;

  /**
   * Terminate process with failure error output.
   */
  fail(message: string, code?: number): void;

  /**
   * Call a registered MCP tool.
   */
  callRpc<T = any>(rpcTool: string, payload: Record<string, any>, requiredPermissions?: RequiredPermission[]): Promise<T>;

  /**
   * Dispatch a raw OData or HTTP request to the SAP backend.
   */
  callHttp<T = any>(method: "GET" | "POST" | "PUT" | "DELETE", uri: string, body?: string, headers?: Record<string, string>, requiredPermissions?: RequiredPermission[], bypassApiGuard?: boolean): Promise<T>;

  /**
   * Execute an OpenSQL statement against the database.
   */
  executeSql<T = any>(anchorTable: string, query: string): Promise<T>;
}

declare const sdk: SapDevSDK;
export default sdk;

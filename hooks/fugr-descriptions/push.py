#!/usr/bin/env python3
import sys
import json
import urllib.request

def log(msg):
    sys.stderr.write(f"[FUGR-PUSH] {msg}\n")
    sys.stderr.flush()

def main():
    try:
        input_data = json.load(sys.stdin)
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Parse error: {str(e)}"}))
        return

    obj_name = input_data.get("object_name", "").upper()
    dashboard_url = input_data.get("active_dashboard_url")
    token = input_data.get("execution_token")
    content = input_data.get("content", "")

    if not dashboard_url or not token:
        print(json.dumps({"success": False, "error_message": "Missing authentication params"}))
        return

    try:
        descriptions = json.loads(content)
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Invalid JSON content: {str(e)}"}))
        return

    # Get active transport request if passed
    transport = input_data.get("transport_request", "")

    loopback_url = f"{dashboard_url.rstrip('/')}/api/guarded/rpc"
    req_body = json.dumps({
        "rpc_tool": "save_fugr_descriptions",
        "payload": {
            "object_name": obj_name,
            "descriptions": [{"funcname": k, "stext": v} for k, v in descriptions.items()],
            "transport": transport
        }
    }).encode("utf-8")

    req = urllib.request.Request(
        loopback_url,
        data=req_body,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            resp_body = resp.read()
            status = resp.status
            headers = resp.headers
    except urllib.error.HTTPError as e:
        status = e.code
        resp_body = e.read()
        headers = e.headers
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Network error: {str(e)}"}))
        return

    if status != 200:
        print(json.dumps({
            "success": False,
            "error_message": f"Backend returned status {status}: {resp_body.decode('utf-8', errors='ignore')}"
        }))
        return

    resp_data = json.loads(resp_body.decode("utf-8"))
    success_val = resp_data.get("success") or resp_data.get("SUCCESS")
    if success_val in (True, "X", "x", "true"):
        success = True
    else:
        success = False

    if not success:
        err = resp_data.get("error_message") or resp_data.get("ERROR_MESSAGE") or "save_fugr_descriptions failed"
        print(json.dumps({"success": False, "error_message": err}))
        return

    etag = headers.get("ETag", "PUSH_FUGR_DESC_ETAG")
    print(json.dumps({
        "success": True,
        "version_signature": etag
    }))

if __name__ == "__main__":
    main()

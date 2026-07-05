#!/usr/bin/env python3
import sys
import json
import urllib.request

def log(msg):
    sys.stderr.write(f"[FUGR-FETCH] {msg}\n")
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

    if not dashboard_url or not token:
        print(json.dumps({"success": False, "error_message": "Missing authentication params"}))
        return

    # Program name for FUGR is SAPL<FUGR_NAME>
    prog_name = f"SAPL{obj_name}"
    sql_url = f"{dashboard_url.rstrip('/')}/api/guarded/sql"

    # 1. Fetch all function modules in the group
    req_data = {
        "anchor_table": "TFDIR",
        "query": f"SELECT funcname FROM tfdir WHERE pname = '{prog_name}'"
    }
    
    try:
        req = urllib.request.Request(
            sql_url,
            data=json.dumps(req_data).encode("utf-8"),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {token}"},
            method="POST"
        )
        with urllib.request.urlopen(req) as resp:
            resp_data = json.loads(resp.read().decode("utf-8"))
            func_rows = resp_data.get("rows", [])
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Failed to query TFDIR: {str(e)}"}))
        return

    if not func_rows:
        # Return empty dictionary if no function modules exist
        print(json.dumps({"success": True, "content": "{}"}))
        return

    func_names = [f"'{row['FUNCNAME']}'" for row in func_rows]
    func_in_list = ",".join(func_names)

    # 2. Fetch descriptions for these modules
    req_data["anchor_table"] = "TFTIT"
    req_data["query"] = f"SELECT funcname, stext FROM tftit WHERE funcname IN ({func_in_list}) AND spras = 'E'"

    descriptions = {}
    try:
        req = urllib.request.Request(
            sql_url,
            data=json.dumps(req_data).encode("utf-8"),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {token}"},
            method="POST"
        )
        with urllib.request.urlopen(req) as resp:
            resp_data = json.loads(resp.read().decode("utf-8"))
            desc_rows = resp_data.get("rows", [])
            for row in desc_rows:
                descriptions[row["FUNCNAME"]] = row["STEXT"]
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Failed to query TFTIT: {str(e)}"}))
        return

    # Backfill any missing module descriptions with empty strings
    for row in func_rows:
        name = row["FUNCNAME"]
        if name not in descriptions:
            descriptions[name] = ""

    print(json.dumps({
        "success": True,
        "content": json.dumps(descriptions, indent=2)
    }))

if __name__ == "__main__":
    main()

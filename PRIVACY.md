# Privacy Statement

Last updated: 14 November 2026

This statement explains how account registration, WorkOS sign-in and automatic usage telemetry process information about you. For registration, questions about this statement or your records, contact the Author. [Contact the Author](https://github.com/stud0709).

## Registration and WorkOS sign-in

Contact the Author before initial registration as an organization or an individual user. The Author provisions or approves registration and arranges account access. Organization members join through the approved invitation and membership process.

WorkOS provides the hosted authentication service. Account and sign-in information includes your name, email address, organization membership, authentication method and session information. The Author’s access service verifies your sign-in and retrieves membership status, assigned roles and permissions, feature availability and display information from WorkOS to determine access. WorkOS and its infrastructure providers also process ordinary network connection information, such as IP addresses. See the [WorkOS privacy policy](https://workos.com/legal/privacy).

The bridge stores remembered sign-in credentials in encrypted local storage and can remember a sign-in for up to 30 days, subject to sign-out, revocation and provider session limits. Local offline-access grants preserve previously verified permissions for up to 12 hours after the last successful online verification, bounded also by the sign-in and remembered-session deadlines. The workspace vault password separately protects stored SAP® credentials.

Account and organization records are managed separately from the telemetry retention period below. Contact the Author to request access to, correction of or deletion of your registration or account records.

## Usage telemetry collected

The software collects usage statistics, including an installation identifier, WorkOS organization and user identifiers, the signed-in user’s display name and organization name when available, the software version, activity timestamps, tool names, success or failure status, whether a tool operation is classified as billable, and call counts. These names and identifiers let the Author identify the account and organization associated with usage. Workspace names and paths are not transmitted.

Usage telemetry does not include SAP® source code, business data, prompts, tool arguments or result contents, SAP® system names or addresses, SAP® usernames, passwords, or credentials supplied by you.

## Purpose, destination and retention

Account and authentication information is used to register users and organizations and control access to the software. Usage telemetry is used to compile statistics about software use and attribute those statistics to the registered user and organization.

Usage records are sent over an encrypted HTTPS connection to the Author's Grafana Cloud account. Grafana Cloud and its infrastructure providers also receive ordinary network connection information, such as the sending IP address. See [Grafana Labs' privacy information](https://grafana.com/legal/privacy-policy/) and [data-processing information](https://grafana.com/legal/data-processing-agreement/).

The Author retains received usage telemetry for **14 days**.

## Your choices

Usage reporting is automatic in telemetry-enabled releases. The current release has no user-facing setting to disable this telemetry separately. Contact the Author before use if this reporting does not meet your requirements, or to ask about access to or deletion of usage records associated with your installation.

This statement covers the usage telemetry described above. Information you choose to send in issue reports or to your AI provider, SAP® systems, GitHub or other services is separate from this telemetry and is subject to the relevant arrangements and service policies.

## Local diagnostics and deliberate sharing

The dashboard, local logs and working artifacts retain original technical details for authorized analysis. Recognized credential fields and authentication headers are omitted when diagnostic records are collected. Ordinary text may contain sensitive information, so protect access to the local workspace and its logs.

Issue filing, diagnostic export and explicit sanitization prepare separate sharing copies. Sanitization uses current workspace credentials, unexpired OAuth tokens held in runtime memory and recognizable sensitive fields or patterns. Historical credentials are not persisted for sanitization. An old credential echoed as unlabelled text may remain unrecognized after it is changed or the daemon restarts. Review the prepared copy before sharing.

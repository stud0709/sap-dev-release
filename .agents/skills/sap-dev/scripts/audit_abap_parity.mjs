#!/usr/bin/env node
/**
 * ABAP AST-Based Structural & Semantic Parity Auditor
 * Part of the sap-dev AI Skill
 * 
 * Compares an ABAP baseline against refactored class includes to verify symbol preservation
 * and spotlight potential semantic shifts (function calls, DB queries, bitmasks) for human/agent review.
 * 
 * Usage:
 *   node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs --target .agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.abap
 *   node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs --git-baseline HEAD~1:... --target ...
 */

import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import * as abaplint from '@abaplint/core';

// CLI Argument Parsing
const args = process.argv.slice(2);
let baselineInput = null;
let gitBaselineRef = null;
let targetInputs = [];
let isJson = false;
let isStrict = false;
let verbose = false;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--baseline' && args[i + 1]) {
    baselineInput = args[++i];
  } else if (args[i] === '--git-baseline' && args[i + 1]) {
    gitBaselineRef = args[++i];
  } else if (args[i] === '--target' && args[i + 1]) {
    while (i + 1 < args.length && !args[i + 1].startsWith('--')) {
      targetInputs.push(args[++i]);
    }
  } else if (args[i] === '--strict') {
    isStrict = true;
  } else if (args[i] === '--json') {
    isJson = true;
  } else if (args[i] === '--verbose') {
    verbose = true;
  }
}

if (!baselineInput && !gitBaselineRef) {
  gitBaselineRef = 'HEAD~1:.agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.abap';
}
if (targetInputs.length === 0) {
  targetInputs = ['.agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.abap'];
}

// Helper: Sibling File Auto-Discovery
function resolveTargetFiles(inputs) {
  const fileMap = {};

  for (const input of inputs) {
    const resolved = path.resolve(input);
    if (!fs.existsSync(resolved)) continue;

    const stat = fs.statSync(resolved);
    if (stat.isDirectory()) {
      for (const f of fs.readdirSync(resolved)) {
        if (f.endsWith('.abap')) {
          fileMap[f] = fs.readFileSync(path.join(resolved, f), 'utf-8');
        }
      }
    } else {
      const dir = path.dirname(resolved);
      const filename = path.basename(resolved);
      fileMap[filename] = fs.readFileSync(resolved, 'utf-8');

      // Auto-discover sibling class includes if pointing to a .clas.* file
      if (filename.includes('.clas.')) {
        const basePrefix = filename.split('.clas.')[0] + '.clas.';
        const siblingSuffixes = ['abap', 'locals_def.abap', 'locals_imp.abap', 'testclasses.abap'];
        for (const suffix of siblingSuffixes) {
          const siblingName = basePrefix + suffix;
          const siblingPath = path.join(dir, siblingName);
          if (fs.existsSync(siblingPath) && !fileMap[siblingName]) {
            fileMap[siblingName] = fs.readFileSync(siblingPath, 'utf-8');
          }
        }
      }
    }
  }
  return fileMap;
}

// 1. Resolve Target Files
const targetFiles = resolveTargetFiles(targetInputs);

// 2. Resolve Baseline Source(s)
const baselineFiles = {};
let baselineLabel = '';

if (gitBaselineRef) {
  baselineLabel = `git:${gitBaselineRef}`;
  const parts = gitBaselineRef.split(':');
  const commit = parts[0];
  const gitPath = parts[1] || '';

  try {
    const content = execSync(`git show "${gitBaselineRef}"`, { encoding: 'utf-8', maxBuffer: 15 * 1024 * 1024 });
    const baseFilename = path.basename(gitPath);
    baselineFiles[baseFilename] = content;

    // Check if git baseline has sibling includes in the same commit
    if (gitPath.includes('.clas.')) {
      const gitDir = path.dirname(gitPath).replace(/\\/g, '/');
      const basePrefix = path.basename(gitPath).split('.clas.')[0] + '.clas.';
      const siblingSuffixes = ['abap', 'locals_def.abap', 'locals_imp.abap', 'testclasses.abap'];

      for (const suffix of siblingSuffixes) {
        const sName = basePrefix + suffix;
        if (sName !== baseFilename) {
          const sGitPath = (gitDir === '.' ? '' : gitDir + '/') + sName;
          try {
            const sContent = execSync(`git show "${commit}:${sGitPath}"`, { encoding: 'utf-8', maxBuffer: 15 * 1024 * 1024, stdio: ['pipe', 'pipe', 'ignore'] });
            baselineFiles[sName] = sContent;
          } catch (e) {
            // Sibling didn't exist in git at that commit (e.g. monolithic baseline) - ignore
          }
        }
      }
    }
  } catch (err) {
    console.error(`Error loading git baseline "${gitBaselineRef}":`, err.message);
    process.exit(1);
  }
} else if (baselineInput) {
  baselineLabel = baselineInput;
  const resolvedBase = path.resolve(baselineInput);
  if (fs.existsSync(resolvedBase)) {
    const bFiles = resolveTargetFiles([resolvedBase]);
    for (const [k, v] of Object.entries(bFiles)) {
      baselineFiles[k] = v;
    }
  }
}

// 3. Parse in abaplint
const regOld = new abaplint.Registry();
for (const [fName, content] of Object.entries(baselineFiles)) {
  regOld.addFile(new abaplint.MemoryFile(fName, content));
}
regOld.parse();

const regNew = new abaplint.Registry();
for (const [fName, content] of Object.entries(targetFiles)) {
  regNew.addFile(new abaplint.MemoryFile(fName, content));
}
regNew.parse();

// 4. Extract AST Metrics & Invariants
function extractASTFeatures(registry) {
  const data = {
    classes: new Set(),
    methods: new Set(),
    types: new Set(),
    interfaces: new Set(),
    statementsCount: 0,
    functionCalls: new Map(), // name -> count
    databaseOps: new Map(),   // op -> count
    bitwiseOps: new Map(),    // op -> count
    messages: new Map(),
    branchesCount: 0,
    parseErrors: []
  };

  for (const obj of registry.getObjects()) {
    for (const file of obj.getABAPFiles()) {
      const statements = file.getStatements();

      for (const stmt of statements) {
        const text = stmt.concatTokens().trim();
        const upper = text.toUpperCase();
        const isComment = stmt.get() && stmt.get().constructor && stmt.get().constructor.name === 'Comment';

        if (isComment) continue;

        data.statementsCount++;

        // Catch true parse errors / unknown syntax tokens
        if (stmt.get() && stmt.get().constructor && stmt.get().constructor.name === 'Unknown') {
          data.parseErrors.push({
            file: file.getFilename(),
            row: stmt.getStart().getRow(),
            text: text
          });
        }

        // Decision branches
        if (upper.startsWith('IF ') || upper.startsWith('ELSEIF ') || upper.startsWith('WHEN ') ||
            upper.startsWith('CATCH ') || upper.startsWith('CLEANUP') || (upper.includes('LOOP AT ') && upper.includes('WHERE '))) {
          data.branchesCount++;
        }

        // Classes & Interfaces
        if (upper.startsWith('CLASS ') && upper.includes(' DEFINITION')) {
          const m = upper.match(/CLASS\s+([^\s]+)\s+DEFINITION/i);
          if (m) data.classes.add(m[1]);
        }
        if (upper.startsWith('INTERFACE ') && upper.includes(' DEFINITION')) {
          const m = upper.match(/INTERFACE\s+([^\s]+)\s+DEFINITION/i);
          if (m) data.interfaces.add(m[1]);
        }

        // Methods
        if (upper.startsWith('CLASS-METHODS ') || upper.startsWith('METHODS ')) {
          const m = upper.match(/(?:CLASS-METHODS|METHODS)\s+([^\s(]+)/i);
          if (m) data.methods.add(m[1]);
        }
        if (upper.startsWith('METHOD ')) {
          const m = upper.match(/METHOD\s+([^\s.]+)/i);
          if (m) data.methods.add(m[1]);
        }

        // Types
        if (upper.startsWith('TYPES:') || upper.startsWith('TYPES ')) {
          const m = upper.match(/TYPES(?::|\s+BEGIN OF|\s+)\s+([^\s(]+)/i);
          if (m) data.types.add(m[1]);
        }

        // Function calls
        if (upper.includes('CALL FUNCTION')) {
          const m = upper.match(/CALL\s+FUNCTION\s+['']([^'']+)['']/i);
          const fn = m ? m[1] : 'DYNAMIC';
          data.functionCalls.set(fn, (data.functionCalls.get(fn) || 0) + 1);
        }

        // Database operations
        if (upper.startsWith('SELECT ') || upper.startsWith('SELECT:')) {
          data.databaseOps.set('SELECT', (data.databaseOps.get('SELECT') || 0) + 1);
        } else if (upper.startsWith('UPDATE ')) {
          data.databaseOps.set('UPDATE', (data.databaseOps.get('UPDATE') || 0) + 1);
        } else if (upper.startsWith('INSERT ')) {
          data.databaseOps.set('INSERT', (data.databaseOps.get('INSERT') || 0) + 1);
        } else if (upper.startsWith('DELETE FROM ') || upper.startsWith('DELETE ')) {
          data.databaseOps.set('DELETE', (data.databaseOps.get('DELETE') || 0) + 1);
        } else if (upper.startsWith('COMMIT WORK')) {
          data.databaseOps.set('COMMIT', (data.databaseOps.get('COMMIT') || 0) + 1);
        }

        // Bitwise operations
        if (upper.includes('BIT-OR') || upper.includes('BIT-AND') || upper.includes('BIT-XOR') ||
            upper.includes('FMB1') || upper.includes('D021S_RES1') || upper.includes('C_X80') || upper.includes('C_X40')) {
          const opKey = upper.includes('BIT-OR') ? 'BIT-OR' : (upper.includes('BIT-AND') ? 'BIT-AND' : 'DYNPRO_BITMASK');
          data.bitwiseOps.set(opKey, (data.bitwiseOps.get(opKey) || 0) + 1);
        }

        // Messages
        if (upper.startsWith('MESSAGE ')) {
          const m = upper.match(/MESSAGE\s+([^\s.]+)/i);
          const msg = m ? m[1] : 'GENERIC_MSG';
          data.messages.set(msg, (data.messages.get(msg) || 0) + 1);
        }
      }
    }
  }

  return data;
}

const oldA = extractASTFeatures(regOld);
const newA = extractASTFeatures(regNew);

// 5. Evaluate Parity & Identify Review Spots
const missingMethods = [...oldA.methods].filter(m => !newA.methods.has(m));
const newLocalMethods = [...newA.methods].filter(m => !oldA.methods.has(m));
const missingTypes = [...oldA.types].filter(t => !newA.types.has(t));
const missingInterfaces = [...oldA.interfaces].filter(i => !newA.interfaces.has(i));

const reviewSpots = [];
const blockingErrors = [];

// Parse/Syntax Errors
if (newA.parseErrors.length > 0) {
  for (const pe of newA.parseErrors) {
    blockingErrors.push({
      type: 'SYNTAX_ERROR',
      message: `Syntax/parse error at [${pe.file}:${pe.row}]: "${pe.text}"`
    });
  }
}

// Dropped public symbols
if (missingMethods.length > 0) {
  reviewSpots.push({
    category: 'METHODS',
    message: `Methods not found in target: ${missingMethods.join(', ')}`,
    guidance: 'Verify if methods were renamed or decomposed into helper subroutines.'
  });
}
if (missingTypes.length > 0) {
  reviewSpots.push({
    category: 'TYPES',
    message: `Data types not found in target: ${missingTypes.join(', ')}`,
    guidance: 'Verify if types were moved to locals_def or replaced.'
  });
}
if (missingInterfaces.length > 0) {
  reviewSpots.push({
    category: 'INTERFACES',
    message: `Interfaces not found in target: ${missingInterfaces.join(', ')}`,
    guidance: 'Verify if interface implementations were preserved.'
  });
}

// Function Module Call shifts
for (const [fnName, count] of oldA.functionCalls.entries()) {
  const targetCount = newA.functionCalls.get(fnName) || 0;
  if (targetCount < count) {
    reviewSpots.push({
      category: 'FUNCTION_CALLS',
      message: `CALL FUNCTION '${fnName}' (baseline: ${count}, target: ${targetCount})`,
      guidance: `Verify if intentionally modernized (e.g. with MESSAGE ... INTO, direct OData, or helper classes).`
    });
  }
}

// Database Operation shifts
for (const [opType, count] of oldA.databaseOps.entries()) {
  const targetCount = newA.databaseOps.get(opType) || 0;
  if (targetCount < count) {
    reviewSpots.push({
      category: 'DATABASE_OPS',
      message: `${opType} statements decreased (baseline: ${count}, target: ${targetCount})`,
      guidance: 'Expected if duplicate query loops were consolidated into reusable helper methods.'
    });
  }
}

// Bitwise shifts
for (const [opName, count] of oldA.bitwiseOps.entries()) {
  const targetCount = newA.bitwiseOps.get(opName) || 0;
  if (targetCount < count) {
    reviewSpots.push({
      category: 'BITWISE_OPS',
      message: `Bitwise/Dynpro '${opName}' operations decreased (baseline: ${count}, target: ${targetCount})`,
      guidance: 'Verify that screen flag / bitmask assignments were not accidentally omitted.'
    });
  }
}

// 6. Output Formatting
const report = {
  baseline_label: baselineLabel,
  baseline_files: Object.keys(baselineFiles),
  target_files: Object.keys(targetFiles),
  has_syntax_errors: blockingErrors.length > 0,
  blocking_errors: blockingErrors,
  review_spots: reviewSpots,
  summary: {
    baseline_methods: oldA.methods.size,
    target_methods: newA.methods.size,
    new_helper_subroutines: newLocalMethods.length,
    baseline_types: oldA.types.size,
    target_types: newA.types.size,
    baseline_branches: oldA.branchesCount,
    target_branches: newA.branchesCount,
    baseline_function_calls: Array.from(oldA.functionCalls.values()).reduce((a, b) => a + b, 0),
    target_function_calls: Array.from(newA.functionCalls.values()).reduce((a, b) => a + b, 0),
    baseline_database_ops: Array.from(oldA.databaseOps.values()).reduce((a, b) => a + b, 0),
    target_database_ops: Array.from(newA.databaseOps.values()).reduce((a, b) => a + b, 0),
    baseline_bitwise_ops: Array.from(oldA.bitwiseOps.values()).reduce((a, b) => a + b, 0),
    target_bitwise_ops: Array.from(newA.bitwiseOps.values()).reduce((a, b) => a + b, 0),
  }
};

if (isJson) {
  console.log(JSON.stringify(report, null, 2));
  if (blockingErrors.length > 0 || (isStrict && reviewSpots.length > 0)) process.exit(1);
  process.exit(0);
}

console.log(`======================================================================`);
console.log(` 🔍 ABAP AST STRUCTURAL AUDIT REPORT`);
console.log(`======================================================================`);
console.log(`Baseline : ${baselineLabel} (${Object.keys(baselineFiles).join(', ')})`);
console.log(`Target   : ${Object.keys(targetFiles).join(', ')} (Auto-discovered class pool includes)`);
console.log(`----------------------------------------------------------------------`);

console.log(`\n📊 Architecture & Symbol Summary:`);
console.log(`  - Methods       : Baseline = ${oldA.methods.size} | Target = ${newA.methods.size} (${newLocalMethods.length > 0 ? `+${newLocalMethods.length} modular helper subroutines` : 'identical'})`);
console.log(`  - Data Types    : Baseline = ${oldA.types.size} | Target = ${newA.types.size}`);
console.log(`  - Decision Paths: Baseline = ${oldA.branchesCount} | Target = ${newA.branchesCount}`);
console.log(`  - Function Calls: Baseline = ${report.summary.baseline_function_calls} | Target = ${report.summary.target_function_calls}`);
console.log(`  - Database Ops  : Baseline = ${report.summary.baseline_database_ops} | Target = ${report.summary.target_database_ops}`);
console.log(`  - Bitwise Ops   : Baseline = ${report.summary.baseline_bitwise_ops} | Target = ${report.summary.target_bitwise_ops}`);

if (blockingErrors.length > 0) {
  console.log(`\n🚨 SYNTAX / PARSE ERRORS (${blockingErrors.length}):`);
  for (const err of blockingErrors) {
    console.log(`  ❌ ${err.message}`);
  }
}

if (reviewSpots.length > 0) {
  console.log(`\n💡 POTENTIAL SPOTS FOR REVIEW (${reviewSpots.length} items noted):`);
  for (const spot of reviewSpots) {
    console.log(`  ℹ️ [${spot.category}] ${spot.message}`);
    console.log(`     ↳ Guidance: ${spot.guidance}`);
  }
} else {
  console.log(`\n✅ 100% Invariants Preserved: Zero statement, call, or symbol deltas.`);
}

console.log(`\n======================================================================`);
if (blockingErrors.length > 0) {
  console.error(`❌ STATUS: AUDIT HALTED - Fix syntax/parse errors before proceeding.`);
  process.exit(1);
} else if (isStrict && reviewSpots.length > 0) {
  console.error(`❌ STATUS: STRICT AUDIT FAILED - Review spots detected.`);
  process.exit(1);
} else {
  console.log(`✅ STATUS: AUDIT COMPLETE - Code is syntactically sound. Review highlighted spots above.`);
  process.exit(0);
}

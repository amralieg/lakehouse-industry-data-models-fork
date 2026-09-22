/**
 * Persistent ELK layout subprocess.
 * Stays alive and accepts line-delimited JSON on stdin.
 * For each line: parse ELK graph, compute layout, write result as one JSON line to stdout.
 *
 * Protocol:
 *   stdin:  one JSON object per line (newline-delimited)
 *   stdout: one JSON object per line — either { result: ... } or { error: "..." }
 *
 * Called by diagram.py once at startup; reused for all subsequent layout requests.
 */
const path = require("path");
const readline = require("readline");
const ELK = require(path.join(__dirname, "elk.bundled.js"));

const elk = new ELK();
let pending = 0;
let stdinClosed = false;

const rl = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });

rl.on("line", (line) => {
  if (!line.trim()) return;
  let graph;
  try {
    graph = JSON.parse(line);
  } catch (err) {
    process.stdout.write(JSON.stringify({ error: "Invalid JSON: " + err.message }) + "\n");
    return;
  }
  pending++;
  elk.layout(graph).then((result) => {
    process.stdout.write(JSON.stringify({ result }) + "\n");
  }).catch((err) => {
    process.stdout.write(JSON.stringify({ error: String(err) }) + "\n");
  }).finally(() => {
    pending--;
    if (stdinClosed && pending === 0) process.exit(0);
  });
});

rl.on("close", () => {
  stdinClosed = true;
  if (pending === 0) process.exit(0);
});

// Signal readiness
process.stdout.write(JSON.stringify({ ready: true }) + "\n");

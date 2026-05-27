// hello.js — a guided tour of what runs in this Hermes build.
//
// Run with:   hermes hello.js          (after `source env.sh`)
//      or:   ./hermes/build/bin/hermes hello.js
//
// Every section is independent — feel free to comment out blocks you don't
// care about, or copy snippets into your own files.

console.log("Hello, World!");

const myFunc = () => {
  console.log("This is a function.");
};
myFunc();

// ─── 1. print() vs console.log ───────────────────────────────────────────
print("\n=== print() and console.log both work ===");
print("print() is the idiomatic Hermes CLI primitive (one arg, no newline tricks).");
console.log("console.log also works — a minimal `console` is shipped.");

// ─── 2. Modern ES syntax (defaults, template literals, spread/rest) ──────
print("\n=== Modern ES syntax ===");
const greet = (who = "stranger") => `hi, ${who}!`;
print(greet());
print(greet("Vikas"));

const user = { name: "Ada", role: "engineer", lang: "JS" };
const { name, ...rest } = user;
print(`destructured: name=${name}  rest=${JSON.stringify(rest)}`);

// ─── 3. Classes with private + static fields ─────────────────────────────
print("\n=== Classes (with #private and static fields) ===");
class Counter {
  #n = 0;
  static label = "tick";
  inc() { this.#n += 1; return this; }   // fluent chain
  get value() { return this.#n; }
}
const c = new Counter().inc().inc().inc();
print(`${Counter.label}: ${c.value}`);    // -> tick: 3

// ─── 4. Map, Set, iteration ──────────────────────────────────────────────
print("\n=== Collections + for..of iteration ===");
const unique = new Set([1, 1, 2, 3, 3, 4]);
print(`unique values: ${[...unique].join(", ")}`);

const m = new Map([["one", 1], ["two", 2], ["three", 3]]);
for (const [k, v] of m) print(`  ${k} -> ${v}`);

// ─── 5. Generators (lazy sequences) ──────────────────────────────────────
print("\n=== Generator: first 10 Fibonacci numbers ===");
function* fibs() {
  let [a, b] = [0, 1];
  while (true) { yield a; [a, b] = [b, a + b]; }
}
const take = (gen, n) => {
  const out = [];
  for (const x of gen) { out.push(x); if (out.length >= n) break; }
  return out;
};
print(take(fibs(), 10).join(", "));

// ─── 6. BigInt ───────────────────────────────────────────────────────────
print("\n=== BigInt (arbitrary precision integers) ===");
print(`2n ** 100n = ${2n ** 100n}`);

// ─── 7. Optional chaining ?. and nullish coalescing ?? ───────────────────
print("\n=== ?. and ?? ===");
const data = { profile: { email: null } };
print(`email: ${data?.profile?.email ?? "(none provided)"}`);
print(`phone: ${data?.profile?.phone ?? "(none provided)"}`);

// ─── 8. Regex: unicode property escapes + named groups ───────────────────
print("\n=== Regex (named groups + unicode properties) ===");
const line = "2026-05-28 ERROR something broke";
const parsed = /^(?<date>\d{4}-\d{2}-\d{2})\s+(?<level>\w+)\s+(?<msg>.+)$/.exec(line);
print(`parsed groups: ${JSON.stringify(parsed.groups)}`);
print(`'日本' contains letters: ${/\p{Letter}/u.test("日本")}`);

// ─── 9. JSON roundtrip ───────────────────────────────────────────────────
print("\n=== JSON ===");
const obj = { ok: true, list: [1, 2, 3], when: new Date(0).toISOString() };
const round = JSON.parse(JSON.stringify(obj));
print(JSON.stringify(round, null, 2));

// ─── 10. async / await + Promise ─────────────────────────────────────────
// Microtasks drain before Hermes exits, so awaiting Promises works in the
// CLI even without a real event loop. (Don't expect setTimeout/setInterval
// callbacks to fire here — there's no event loop to schedule them.)
// We put this section last so its output (which runs in the microtask queue
// after the synchronous code finishes) appears at the natural bottom.
print("\n=== async / await ===");
async function addAsync() {
  const a = await Promise.resolve(2);
  const b = await Promise.resolve(3);
  return a + b;
}
addAsync().then(r => {
  print(`Promise resolved with ${r}`);
  print("\nDone. Edit this file and re-run `hermes hello.js` to experiment.");
});

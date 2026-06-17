import { spawn, execSync } from 'child_process';
import readline from 'readline';

// Get current version and build
const infoPlistPath = "Apps/Harness/Sources/HarnessApp/Resources/Info.plist";
let currentVersion = "";
let currentBuild = "";
try {
  currentVersion = execSync(`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${infoPlistPath}"`, { encoding: 'utf8' }).trim();
  currentBuild = execSync(`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${infoPlistPath}"`, { encoding: 'utf8' }).trim();
} catch (e) {
  currentVersion = "unknown";
  currentBuild = "unknown";
}

// Calculate next versions
let nextPatch = "";
let nextMinor = "";
let nextMajor = "";
if (currentVersion !== "unknown" && currentVersion.includes('.')) {
  const [major, minor, patch] = currentVersion.split('.').map(Number);
  nextPatch = `${major}.${minor}.${patch + 1}`;
  nextMinor = `${major}.${minor + 1}.0`;
  nextMajor = `${major + 1}.0.0`;
}
const nextVersions = nextPatch ? ` (${nextPatch} / ${nextMinor} / ${nextMajor})` : "";

function runCommand(command, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { stdio: 'inherit' });
    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Command failed with code ${code}`));
      }
    });
    child.on('error', reject);
  });
}

async function selectWithArrows(options) {
  if (!process.stdin.isTTY) {
    return selectWithReadline(options);
  }

  let selected = 0;

  const displayMenu = () => {
    console.clear?.() || console.log('\x1Bc');
    console.log('\n🚀 Harness Build & Release');
    console.log(`\x1b[2mCurrent Version:\x1b[0m \x1b[1;33mv${currentVersion}\x1b[0m \x1b[2m(build ${currentBuild})\x1b[0m\n`);
    options.forEach((opt, i) => {
      const prefix = i === selected ? '❯ ' : '  ';
      const style = i === selected ? '\x1b[1;36m' : '\x1b[0m';
      console.log(`${prefix}${style}${opt.display}\x1b[0m`);
    });
    console.log('\n(Use ↑/↓ arrows and press Enter)\n');
  };

  displayMenu();

  return new Promise((resolve) => {
    process.stdin.setRawMode(true);
    process.stdin.setEncoding('utf8');
    process.stdin.resume();

    const onData = (char) => {
      const code = char.charCodeAt(0);

      if (code === 3) {
        process.stdin.setRawMode(false);
        process.exit(0);
      }

      if (code === 13) {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        process.stdin.removeListener('data', onData);
        console.log(`\n✅ Selected: ${options[selected].display}\n`);
        resolve(options[selected].value);
        return;
      }

      if (char === '\x1b[A') {
        selected = (selected - 1 + options.length) % options.length;
        displayMenu();
      } else if (char === '\x1b[B') {
        selected = (selected + 1) % options.length;
        displayMenu();
      }
    };

    process.stdin.on('data', onData);
  });
}

async function selectWithReadline(options) {
  console.log('\n🚀 Harness Build & Release');
  console.log(`\x1b[2mCurrent Version:\x1b[0m \x1b[1;33mv${currentVersion}\x1b[0m \x1b[2m(build ${currentBuild})\x1b[0m\n`);
  options.forEach((opt) => {
    console.log(`  ${opt.display}`);
  });

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question('\nEnter choice (1-' + options.length + '): ', (answer) => {
      rl.close();
      const idx = parseInt(answer) - 1;
      if (idx >= 0 && idx < options.length) {
        console.log(`\n✅ Selected: ${options[idx].display}\n`);
        resolve(options[idx].value);
      } else {
        console.log('❌ Invalid choice');
        process.exit(1);
      }
    });
  });
}

async function main() {
  try {
    const options = [
      {
        display: '1) Commit + Push + Merge (commit-push-merge.sh)',
        value: 'commit-push-merge'
      },
      {
        display: '2) Preview build, isolated dev/test app (make preview)',
        value: 'preview'
      },
      {
        display: '3) Production build only, no version bump (make prod)',
        value: 'prod'
      },
      {
        display: `4) Full cycle: build → bump → commit+push → prod${nextVersions}`,
        value: 'full-cycle'
      }
    ];

    // Direct argument: `node start.mjs 1` or `node start.mjs preview`
    const arg = process.argv[2];
    let choice;
    if (arg) {
      const byNumber = { '1': 'commit-push-merge', '2': 'preview', '3': 'prod', '4': 'full-cycle' };
      const byName = { 'commit-push-merge': 'commit-push-merge', 'preview': 'preview', 'prod': 'prod', 'full-cycle': 'full-cycle' };
      choice = byNumber[arg] || byName[arg];
      if (!choice) { console.error(`❌ Unknown option: ${arg}`); process.exit(1); }
      console.log(`\n✅ Selected: ${options.find(o => o.value === choice)?.display}\n`);
    } else {
      choice = await selectWithArrows(options);
    }

    if (choice === 'commit-push-merge') {
      await runCommand('Scripts/commit-push-merge.sh', []);
    } else if (choice === 'preview') {
      await runCommand('make', ['preview-stop']).catch(() => {});
      await runCommand('make', ['preview-clean']);
      await runCommand('./Scripts/run.sh', ['preview']);
    } else if (choice === 'prod') {
      await runCommand('./Scripts/run.sh', ['prod']);
    } else if (choice === 'full-cycle') {
      await runCommand('Scripts/full-cycle.sh', []);
    }
  } catch (err) {
    console.error('\n❌ Error:', err.message);
    process.exit(1);
  }
}

main();

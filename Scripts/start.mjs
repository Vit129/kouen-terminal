import { spawn, execSync } from 'child_process';
import readline from 'readline';

// Get current version and build
const infoPlistPath = "Apps/Kouen/Sources/KouenApp/Resources/Info.plist";
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
    console.log('\n🚀 Kouen Build & Release');
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
  console.log('\n🚀 Kouen Build & Release');
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

function printHelp(options) {
  console.log(`
🚀 Kouen Build & Release

Usage:
  Scripts/start.sh [choice] [bump] [options]
  make start [choice] [bump] [options]

Choices:
  1, commit-push-merge, commit   Commit and push changes via PR/merge
  2, preview, dev                Preview build — isolated dev/test app
  3, full-cycle, release         Full cycle: build → bump → commit+push → install

Direct Bump Shortcuts (runs full-cycle):
  patch                          Full cycle with patch bump
  minor                          Full cycle with minor bump
  major                          Full cycle with major bump
  skip, --no-bump                Full cycle keeping current version

Options & AI / Non-interactive Flags:
  -m, --message <msg>            Commit message (or set COMMIT_MESSAGE="...")
  -y, --yes                      Non-interactive: skip prompts, auto-accept defaults
  -h, --help                     Show this help

Examples:
  make start 1 -m "feat(history): add usage view"
  make start patch -m "fix: resolve memory leak"
  make start 3 minor -y
  make start preview
`);
}

async function main() {
  try {
    const options = [
      {
        display: '1) Commit + Push (commit-push-merge.sh)',
        value: 'commit-push-merge'
      },
      {
        display: '2) Preview build — isolated dev/test app (make preview)',
        value: 'preview'
      },
      {
        display: `3) Full cycle: build → bump → commit+push → install${nextVersions}`,
        value: 'full-cycle'
      }
    ];

    const byNumber = { '1': 'commit-push-merge', '2': 'preview', '3': 'full-cycle' };
    const byName = {
      'commit-push-merge': 'commit-push-merge',
      'commit': 'commit-push-merge',
      'push': 'commit-push-merge',
      'preview': 'preview',
      'dev': 'preview',
      'full-cycle': 'full-cycle',
      'release': 'full-cycle'
    };
    const bumpDirect = {
      'patch': 'patch',
      'minor': 'minor',
      'major': 'major',
      'skip': '--no-bump',
      '--no-bump': '--no-bump'
    };

    let choice = process.env.START_CHOICE || process.env.CHOICE || null;
    let bumpArg = null;
    let commitMessage = process.env.COMMIT_MESSAGE || null;
    let autoYes = Boolean(process.env.AUTO_YES || process.env.CI || process.env.NON_INTERACTIVE);

    const rawArgs = process.argv.slice(2);
    const positionalArgs = [];

    for (let i = 0; i < rawArgs.length; i++) {
      const a = rawArgs[i];
      if (a === '-h' || a === '--help' || a === 'help') {
        printHelp(options);
        process.exit(0);
      } else if (a === '-y' || a === '--yes' || a === '--non-interactive') {
        autoYes = true;
      } else if (a === '-m' || a === '--message') {
        commitMessage = rawArgs[++i] || '';
      } else if (a.startsWith('--message=')) {
        commitMessage = a.slice('--message='.length);
      } else if (a.startsWith('-m=')) {
        commitMessage = a.slice('-m='.length);
      } else if (a === '--no-bump' || a === '--skip') {
        bumpArg = '--no-bump';
      } else {
        positionalArgs.push(a);
      }
    }

    // Process positional arguments
    for (const pos of positionalArgs) {
      if (!choice) {
        if (bumpDirect[pos]) {
          choice = 'full-cycle';
          bumpArg = bumpDirect[pos];
        } else if (byNumber[pos] || byName[pos]) {
          choice = byNumber[pos] || byName[pos];
        } else {
          // If message not set, this could be a commit message or invalid choice
          console.error(`❌ Unknown option: ${pos}`);
          printHelp(options);
          process.exit(1);
        }
      } else if (choice === 'full-cycle' && !bumpArg) {
        if (bumpDirect[pos]) {
          bumpArg = bumpDirect[pos];
        } else if (['1', '2', '3', '4'].includes(pos)) {
          const bumpMap = { '1': 'patch', '2': 'minor', '3': 'major', '4': '--no-bump' };
          bumpArg = bumpMap[pos];
        } else if (!commitMessage) {
          commitMessage = pos;
        }
      } else if (!commitMessage) {
        commitMessage = pos;
      }
    }

    if (!choice) {
      if (!process.stdin.isTTY) {
        console.error('\n🚀 Kouen Build & Release (Non-interactive / AI mode)');
        console.error(`Current Version: v${currentVersion} (build ${currentBuild})\n`);
        console.error('No interactive TTY detected. Specify options via arguments or environment:');
        console.error('  make start 1 [-m "commit message"]               # Commit + Push + Merge');
        console.error('  make start 2                                    # Preview build');
        console.error('  make start 3 [patch|minor|major|skip] [-m "msg"] # Full cycle');
        console.error('  make start patch [-m "commit message"]           # Shortcut for patch full-cycle');
        console.error('\nOr pass variables:');
        console.error('  COMMIT_MESSAGE="feat: ..." make start 1');
        console.error('  make start 1 msg="feat: ..."\n');
        process.exit(1);
      }
      choice = await selectWithArrows(options);
    } else {
      console.log(`\n✅ Selected: ${options.find(o => o.value === choice)?.display || choice}\n`);
    }

    // Refresh the knowledge graph before any option that actually commits/releases
    // code — a stale graphify-out/ silently misleads AI-assisted work done right
    // after. Skipped for 'preview' (just spins up a local test app, touches no git
    // history). Reuses run.sh's own `graphify` subcommand rather than duplicating
    // the update logic here. Best-effort: never blocks the actual command.
    if (choice !== 'preview') {
      try {
        const fs = await import('fs');
        if (fs.existsSync('graphify-out')) {
          console.log('▶ Refreshing graphify index...');
          await runCommand('./Scripts/run.sh', ['graphify']);
          console.log('');
        }
      } catch (e) {
        console.log(`⚠️  graphify refresh failed — continuing anyway (${e.message})\n`);
      }
    }

    if (choice === 'commit-push-merge') {
      const cpmArgs = [];
      if (commitMessage) {
        cpmArgs.push('-m', commitMessage);
      }
      if (autoYes) {
        cpmArgs.push('-y');
      }
      await runCommand('Scripts/commit-push-merge.sh', cpmArgs);
    } else if (choice === 'preview') {
      await runCommand('make', ['preview-stop']).catch(() => {});
      await runCommand('make', ['preview-clean']);
      await runCommand('./Scripts/run.sh', ['preview']);
    } else if (choice === 'full-cycle') {
      const bumpOptions = [
        { display: '1) patch  — bug fixes', value: 'patch' },
        { display: '2) minor  — new features', value: 'minor' },
        { display: '3) major  — breaking changes', value: 'major' },
        { display: '4) skip   — keep current version', value: '--no-bump' },
      ];
      let bump = bumpArg;
      if (!bump) {
        if (!process.stdin.isTTY || autoYes) {
          console.log('No TTY available / auto-yes mode: defaulting to patch bump.');
          bump = 'patch';
        } else {
          console.log('\nVersion bump?');
          bump = await selectWithArrows(bumpOptions);
        }
      }
      const bumpArgs = bump === '--no-bump' ? ['--no-bump'] : [bump];
      if (commitMessage) {
        bumpArgs.push('-m', commitMessage);
      }
      if (autoYes) {
        bumpArgs.push('-y');
      }
      await runCommand('Scripts/full-cycle.sh', bumpArgs);
    }
  } catch (err) {
    console.error('\n❌ Error:', err.message);
    process.exit(1);
  }
}

main();

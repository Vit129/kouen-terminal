#!/usr/bin/env python3
"""Matched local GUI history/idle receipt at 1/10/30/50 sessions.

Use an isolated HARNESS_HOME and an already-running packaged app. Every pane is
visited and proves parsing with a cursor-report fence. Agent processes, when
requested, are launched only in the last ten panes; their memory is separate.
This records one settled sample per state, not a statistical performance claim.
"""
import argparse
import json
import os
from pathlib import Path
import re
import select
import shlex
import subprocess
import sys
import termios
import time
import tty


def pane_ready(path):
    saved = termios.tcgetattr(0)
    try:
        tty.setraw(0)
        os.write(1, b"\x1b[6n")
        deadline = time.monotonic() + 15
        received = b""
        while time.monotonic() < deadline:
            if select.select([0], [], [], max(0, deadline-time.monotonic()))[0]:
                received += os.read(0, 4096)
                if re.search(rb"\x1b\[\d+;\d+R", received):
                    size = os.get_terminal_size(1)
                    path.write_text(json.dumps({'columns': size.columns, 'rows': size.lines})+'\n')
                    return
        raise RuntimeError('GUI did not acknowledge filled pane')
    finally:
        termios.tcsetattr(0, termios.TCSANOW, saved)


def processes():
    output = subprocess.check_output(['ps', '-axo', 'pid=,ppid=,cputime=,rss=,comm='], text=True)
    result = {}
    for line in output.splitlines():
        pid, parent, clock, rss, command = line.split(maxsplit=4)
        seconds = 0
        if '-' in clock:
            days, clock = clock.split('-', 1)
            seconds = int(days)*86400
        parts = clock.split(':')
        duration = 0
        for part in parts:
            duration = duration*60+float(part)
        result[int(pid)] = {'parent': int(parent), 'cpu_seconds': seconds+duration,
                            'rss_bytes': int(rss)*1024, 'command': command}
    return result


def footprint(pid, raw_path):
    probe = subprocess.run(['footprint', '--format', 'bytes', '--noCategories', str(pid)],
                           capture_output=True, text=True)
    raw_path.write_text(probe.stdout+probe.stderr)
    match = re.search(r'^\s*phys_footprint:\s*(\d+)', probe.stdout, re.M)
    return int(match[1]) if match else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pane-ready', type=Path)
    parser.add_argument('--cli', type=Path)
    parser.add_argument('--home', type=Path)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--app-pid', type=int)
    parser.add_argument('--daemon-pid', type=int)
    parser.add_argument('--host-pid', type=int)
    parser.add_argument('--agent-command')
    args = parser.parse_args()
    if args.pane_ready:
        pane_ready(args.pane_ready)
        return
    if not all((args.cli, args.home, args.out, args.app_pid, args.daemon_pid, args.host_pid)):
        parser.error('provide explicit CLI, isolated home, output, and all three process IDs')
    args.out.mkdir(parents=True, exist_ok=True)
    if args.home.resolve().parent != Path('/tmp').resolve() or not args.home.name.startswith('harness-performance-'):
        parser.error('use an isolated /tmp/harness-performance- home')
    env = {key: value for key, value in os.environ.items() if not key.startswith('HARNESS')}
    env['HARNESS_HOME'] = str(args.home.resolve())
    def cli(*argv):
        return subprocess.check_output([str(args.cli.resolve()), *argv], env=env, text=True)
    stats = json.loads(cli('daemon-stats', '--json'))
    if (stats.get('daemonPID'), stats.get('sessionHostPID')) != (args.daemon_pid, args.host_pid):
        parser.error('daemon and host PIDs do not match the isolated home')
    bundles = [parent for parent in args.cli.resolve().parents if parent.suffix == '.app']
    app_command = subprocess.check_output(['ps', '-p', str(args.app_pid), '-o', 'comm='], text=True).strip()
    if not bundles or Path(app_command) != bundles[-1] / 'Contents/MacOS/Harness':
        parser.error('app PID and CLI must belong to the same packaged benchmark app')
    listing = json.loads(cli('ls', '--json'))['sessions']
    if len(listing) != 1:
        parser.error('start with exactly one session in the isolated app home')
    session = listing[0]
    workspace = session['workspace']
    panes = [{'session': session['id'], 'surface': session['tabs'][0]['panes'][0]['surface']}]
    payload = args.out.resolve()/'styled-10000.vt'
    with payload.open('wb') as output:
        for index in range(10000):
            text = f'{index:06d} '+('terminal agent output 0123456789 ' * 3)[:65]
            output.write(f'\x1b[{31+index%7}m{text}\x1b[0m\r\n'.encode())
    filled = 0
    roles = {args.app_pid: 'app', args.daemon_pid: 'daemon', args.host_pid: 'host'}
    for count in (1, 10, 30, 50):
        while len(panes) < count:
            panes.append(json.loads(cli('new', '--json', f'perf-{len(panes)+1}')))
        for index in range(filled, count):
            pane = panes[index]
            cli('select-session', '--workspace', workspace, '--session', pane['session'])
            time.sleep(0.4)
            ready = args.out.resolve()/f'ready-{index+1}.json'
            ready.unlink(missing_ok=True)
            command = shlex.join(['/usr/bin/printf', r'\033[3J\033[2J\033[H'])+'; '+shlex.join(['/bin/cat', str(payload)])+'; '+shlex.join([
                sys.executable, str(Path(__file__).resolve()), '--pane-ready', str(ready)])
            if args.agent_command and index >= 40:
                command += '; '+args.agent_command
            cli('send', '--surface', pane['surface'], '--text', command+'\n')
            deadline = time.monotonic()+20
            while not ready.exists() and time.monotonic() < deadline:
                time.sleep(0.05)
            if not ready.exists():
                raise RuntimeError(f'pane {index+1} did not reach parsing fence')
            grid = json.loads(ready.read_text())
            if (grid['columns'], grid['rows']) != (100, 30):
                raise RuntimeError(f'pane {index+1} has unmatched grid: {grid}')
            (args.out/'sessions.json').write_text(json.dumps(panes, indent=2)+'\n')
        filled = count
        time.sleep(30)
        before = processes(); started = time.monotonic()
        time.sleep(60)
        after = processes(); elapsed = time.monotonic()-started
        descendants = set(roles)
        changed = True
        while changed:
            children = {pid for pid, entry in after.items() if entry['parent'] in descendants}
            changed = not children.issubset(descendants)
            descendants |= children
        records = []
        for pid in sorted(descendants):
            if pid not in after:
                continue
            entry = after[pid]
            records.append({'pid': pid, 'role': roles.get(pid, 'shell-or-agent'),
                            'command': entry['command'], 'rss_bytes': entry['rss_bytes'],
                            'one_core_cpu_percent': 100*(entry['cpu_seconds']-before[pid]['cpu_seconds'])/elapsed if pid in before else None,
                            'phys_footprint_bytes': footprint(pid, args.out/f'footprint-{count}-{pid}.txt')})
        receipt = {'sessions': count, 'agent_processes_requested': 10 if args.agent_command and count == 50 else 0,
                   'settle_seconds': 30, 'sample_seconds': elapsed, 'styled_lines': 10000,
                   'processes': records, 'panes': panes}
        (args.out/f'scale-{count}.json').write_text(json.dumps(receipt, indent=2)+'\n')
        print(json.dumps({'sessions': count, 'receipt': str(args.out/f'scale-{count}.json')}), flush=True)


if __name__ == '__main__':
    main()

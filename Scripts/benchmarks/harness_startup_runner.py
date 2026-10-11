#!/usr/bin/env python3
"""Measure warm GUI reconnect to an already-running, isolated shell.

The pre-armed DSR probe fences parsing, with at most 5 ms polling quantization.
Optional prompt metrics additionally observe a submitted shell-prompt frame;
neither boundary establishes GPU visibility. No normal installation is touched.
"""
import argparse
import json
import os
from pathlib import Path
import shlex
import signal
import subprocess
import time


def wait_until(predicate, seconds=10):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.002)
    raise RuntimeError('startup boundary did not arrive')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app', type=Path, required=True)
    parser.add_argument('--cli', type=Path, required=True)
    parser.add_argument('--home', type=Path, required=True)
    parser.add_argument('--surface', required=True)
    parser.add_argument('--app-pid', type=int, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--label', required=True)
    parser.add_argument('--samples', type=int, default=5)
    parser.add_argument('--prompt-metrics', action='store_true')
    args = parser.parse_args()
    if args.samples < 1:
        parser.error('use a positive sample count')
    executable = args.app.resolve() / 'Contents/MacOS/Harness'
    if args.home.resolve().parent != Path('/tmp').resolve() or not args.home.name.startswith('harness-performance-'):
        parser.error('use an isolated /tmp/harness-performance- home')
    command = subprocess.check_output(['ps', '-p', str(args.app_pid), '-o', 'comm='], text=True).strip()
    if command != str(executable):
        parser.error('app PID does not match the explicit benchmark executable')
    args.out.mkdir(parents=True, exist_ok=True)
    env = {key: value for key, value in os.environ.items() if not key.startswith('HARNESS')}
    env.update(HARNESS_HOME=str(args.home.resolve()), HARNESS_STARTUP_METRICS='1')
    probe = Path(__file__).with_name('startup_ack_runner.py').resolve()
    log = args.home / 'logs/startup.log'
    os.kill(args.app_pid, signal.SIGTERM)
    wait_until(lambda: subprocess.run(['ps', '-p', str(args.app_pid)], capture_output=True).returncode != 0)
    running = None
    try:
        with (args.out / 'startup.jsonl').open('w') as receipts:
            for sample in range(args.samples + 1):
                if running is not None:
                    running.terminate()
                    running.wait(timeout=5)
                ready = args.out.resolve() / f'ready-{sample}.json'
                ready.unlink(missing_ok=True)
                armed = ready.with_suffix('.armed')
                armed.unlink(missing_ok=True)
                text = shlex.join(['/usr/bin/python3', str(probe), str(ready), '100', '30']) + '\n'
                subprocess.run([str(args.cli.resolve()), 'send', '--surface', args.surface, '--text', text],
                               env=env, check=True, capture_output=True)
                wait_until(armed.exists)
                started = time.clock_gettime_ns(time.CLOCK_MONOTONIC_RAW)
                output = (args.out / f'app-{sample}.log').open('wb')
                running = subprocess.Popen([str(executable)], env=env, stdout=output, stderr=subprocess.STDOUT)
                output.close()
                wait_until(ready.exists)
                result = json.loads(ready.read_text())
                result.update(label=args.label, sample=sample, app_pid=running.pid,
                              dsr_ready_ms=(result['ready_ns'] - started) / 1e6,
                              boundary='warm GUI reconnect to pre-armed shell; DSR parsing fence')
                if args.prompt_metrics:
                    wait_until(lambda: log.exists() and 'firstShellPromptFrameSubmitted' in log.read_text())
                    result['shell_prompt_frame_observed_ms'] = (time.clock_gettime_ns(time.CLOCK_MONOTONIC_RAW) - started) / 1e6
                if log.exists():
                    (args.out / f'phases-{sample}.log').write_text(log.read_text())
                receipts.write(json.dumps(result) + '\n')
                receipts.flush()
                print(json.dumps(result), flush=True)
    finally:
        if running is not None and running.poll() is None:
            running.terminate()
            try:
                running.wait(timeout=5)
            except subprocess.TimeoutExpired:
                running.kill()
                running.wait()



if __name__ == '__main__':
    main()

# EnergyLogger Docker test version for MacBook Pro M3 Max

This package lets you test the Docker workflow on Apple Silicon before running on Raspberry Pi 5.

It does **not** read real Raspberry Pi PMIC values. Instead, it uses `fake_pmic_read_adc.sh`, which simulates the output format of:

```bash
vcgencmd pmic_read_adc
```

The purpose is to test:

- Docker build
- experiment loop
- CSV generation
- active flag transitions
- `stress-ng` workload
- Siglent marker call structure, disabled by default
- mounted `/data` output folder

## Build on Mac

```bash
cd energylogger-docker-test
docker build -f Dockerfile -t energylogger-test:latest .
```

## Quick test

```bash
mkdir -p results

docker run --rm -it \
  -v "$PWD/results:/data" \
  -e LOADS="0 50" \
  -e REPEATS="1" \
  -e SAMPLE_PERIODS="1 0.1" \
  -e WORK_DURATION="10s" \
  -e COOLDOWN="2" \
  energylogger-test:latest
```

Afterwards:

```bash
ls -lh results
head results/*.csv
```

You should see CSV files with columns like:

```csv
duration_s,active,VDD_CORE_A current(0),VDD_SOC_A current(1),VDD_DDR_A current(2),VDD_5V volt(8),VDD_3V3 volt(9)
```

The `active` column should be `1` while the workload runs.

## Optional: test marker calls without sending to Siglent

By default, marker calls are printed only:

```text
[sigmark disabled] CH1 -> start,sigmark,1,50,0.1
```

## Optional: enable UDP marker sending

The included `sigmark.sh` is only a placeholder UDP sender. Your real Siglent setup should still use your real `sigmark.sh`.

```bash
docker run --rm -it \
  -v "$PWD/results:/data" \
  -e SIGMARK_ENABLED="1" \
  -e REMOTE_ADDRESS="192.168.50.101:8000" \
  -e LOADS="50" \
  -e REPEATS="1" \
  -e SAMPLE_PERIODS="1" \
  -e WORK_DURATION="5s" \
  -e COOLDOWN="2" \
  energylogger-test:latest
```

## Difference from Raspberry Pi version

Mac version:

- Uses fake PMIC readings.
- Does not require `--privileged`.
- Does not require `--network host`.
- Is safe for workflow testing only.

Raspberry Pi version:

- Should use real `vcgencmd pmic_read_adc`.
- May need `--privileged`, mounted Raspberry Pi device paths, or Raspberry Pi OS userspace tools depending on how `vcgencmd` is available inside the container.

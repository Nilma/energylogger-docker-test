#!/usr/bin/env sh
# Simulates the output format of: vcgencmd pmic_read_adc
# Values vary slightly over time so CSVs are useful for testing parsing/plotting.
awk 'BEGIN {
  srand();
  t=systime()%100;
  c0=0.25 + (t%10)/100.0 + rand()/50.0;
  c1=0.35 + (t%7)/100.0 + rand()/50.0;
  c2=0.18 + (t%5)/100.0 + rand()/60.0;
  v0=5.05 + rand()/100.0;
  v1=3.30 + rand()/100.0;
  printf "VDD_CORE_A current(0)=%.6fA\n", c0;
  printf "VDD_SOC_A current(1)=%.6fA\n", c1;
  printf "VDD_DDR_A current(2)=%.6fA\n", c2;
  printf "VDD_5V volt(8)=%.6fV\n", v0;
  printf "VDD_3V3 volt(9)=%.6fV\n", v1;
}'

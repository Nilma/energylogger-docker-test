FROM debian:bookworm-slim@sha256:<digest>
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends build-essential stress-ng netcat-openbsd ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY pmic_raw_logger.c run_with_logging.c ./
RUN cc -O2 -Wall -Wextra -o /usr/local/bin/pmic_raw_logger pmic_raw_logger.c -lm \
 && cc -O2 -Wall -Wextra -o /usr/local/bin/run_with_logging run_with_logging.c
COPY fake_pmic_read_adc.sh sigmark.sh energylogger.sh /usr/local/bin/
ENV PMIC_CMD="/usr/local/bin/fake_pmic_read_adc.sh" \
    OUT_DIR="/data" \
    SIGMARK_ENABLED="0"
VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/energylogger.sh"]

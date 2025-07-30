SHELL := /bin/bash

all: deploy

deploy:
	./scripts/gen-certs.sh
	./scripts/update-rules.sh
	./scripts/deploy.sh

stop:
	./scripts/stop.sh

backup:
	./config/backup/run-backup.sh

restore:
	./scripts/restore-backup.sh

update-rules:
	./scripts/update-rules.sh

.PHONY: all deploy stop backup restore update-rules

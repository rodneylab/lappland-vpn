#!/usr/bin/env bash
export GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS}
export GOOGLE_PROJECT=${PROJECT_ID}

/usr/bin/env python3 ./engage.py

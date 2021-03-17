#!/usr/bin/env bash

if [ -z "$PROJECT_ID" ]; then
  echo "Please could you set the PROJECT_ID environment variable?  Make sure CREDENTIALS is set too (I haven't checked myself)."
  exit 1
fi

if [ -z "$CREDENTIALS" ]; then
  echo "Did you forget to set the CREDENTIALS environment variable?"
  exit 1
fi

if env | grep -q ^PROJECT_ID=
then
  echo env PROJECT_ID is already exported. Thanks!
else
  echo env PROJECT_ID is now exported.
  export PROJECT_ID
fi

if env | grep -q ^CREDENTIALS=
then
  echo env CREDENTIALS is already exported. Sweet!
else
  echo env CREDENTIALS is now exported.
  export CREDENTIALS
fi

export GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS}
export GOOGLE_PROJECT=${PROJECT_ID}

/usr/bin/env python3 ./engage.py

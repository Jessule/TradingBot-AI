#!/bin/sh
# Put the latest changes on https://laundry-incremental.web.app for everyone.
cd "$(dirname "$0")" && git pull -q && npx -y firebase-tools deploy --only hosting --project laundry-incremental

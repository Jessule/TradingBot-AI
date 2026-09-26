#!/bin/sh
# Private test link with the latest changes (lasts 7 days); the real game is not touched.
cd "$(dirname "$0")" && git pull -q && npx -y firebase-tools hosting:channel:deploy prueba --expires 7d --project laundry-incremental

# Pixel Laundromat on Firebase

The game is `../lavanderia.html`; deploying copies it to `public/index.html`.

Deploy from Google Cloud Shell (project `laundry-incremental`):

    git clone -b claude/laundry-pixel-game-xa8uxo https://github.com/Jessule/TradingBot-AI.git
    cd TradingBot-AI/pixel-laundromat
    npx -y firebase-tools deploy --project laundry-incremental

If it asks you to log in: `npx -y firebase-tools login --no-localhost`, then deploy again.
The game ends up at https://laundry-incremental.web.app

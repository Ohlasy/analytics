[![Build Status](https://travis-ci.org/Ohlasy/analytics.svg?branch=master)](https://travis-ci.org/Ohlasy/analytics)

Skript je napsaný v [Haskellu](https://www.haskell.org), prostředí pro lokální vývoj se dá nainstalovat například takhle:

    $ brew install haskell-stack
    $ stack build
    $ stack execute Analytics

Po přidání commitu na GitHub (ale i bez toho aspoň jednou denně) se rozběhne [Travis](https://travis-ci.org), který kód přeloží a výsledný JSON se seznamem nejčtenějších článků nahraje do kyblíčku na [S3](https://aws.amazon.com/s3/), který je zvenčí vidět jako [data.ohlasy.info](http://data.ohlasy.info/top-articles.json). Odtud si data při každém překladu bere [hlavní web](https://github.com/Ohlasy/web).
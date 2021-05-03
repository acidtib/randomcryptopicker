#!/usr/bin/env node

const fs = require('fs');
const https = require('https');

function fetchSymbols() {
  https.get('https://api.binance.us/api/v3/exchangeInfo', (resp) => {
    const statusCode = resp.statusCode
    let data = '';

    // A chunk of data has been received
    resp.on('data', (chunk) => {
      data += chunk;
    });

    // The whole response has been received
    resp.on('end', () => {
      data = JSON.parse(data)

      saveSymbols(data)
    });

  }).on("error", (err) => {
    console.log("Error: " + err.message);
  });  
}

function saveSymbols(data) {
  let payload = []
  let robinhood = false

  data.symbols.forEach(function(symbol) {
    const baseAsset = symbol.baseAsset
    const quoteAsset = symbol.quoteAsset

    payload.push({
      symbol: `${baseAsset}-${quoteAsset}`,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      exchange: {
        binanceus: true,
        binancecom: false,
        robinhood: false
      }
      
    });
  })

  fs.writeFileSync('symbolPairs.json', JSON.stringify(payload));
}


fetchSymbols()
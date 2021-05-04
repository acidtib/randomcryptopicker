#!/usr/bin/env node

const fs = require('fs');
const https = require('https');

function fetch(url, exchange) {
  https.get(url, (resp) => {
    const statusCode = resp.statusCode
    let data = '';

    // A chunk of data has been received
    resp.on('data', (chunk) => {
      data += chunk;
    });

    // The whole response has been received
    resp.on('end', () => {
      data = JSON.parse(data)

      readSymbols(data, exchange)
    });

  }).on("error", (err) => {
    console.log("Error: " + err.message);
  });
}

function readSymbols(data, exchange) {
  let payload = []
  let robinhood = false
  const filePath = "symbols.json"

  if (fs.existsSync(filePath)) {
    payload = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  }

  let binanceus = false
  let binancecom = false

  switch (exchange) {
    case 'binanceus':
      binanceus = true
      break;
    case 'binancecom':
      binancecom = true
      break;
  }

  data.symbols.forEach(function(symbol) {
    const baseAsset = symbol.baseAsset
    const quoteAsset = symbol.quoteAsset

    payload.push({
      symbol: `${baseAsset}-${quoteAsset}`,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      exchange: {
        binanceus: binanceus,
        binancecom: binancecom,
        robinhood: false
      }
      
    });
  })

  payload = payload.sort(() => Math.random() - 0.5)

  fs.writeFileSync(filePath, JSON.stringify(payload));
}

function deleteFile(filePath) {
  if (fs.existsSync(filePath)) {
    fs.unlink(filePath, (err) => {console.log(err)})
  }
  
}

function fetchSymbols() {
  deleteFile('symbols.json')

  fetch('https://api.binance.us/api/v3/exchangeInfo', 'binanceus')

  fetch('https://api.binance.com/api/v3/exchangeInfo', 'binancecom')
}


fetchSymbols()
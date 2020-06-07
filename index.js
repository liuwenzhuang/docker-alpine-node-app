const express = require('express');

const app = express()

const port = 8085

app.get('/', (req, res) => {
  console.log('get called')
  res.json({
    test: 'testStr'
  })
})

app.listen(port, '0.0.0.0', () => {
  console.log(`server is on http://127.0.0.1:${port}`)
})
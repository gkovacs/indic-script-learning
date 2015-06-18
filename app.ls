require! {
  express
  path
}

app = express()

app.set 'port', (process.env.PORT || 8080)

app.use express.static(path.join(__dirname, ''))

app.listen app.get('port'), '0.0.0.0'

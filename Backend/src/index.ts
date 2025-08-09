import { Hono } from 'hono'
import { cors } from 'hono/cors'
import type { JwtVariables } from 'hono/jwt'
import { prettyJSON } from 'hono/pretty-json'
import { getCategories, getPrice, getPricesfromDB, getSheetUrl } from './controller/apiController'
import { signupCustomer } from './controller/authController'


const app = new Hono<{ Variables: JwtVariables }>()

app.use(prettyJSON())
app.use('/*', cors())

app.get('/', (c) => {
  return c.json({ message: 'Welcome to the API!' })
})
app.use('/get_price', getPrice)
app.use('/get_url', getSheetUrl)
app.use('/get_pricelist', getPricesfromDB)
app.get('/get_categories', getCategories)
app.post('/signup_customer', signupCustomer)

export default {
  port: process.env.PORT || 5000,
  fetch: app.fetch,
  idleTimeout: 255,
};
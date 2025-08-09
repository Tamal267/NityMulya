import { Hono } from 'hono'
import { cors } from 'hono/cors'
import type { JwtVariables } from 'hono/jwt'
import { prettyJSON } from 'hono/pretty-json'
import { getCategories, getPrice, getPricesfromDB, getSheetUrl } from './controller/apiController'
import { login, loginCustomer, loginShopOwner, loginWholesaler, signupCustomer, signupShopOwner, signupWholesaler } from './controller/authController'
import {
  addProductToInventory,
  createOffer,
  getChatMessages,
  getLowStockProducts,
  getShopOrders,
  getWholesalerDashboard,
  getWholesalerInventory,
  getWholesalerOffers,
  updateInventoryItem,
  updateOrderStatus
} from './controller/wholesalerController'
import { checkDatabaseConnection, initializeDatabase } from './db-init'
import { runMigrations } from './migrations'
import { createAuthMiddleware, requireRole } from './utils/jwt'


const app = new Hono<{ Variables: JwtVariables }>()

app.use(prettyJSON())
app.use('/*', cors())

app.get('/', (c) => {
  return c.json({ message: 'Welcome to the API!' })
})
// Existing API routes
app.use('/get_price', getPrice)
app.use('/get_url', getSheetUrl)
app.use('/get_pricelist', getPricesfromDB)
app.get('/get_categories', getCategories)

// Auth routes
app.post('/signup_customer', signupCustomer)
app.post('/signup_wholesaler', signupWholesaler)
app.post('/signup_shop_owner', signupShopOwner)
app.post('/login', login)
app.post('/login_customer', loginCustomer)
app.post('/login_wholesaler', loginWholesaler)
app.post('/login_shop_owner', loginShopOwner)

// Wholesaler routes - protected with authentication
app.use('/wholesaler/*', createAuthMiddleware(), requireRole('wholesaler'))
app.get('/wholesaler/dashboard', getWholesalerDashboard)
app.get('/wholesaler/inventory', getWholesalerInventory)
app.post('/wholesaler/inventory', addProductToInventory)
app.put('/wholesaler/inventory', updateInventoryItem)
app.get('/wholesaler/low-stock', getLowStockProducts)
app.get('/wholesaler/orders', getShopOrders)
app.put('/wholesaler/orders/status', updateOrderStatus)
app.get('/wholesaler/offers', getWholesalerOffers)
app.post('/wholesaler/offers', createOffer)
app.get('/wholesaler/chat', getChatMessages)

// Initialize database on startup
checkDatabaseConnection().then(async (connected) => {
  if (connected) {
    try {
      await initializeDatabase();
      await runMigrations();
    } catch (error) {
      console.error('Failed to initialize database:', error);
    }
  }
});

export default {
  port: process.env.PORT || 5000,
  fetch: app.fetch,
  idleTimeout: 255,
};
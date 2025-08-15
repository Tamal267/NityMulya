import { Hono } from 'hono'
import { cors } from 'hono/cors'
import type { JwtVariables } from 'hono/jwt'
import { prettyJSON } from 'hono/pretty-json'
import { getCategories, getPrice, getPricesfromDB, getSheetUrl } from './controller/apiController'
import { login, loginCustomer, loginShopOwner, loginWholesaler, signupCustomer, signupShopOwner, signupWholesaler } from './controller/authController'
import {
  addProductToInventory as addShopOwnerProduct,
  getChatMessages as getShopOwnerChatMessages,
  getShopOwnerDashboard,
  getShopOwnerInventory,
  getLowStockProducts as getShopOwnerLowStockProducts,
  getShopOrders as getShopOwnerOrders,
  updateInventoryItem as updateShopOwnerInventoryItem
} from './controller/shopOwnerController'
import {
  addProductToInventory as addWholesalerProduct,
  createOffer,
  getChatMessages as getWholesalerChatMessages,
  getWholesalerDashboard,
  getWholesalerInventory,
  getLowStockProducts as getWholesalerLowStockProducts,
  getWholesalerOffers,
  getShopOrders as getWholesalerShopOrders,
  updateOrderStatus,
  updateInventoryItem as updateWholesalerInventoryItem
} from './controller/wholesalerController'
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
app.post('/wholesaler/inventory', addWholesalerProduct)
app.put('/wholesaler/inventory', updateWholesalerInventoryItem)
app.get('/wholesaler/low-stock', getWholesalerLowStockProducts)
app.get('/wholesaler/orders', getWholesalerShopOrders)
app.put('/wholesaler/orders/status', updateOrderStatus)
app.get('/wholesaler/offers', getWholesalerOffers)
app.post('/wholesaler/offers', createOffer)
app.get('/wholesaler/chat', getWholesalerChatMessages)

// Shop Owner routes (protected)
app.use('/shop-owner/*', createAuthMiddleware(), requireRole('shop_owner'))
app.get('/shop-owner/dashboard', getShopOwnerDashboard)
app.get('/shop-owner/inventory', getShopOwnerInventory)
app.post('/shop-owner/inventory', addShopOwnerProduct)
app.put('/shop-owner/inventory', updateShopOwnerInventoryItem)
app.get('/shop-owner/low-stock', getShopOwnerLowStockProducts)
app.get('/shop-owner/orders', getShopOwnerOrders)
app.get('/shop-owner/chat', getShopOwnerChatMessages)

export default {
  port: process.env.PORT || 5000,
  fetch: app.fetch,
  idleTimeout: 255,
};
import { GoogleGenerativeAI } from "@google/generative-ai";
import fetch from "node-fetch";
import * as XLSX from "xlsx"; // Import the xlsx library
import sql from "../db";

const GoogleApiKey = process.env.GOOGLE_API_KEY;

const genAI = new GoogleGenerativeAI(GoogleApiKey ? GoogleApiKey : "");

export const getSheetUrl = async (c: any) => {
  try {
    const response = await fetch(
      "https://tcb.gov.bd/api/datatable/daily_rmp_view.php?domain_id=6383&lang=bn&subdomain=tcb.portal.gov.bd&content_type=daily_rmp"
    );
    if (!response.ok) {
      // Return a 500 error if the API request fails
      return c.json({ error: "Failed to fetch the sheet URL" }, 500);
    }

    const data: any = await response.json();
    const htmlString = data.data[0][4];
    const regex = /href="(.*?)"/;
    const match = htmlString.match(regex);

    if (match) {
      const url = "http:" + match[1];
      return c.json({ url });
    } else {
      // Return a 404 error if the URL is not found in the HTML string
      return c.json({ error: "URL not found in the HTML string" }, 404);
    }
  } catch (error) {
    // Handle any other errors that may occur
    console.error("Error:", error);
    return c.json(
      { error: "An error occurred while processing the request" },
      500
    );
  }
};

const prompt = `
give me the json format of unit, max price and min price of each subtopics under topics: 

চাল:
চাল সরু (নাজির/মিনিকেট)
চাল (মাঝারী)পাইজাম/আটাশ 
চাল (মোটা)/স্বর্ণা/চায়না ইরি

আটা/ময়দা:
আটা সাদা (খোলা)
আটা (প্যাকেট)
ময়দা (খোলা)
ময়দা (প্যাকেট)

ভোজ্য তেল:
সয়াবিন তেল (লুজ)
সয়াবিন তেল (বোতল)
সয়াবিন তেল (বোতল)
সয়াবিন তেল (বোতল)
পাম অয়েল (লুজ)
সুপার পাম অয়েল (লুজ)
রাইস ব্রান তেল (বোতল)

ডাল:
মশুর ডাল (বড় দানা)
মশুর ডাল (মাঝারী দানা)
মশুর ডাল (ছোট দানা)
মুগ ডাল (মানভেদে)
এ্যাংকর ডাল
ছোলা (মানভেদে)
আলু (মানভেদে)

মসলা:
পিঁয়াজ (দেশী)
পিঁয়াজ (আমদানি)
রসুন (দেশী) 
রসুন (আমদানি)
শুকনা মরিচ (দেশী)
শুকনা মরিচ (আমদানি)
হলুদ (দেশী)
হলুদ (আমদানি)
আদা (দেশী)
আদা (আমদানি)
জিরা
দারুচিনি
লবঙ্গ
এলাচ(ছোট)
ধনে
তেজপাতা

মাছ ও গোশত:
রুই
ইলিশ
গরু 
খাসী 
মুরগী(ব্রয়লার)
মুরগী (দেশী)

গুড়া দুধ(প্যাকেটজাত):
ডানো 
ডিপ্লোমা (নিউজিল্যান্ড)
ফ্রেশ
মার্কস

চিনি:
চিনি                                

খেজুর:
খেজুর(সাধারণ মানের)

লবণ:
লবণ(প্যাঃ)আয়োডিনযুক্ত

ডিম:
ডিম (ফার্ম)


example: 
{
    "চাল": {
        "চাল সরু (নাজির/মিনিকেট)": {
            "unit": "প্রতি কেজি",
            "max_price": 85,
            "min_price": 75
        },
        "চাল (মাঝারী)পাইজাম/আটাশ": {
            "unit": "প্রতি কেজি",
            "max_price": 75,
            "min_price": 60
        },
        "চাল (মোটা)/স্বর্ণা/চায়না ইরি": {
            "unit": "প্রতি কেজি",
            "max_price": 60,
            "min_price": 55
        }
    },
    "আটা/ময়দা": {
        "আটা সাদা (খোলা)": {
            "unit": "প্রতি কেজি",
            "max_price": 45,
            "min_price": 40
        },
        "আটা (প্যাকেট)": {
            "unit": "প্রতি কেজি প্যাঃ",
            "max_price": 55,
            "min_price": 50
        },
        "ময়দা (খোলা)": {
            "unit": "প্রতি কেজি",
            "max_price": 65,
            "min_price": 50
        },
        "ময়দা (প্যাকেট)": {
            "unit": "প্রতি কেজি প্যাঃ",
            "max_price": 70,
            "min_price": 65
        }
    },
    "ভোজ্য তেল": {
        "সয়াবিন তেল (লুজ)": {
            "unit": "প্রতি লিটার",
            "max_price": 172,
            "min_price": 162
        },
        "সয়াবিন তেল (বোতল) 5 লিটার": {
            "unit": "৫ লিটার",
            "max_price": 920,
            "min_price": 890
        },
        "সয়াবিন তেল (বোতল) 2 লিটার": {
            "unit": "2 লিটার",
            "max_price": 378,
            "min_price": 375
        },
        "সয়াবিন তেল (বোতল) 1 লিটার": {
            "unit": "১ লিটার",
            "max_price": 190,
            "min_price": 185
        },
        "পাম অয়েল (লুজ)": {
            "unit": "প্রতি লিটার",
            "max_price": 160,
            "min_price": 150
        },
        "সুপার পাম অয়েল (লুজ)": {
            "unit": "প্রতি লিটার",
            "max_price": 163,
            "min_price": 152
        },
        "রাইস ব্রান তেল (বোতল)": {
            "unit": "৫ লিটার",
            "max_price": 1080,
            "min_price": 1030
        }
    },
    "ডাল": {
        "মশুর ডাল (বড় দানা)": {
            "unit": "প্রতি কেজি",
            "max_price": 110,
            "min_price": 95
        },
        "মশুর ডাল (মাঝারী দানা)": {
            "unit": "প্রতি কেজি",
            "max_price": 135,
            "min_price": 110
        },
        "মশুর ডাল (ছোট দানা)": {
            "unit": "প্রতি কেজি",
            "max_price": 155,
            "min_price": 150
        },
        "মুগ ডাল (মানভেদে)": {
            "unit": "প্রতি কেজি",
            "max_price": 180,
            "min_price": 120
        },
        "এ্যাংকর ডাল": {
            "unit": "প্রতি কেজি",
            "max_price": 80,
            "min_price": 60
        },
        "ছোলা (মানভেদে)": {
            "unit": "প্রতি কেজি",
            "max_price": 110,
            "min_price": 90
        },
        "আলু (মানভেদে)": {
            "unit": "প্রতি কেজি",
            "max_price": 30,
            "min_price": 20
        }
    },
    "মসলা": {
        "পিঁয়াজ (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": 85,
            "min_price": 75
        },
        "পিঁয়াজ (আমদানি)": {
            "unit": "প্রতি কেজি",
            "max_price": null,
            "min_price": null
        },
        "রসুন (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": 160,
            "min_price": 80
        },
        "রসুন (আমদানি)": {
            "unit": "প্রতি কেজি",
            "max_price": 220,
            "min_price": 160
        },
        "শুকনা মরিচ (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": 350,
            "min_price": 240
        },
        "শুকনা মরিচ (আমদানি)": {
            "unit": "প্রতি কেজি",
            "max_price": 450,
            "min_price": 300
        },
        "হলুদ (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": 400,
            "min_price": 300
        },
        "হলুদ (আমদানি)": {
            "unit": "প্রতি কেজি",
            "max_price": 420,
            "min_price": 300
        },
        "আদা (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": null,
            "min_price": null
        },
        "আদা (আমদানি)": {
            "unit": "প্রতি কেজি",
            "max_price": 280,
            "min_price": 180
        },
        "জিরা": {
            "unit": "প্রতি কেজি",
            "max_price": 750,
            "min_price": 600
        },
        "দারুচিনি": {
            "unit": "প্রতি কেজি",
            "max_price": 600,
            "min_price": 500
        },
        "লবঙ্গ": {
            "unit": "প্রতি কেজি",
            "max_price": 1600,
            "min_price": 1400
        },
        "এলাচ(ছোট)": {
            "unit": "প্রতি কেজি",
            "max_price": 5200,
            "min_price": 4500
        },
        "ধনে": {
            "unit": "প্রতি কেজি",
            "max_price": 280,
            "min_price": 180
        },
        "তেজপাতা": {
            "unit": "প্রতি কেজি",
            "max_price": 220,
            "min_price": 180
        }
    },
    "মাছ ও গোশত": {
        "রুই": {
            "unit": "প্রতি কেজি",
            "max_price": 450,
            "min_price": 300
        },
        "ইলিশ": {
            "unit": "প্রতি কেজি",
            "max_price": 2000,
            "min_price": 800
        },
        "গরু": {
            "unit": "প্রতি কেজি",
            "max_price": 800,
            "min_price": 750
        },
        "খাসী": {
            "unit": "প্রতি কেজি",
            "max_price": 1250,
            "min_price": 1100
        },
        "মুরগী(ব্রয়লার)": {
            "unit": "প্রতি কেজি",
            "max_price": 170,
            "min_price": 160
        },
        "মুরগী (দেশী)": {
            "unit": "প্রতি কেজি",
            "max_price": 700,
            "min_price": 580
        }
    },
    "গুড়া দুধ(প্যাকেটজাত)": {
        "ডানো": {
            "unit": "১ কেজি",
            "max_price": 860,
            "min_price": 720
        },
        "ডিপ্লোমা (নিউজিল্যান্ড)": {
            "unit": "১ কেজি",
            "max_price": 910,
            "min_price": 840
        },
        "ফ্রেশ": {
            "unit": "১ কেজি",
            "max_price": 890,
            "min_price": 830
        },
        "মার্কস": {
            "unit": "১ কেজি",
            "max_price": 900,
            "min_price": 830
        }
    },
    "চিনি": {
        "চিনি": {
            "unit": "প্রতি কেজি",
            "max_price": 115,
            "min_price": 105
        }
    },
    "খেজুর": {
        "খেজুর(সাধারণ মানের)": {
            "unit": "প্রতি কেজি",
            "max_price": 550,
            "min_price": 220
        }
    },
    "লবণ": {
        "লবণ(প্যাঃ)আয়োডিনযুক্ত": {
            "unit": "প্রতি কেজি",
            "max_price": 42,
            "min_price": 38
        }
    },
    "ডিম": {
        "ডিম (ফার্ম)": {
            "unit": "প্রতি হালি",
            "max_price": 48,
            "min_price": 40
        }
    }
}`;

export const getPrice = async (c: any) => {
  try {
    const getUrlResponse = await getSheetUrl(c);
    if (getUrlResponse.status === 200) {
      const responseData = await getUrlResponse.json();
      const { url } = responseData;
      const response = await fetch(url);
      if (!response.ok) {
        // Return a 500 error if the file download fails
        return c.json({ error: "Failed to download the file" }, 500);
      }

      const arrayBuffer = await response.arrayBuffer();

      const workbook = XLSX.read(arrayBuffer, { type: "array" });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];

      const fileContent = XLSX.utils.sheet_to_csv(worksheet);

      const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });

      const result = await model.generateContent([prompt, fileContent]);
      let geminiResponse = result.response.text();

      geminiResponse = geminiResponse.trim();
      if (geminiResponse.startsWith("```json")) {
        geminiResponse = geminiResponse.slice(7).trim(); // Remove '```json' prefix
      }
      if (geminiResponse.endsWith("```")) {
        geminiResponse = geminiResponse.slice(0, -3);
      }
      geminiResponse = geminiResponse.trim();

      const jsonData = JSON.parse(geminiResponse);

      for (const topic in jsonData) {
        try {
          for (const subtopic in jsonData[topic]) {
            const { unit, max_price, min_price } = jsonData[topic][subtopic];
            const subtopicData = await sql`
                 UPDATE subcategories
                 SET unit = ${unit}, max_price = ${max_price}, min_price = ${min_price}, created_at = NOW()
                 WHERE subcat_name = ${subtopic}
                 RETURNING id
               `;
          }
        } catch (error) {
          console.error("Error inserting price data:", error);
          return c.json({ error: "Failed to insert price data" }, 500);
        }
      }

      return c.json(jsonData);
    } else {
      // Return error if getSheetUrl failed
      return c.json(
        { error: "Failed to get sheet URL" },
        getUrlResponse.status
      );
    }
  } catch (error) {
    // Handle any other errors that may occur
    console.error("Error:", error);
    return c.json(
      { error: "An error occurred while processing the request" },
      500
    );
  }
};

export const getPricesfromDB = async (c: any) => {
  try {
    let pricelist = await sql`select c.cat_name, sc.* from subcategories sc
        join categories c on sc.cat_id = c.id
        order by c.cat_name`;

    // if day of created_at is today, then call getPrice function to update prices and then return pricelist
    const today = new Date();
    const todayString = today.toISOString().split("T")[0]; // Get today's date in YYYY-MM-DD format

    const lastUpdated = pricelist[0]?.created_at
      ? new Date(pricelist[0].created_at)
      : null;
    if (
      lastUpdated &&
      lastUpdated.toISOString().split("T")[0] === todayString
    ) {
      console.log("Prices already updated today, returning cached pricelist");
      return c.json(pricelist);
    }

    await getPrice(c);
    pricelist = await sql`select c.cat_name, sc.* from subcategories sc
        join categories c on sc.cat_id = c.id
        order by c.cat_name`;

    if (pricelist.length === 0) {
      return c.json({ message: "No prices found" }, 404);
    }
    return c.json(pricelist);
  } catch (error) {
    console.error("Error fetching prices:", error);
    return c.json({ error: "Failed to fetch prices" }, 500);
  }
};

export const getCategories = async (c: any) => {
  try {
    const categories = await sql`SELECT * FROM categories`;
    if (categories.length === 0) {
      return c.json({ message: "No categories found" }, 404);
    }
    return c.json(categories);
  } catch (error) {
    console.error("Error fetching categories:", error);
    return c.json({ error: "Failed to fetch categories" }, 500);
  }
};

// Get all shop owners with their inventory
export const getShops = async (c: any) => {
  try {
    // First check what columns exist in shop_owners table
    const shops = await sql`
      SELECT 
        so.id,
        so.full_name as name,
        so.contact as phone,
        so.address,
        so.latitude,
        so.longitude,
        so.created_at
      FROM shop_owners so
      ORDER BY so.full_name
    `;

    if (shops.length === 0) {
      return c.json({ message: "No shops found" }, 404);
    }

    return c.json(shops);
  } catch (error) {
    console.error("Error fetching shops:", error);
    return c.json({ error: "Failed to fetch shops" }, 500);
  }
};

// Get shops that have a specific product available (from shop inventory)
// Get shops by product name (legacy endpoint)
export const getShopsByProduct = async (c: any) => {
  try {
    const { productName } = c.req.param();

    if (!productName) {
      return c.json({ error: "Product name is required" }, 400);
    }

    const shops = await sql`
      SELECT 
        so.id,
        so.full_name as name,
        so.contact as phone,
        so.address,
        so.latitude,
        so.longitude,
        si.unit_price,
        si.stock_quantity,
        si.low_stock_threshold,
        sc.unit,
        sc.subcat_name as product_name,
        sc.min_price,
        sc.max_price
      FROM shop_owners so
      JOIN shop_inventory si ON si.shop_owner_id = so.id
      JOIN subcategories sc ON si.subcat_id = sc.id
      WHERE sc.subcat_name ILIKE ${`%${productName}%`}
        AND si.is_active = true
        AND si.stock_quantity > 0
      ORDER BY si.unit_price ASC
    `;

    if (shops.length === 0) {
      return c.json({ message: "No shops found with this product" }, 404);
    }

    return c.json(shops);
  } catch (error) {
    console.error("Error fetching shops by product:", error);
    return c.json({ error: "Failed to fetch shops" }, 500);
  }
};

// Get shops by subcategory ID (new preferred endpoint)
export const getShopsBySubcategoryId = async (c: any) => {
  try {
    const { subcatId } = c.req.param();

    if (!subcatId) {
      return c.json({ error: "Subcategory ID is required" }, 400);
    }

    const shops = await sql`
      SELECT 
        so.id,
        so.full_name as name,
        so.contact as phone,
        so.address,
        so.latitude,
        so.longitude,
        si.unit_price,
        si.stock_quantity,
        si.low_stock_threshold,
        sc.unit,
        sc.subcat_name as product_name,
        sc.min_price,
        sc.max_price
      FROM shop_owners so
      JOIN shop_inventory si ON si.shop_owner_id = so.id
      JOIN subcategories sc ON si.subcat_id = sc.id
      WHERE sc.id = ${subcatId}
        AND si.is_active = true
        AND si.stock_quantity > 0
      ORDER BY si.unit_price ASC
    `;

    if (shops.length === 0) {
      return c.json({ message: "No shops found with this product" }, 404);
    }

    return c.json(shops);
  } catch (error) {
    console.error("Error fetching shops by product:", error);
    return c.json({ error: "Failed to fetch shops by product" }, 500);
  }
};

// Get product price history (mock data for now)
export const getProductPriceHistory = async (c: any) => {
  try {
    const { productName } = c.req.param();

    if (!productName) {
      return c.json({ error: "Product name is required" }, 400);
    }

    // Get current prices
    const currentPrices = await sql`
      SELECT min_price, max_price, unit
      FROM subcategories
      WHERE subcat_name = ${productName}
      LIMIT 1
    `;

    if (currentPrices.length === 0) {
      return c.json({ message: "Product not found" }, 404);
    }

    const { min_price, max_price, unit } = currentPrices[0];

    // Generate mock price history for the last 7 days
    const today = new Date();
    const priceHistory = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);

      // Generate slight variations in price
      const variation = (Math.random() - 0.5) * 0.1; // ±5% variation
      const mockMinPrice = Math.round(min_price * (1 + variation));
      const mockMaxPrice = Math.round(max_price * (1 + variation));

      priceHistory.push({
        date: date.toISOString().split("T")[0],
        min_price: mockMinPrice,
        max_price: mockMaxPrice,
        unit: unit,
      });
    }

    return c.json({
      product_name: productName,
      unit: unit,
      price_history: priceHistory,
    });
  } catch (error) {
    console.error("Error fetching price history:", error);
    return c.json({ error: "Failed to fetch price history" }, 500);
  }
};

// Initialize sample shop inventory data for testing
export const initializeSampleData = async (c: any) => {
  try {
    // First create the chat_messages table if it doesn't exist
    await sql`
      CREATE TABLE IF NOT EXISTS chat_messages (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        sender_id UUID NOT NULL,
        sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('shop_owner', 'wholesaler')),
        receiver_id UUID NOT NULL,
        receiver_type VARCHAR(20) NOT NULL CHECK (receiver_type IN ('shop_owner', 'wholesaler')),
        message TEXT NOT NULL,
        message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // Create chat message indexes
    await sql`CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender_id, sender_type)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_chat_messages_receiver ON chat_messages(receiver_id, receiver_type)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(sender_id, receiver_id, created_at)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_chat_messages_unread ON chat_messages(receiver_id, is_read, created_at)`;

    // First create the shop_inventory table if it doesn't exist
    await sql`
      CREATE TABLE IF NOT EXISTS shop_inventory (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
        subcat_id UUID REFERENCES subcategories(id) ON DELETE CASCADE,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        unit_price DECIMAL(10, 2) NOT NULL,
        low_stock_threshold INTEGER DEFAULT 10,
        is_active BOOLEAN DEFAULT TRUE,
        UNIQUE(shop_owner_id, subcat_id)
      )
    `;

    // Create indexes for better performance
    await sql`CREATE INDEX IF NOT EXISTS idx_shop_inventory_shop_owner ON shop_inventory (shop_owner_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_shop_inventory_subcat ON shop_inventory (subcat_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_shop_inventory_active ON shop_inventory (is_active)`;

    // Check if shop_owners table has the name column, if not add it
    try {
      await sql`ALTER TABLE shop_owners ADD COLUMN IF NOT EXISTS name VARCHAR(100)`;
    } catch (error) {
      console.log(
        "Name column might already exist or table structure is different"
      );
    }

    // Now ensure we have shop owners
    await sql`
      INSERT INTO shop_owners (full_name, email, password, contact, address, latitude, longitude) VALUES 
      ('রহমান গ্রোসারি', 'rahman.grocery@example.com', 'password123', '01711123456', 'ধানমন্ডি-৩২, ঢাকা', 23.7465, 90.3763),
      ('করিম স্টোর', 'karim.store@example.com', 'password123', '01812345678', 'গুলশান-১, ঢাকা', 23.7925, 90.4078),
      ('নিউ মার্কেট শপ', 'newmarket.shop@example.com', 'password123', '01913456789', 'নিউমার্কেট, ঢাকা', 23.7275, 90.3854),
      ('ফ্রেশ মার্ট', 'fresh.mart@example.com', 'password123', '01615678901', 'উত্তরা-৭, ঢাকা', 23.8759, 90.3795)
      ON CONFLICT (email) DO NOTHING
    `;

    // Add sample wholesalers for chat testing
    await sql`
      INSERT INTO wholesalers (full_name, email, password, contact, address, latitude, longitude) VALUES 
      ('রহমান ট্রেডার্স', 'rahman.traders@example.com', 'password123', '01711123456', 'কাওরান বাজার, ঢাকা', 23.7465, 90.3863),
      ('করিম এন্টারপ্রাইজ', 'karim.enterprise@example.com', 'password123', '01812345678', 'চকবাজার, ঢাকা', 23.7225, 90.4078),
      ('আলম ইমপোর্ট', 'alam.import@example.com', 'password123', '01913456789', 'সদরঘাট, ঢাকা', 23.7175, 90.4154),
      ('নিউ সুন্দরবন', 'new.sundarban@example.com', 'password123', '01615678901', 'বাবুবাজার, ঢাকা', 23.7259, 90.3995),
      ('বাংলা ট্রেডিং', 'bangla.trading@example.com', 'password123', '01516789012', 'মৌলভীবাজার, ঢাকা', 23.7365, 90.4063),
      ('ঢাকা হোলসেল', 'dhaka.wholesale@example.com', 'password123', '01717890123', 'গুলিস্তান, ঢাকা', 23.7265, 90.4163)
      ON CONFLICT (email) DO NOTHING
    `;

    // Add sample inventory data for চাল সরু (নাজির/মিনিকেট)
    await sql`
      INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
      SELECT so.id, sc.id, 150, 78.00, 20, true
      FROM shop_owners so, subcategories sc 
      WHERE so.email = 'rahman.grocery@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
      ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
          stock_quantity = EXCLUDED.stock_quantity,
          unit_price = EXCLUDED.unit_price,
          updated_at = CURRENT_TIMESTAMP
    `;

    await sql`
      INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
      SELECT so.id, sc.id, 200, 80.00, 25, true
      FROM shop_owners so, subcategories sc 
      WHERE so.email = 'karim.store@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
      ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
          stock_quantity = EXCLUDED.stock_quantity,
          unit_price = EXCLUDED.unit_price,
          updated_at = CURRENT_TIMESTAMP
    `;

    await sql`
      INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
      SELECT so.id, sc.id, 80, 82.00, 15, true
      FROM shop_owners so, subcategories sc 
      WHERE so.email = 'newmarket.shop@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
      ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
          stock_quantity = EXCLUDED.stock_quantity,
          unit_price = EXCLUDED.unit_price,
          updated_at = CURRENT_TIMESTAMP
    `;

    // Add sample data for আটা সাদা (খোলা)
    await sql`
      INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
      SELECT so.id, sc.id, 75, 42.00, 10, true
      FROM shop_owners so, subcategories sc 
      WHERE so.email = 'rahman.grocery@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
      ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
          stock_quantity = EXCLUDED.stock_quantity,
          unit_price = EXCLUDED.unit_price,
          updated_at = CURRENT_TIMESTAMP
    `;

    await sql`
      INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
      SELECT so.id, sc.id, 60, 44.00, 8, true
      FROM shop_owners so, subcategories sc 
      WHERE so.email = 'karim.store@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
      ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
          stock_quantity = EXCLUDED.stock_quantity,
          unit_price = EXCLUDED.unit_price,
          updated_at = CURRENT_TIMESTAMP
    `;

    return c.json({
      message: "Sample shop inventory data initialized successfully!",
    });
  } catch (error) {
    console.error("Error initializing sample data:", error);
    return c.json({ error: "Failed to initialize sample data" }, 500);
  }
};

// Chat functionality

// Get all wholesalers for chat search
export const getWholesalers = async (c: any) => {
  try {
    const { search } = c.req.query();

    let wholesalers;
    if (search) {
      wholesalers = await sql`
        SELECT id, full_name, email, contact, address, created_at
        FROM wholesalers
        WHERE full_name ILIKE ${`%${search}%`} 
           OR email ILIKE ${`%${search}%`}
           OR contact ILIKE ${`%${search}%`}
        ORDER BY full_name
        LIMIT 20
      `;
    } else {
      wholesalers = await sql`
        SELECT id, full_name, email, contact, address, created_at
        FROM wholesalers
        ORDER BY full_name
        LIMIT 50
      `;
    }

    if (wholesalers.length === 0) {
      return c.json({ message: "No wholesalers found" }, 404);
    }

    return c.json(wholesalers);
  } catch (error) {
    console.error("Error fetching wholesalers:", error);
    return c.json({ error: "Failed to fetch wholesalers" }, 500);
  }
};

// Send a chat message
export const sendMessage = async (c: any) => {
  try {
    const {
      sender_id,
      sender_type,
      receiver_id,
      receiver_type,
      message,
      message_type = "text",
    } = await c.req.json();

    if (
      !sender_id ||
      !sender_type ||
      !receiver_id ||
      !receiver_type ||
      !message
    ) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    if (
      !["shop_owner", "wholesaler"].includes(sender_type) ||
      !["shop_owner", "wholesaler"].includes(receiver_type)
    ) {
      return c.json({ error: "Invalid sender or receiver type" }, 400);
    }

    const newMessage = await sql`
      INSERT INTO chat_messages (sender_id, sender_type, receiver_id, receiver_type, message, message_type)
      VALUES (${sender_id}, ${sender_type}, ${receiver_id}, ${receiver_type}, ${message}, ${message_type})
      RETURNING *
    `;

    return c.json({
      success: true,
      message: "Message sent successfully",
      data: newMessage[0],
    });
  } catch (error) {
    console.error("Error sending message:", error);
    return c.json({ error: "Failed to send message" }, 500);
  }
};

// Get chat messages between two users
export const getChatMessages = async (c: any) => {
  try {
    const { user1_id, user1_type, user2_id, user2_type } = c.req.query();

    if (!user1_id || !user1_type || !user2_id || !user2_type) {
      return c.json({ error: "Missing required parameters" }, 400);
    }

    const messages = await sql`
      SELECT 
        cm.*,
        CASE 
          WHEN cm.sender_type = 'shop_owner' THEN so.full_name
          WHEN cm.sender_type = 'wholesaler' THEN w.full_name
        END as sender_name,
        CASE 
          WHEN cm.receiver_type = 'shop_owner' THEN so2.full_name
          WHEN cm.receiver_type = 'wholesaler' THEN w2.full_name
        END as receiver_name
      FROM chat_messages cm
      LEFT JOIN shop_owners so ON cm.sender_id::uuid = so.id AND cm.sender_type = 'shop_owner'
      LEFT JOIN wholesalers w ON cm.sender_id::uuid = w.id AND cm.sender_type = 'wholesaler'
      LEFT JOIN shop_owners so2 ON cm.receiver_id::uuid = so2.id AND cm.receiver_type = 'shop_owner'
      LEFT JOIN wholesalers w2 ON cm.receiver_id::uuid = w2.id AND cm.receiver_type = 'wholesaler'
      WHERE 
        (cm.sender_id = ${user1_id} AND cm.sender_type = ${user1_type} AND 
         cm.receiver_id = ${user2_id} AND cm.receiver_type = ${user2_type})
        OR
        (cm.sender_id = ${user2_id} AND cm.sender_type = ${user2_type} AND 
         cm.receiver_id = ${user1_id} AND cm.receiver_type = ${user1_type})
      ORDER BY cm.created_at ASC
    `;

    // Mark messages as read for the current user
    await sql`
      UPDATE chat_messages 
      SET is_read = true, updated_at = CURRENT_TIMESTAMP
      WHERE receiver_id = ${user1_id} AND receiver_type = ${user1_type}
        AND sender_id = ${user2_id} AND sender_type = ${user2_type}
        AND is_read = false
    `;

    return c.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    console.error("Error fetching chat messages:", error);
    return c.json({ error: "Failed to fetch chat messages" }, 500);
  }
};

// Get chat conversations for a user
export const getChatConversations = async (c: any) => {
  try {
    const { user_id, user_type } = c.req.query();

    if (!user_id || !user_type) {
      return c.json({ error: "Missing required parameters" }, 400);
    }

    const conversations = await sql`
      WITH latest_messages AS (
        SELECT DISTINCT ON (
          CASE 
            WHEN sender_id = ${user_id} AND sender_type = ${user_type} THEN receiver_id || '_' || receiver_type
            ELSE sender_id || '_' || sender_type
          END
        )
        CASE 
          WHEN sender_id = ${user_id} AND sender_type = ${user_type} THEN receiver_id
          ELSE sender_id
        END as contact_id,
        CASE 
          WHEN sender_id = ${user_id} AND sender_type = ${user_type} THEN receiver_type
          ELSE sender_type
        END as contact_type,
        message,
        created_at,
        sender_id = ${user_id} AND sender_type = ${user_type} as is_from_me
        FROM chat_messages
        WHERE (sender_id = ${user_id} AND sender_type = ${user_type})
           OR (receiver_id = ${user_id} AND receiver_type = ${user_type})
        ORDER BY 
          CASE 
            WHEN sender_id = ${user_id} AND sender_type = ${user_type} THEN receiver_id || '_' || receiver_type
            ELSE sender_id || '_' || sender_type
          END,
          created_at DESC
      ),
      unread_counts AS (
        SELECT 
          sender_id as contact_id,
          sender_type as contact_type,
          COUNT(*) as unread_count
        FROM chat_messages
        WHERE receiver_id = ${user_id} AND receiver_type = ${user_type} AND is_read = false
        GROUP BY sender_id, sender_type
      )
      SELECT 
        lm.*,
        COALESCE(uc.unread_count, 0) as unread_count,
        CASE 
          WHEN lm.contact_type = 'shop_owner' THEN so.full_name
          WHEN lm.contact_type = 'wholesaler' THEN w.full_name
        END as contact_name,
        CASE 
          WHEN lm.contact_type = 'shop_owner' THEN so.contact
          WHEN lm.contact_type = 'wholesaler' THEN w.contact
        END as contact_phone
      FROM latest_messages lm
      LEFT JOIN unread_counts uc ON lm.contact_id = uc.contact_id AND lm.contact_type = uc.contact_type
      LEFT JOIN shop_owners so ON lm.contact_id::uuid = so.id AND lm.contact_type = 'shop_owner'
      LEFT JOIN wholesalers w ON lm.contact_id::uuid = w.id AND lm.contact_type = 'wholesaler'
      ORDER BY lm.created_at DESC
    `;

    return c.json({
      success: true,
      data: conversations,
    });
  } catch (error) {
    console.error("Error fetching chat conversations:", error);
    return c.json({ error: "Failed to fetch chat conversations" }, 500);
  }
};

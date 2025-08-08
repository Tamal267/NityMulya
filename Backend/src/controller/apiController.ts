import { GoogleGenerativeAI } from '@google/generative-ai';
import { Hono } from 'hono';
import fetch from 'node-fetch';
import * as XLSX from 'xlsx'; // Import the xlsx library
import sql from '../db';

const GoogleApiKey = process.env.GOOGLE_API_KEY

const genAI = new GoogleGenerativeAI(GoogleApiKey ? GoogleApiKey : '')

const app = new Hono()

export const getSheetUrl = async (c: any) => {
  try {
    const response = await fetch(
      'https://tcb.gov.bd/api/datatable/daily_rmp_view.php?domain_id=6383&lang=bn&subdomain=tcb.portal.gov.bd&content_type=daily_rmp',
    )
    if (!response.ok) {
      // Return a 500 error if the API request fails
      return c.json({ error: 'Failed to fetch the sheet URL' }, 500)
    }

    const data: any = await response.json()
    const htmlString = data.data[0][4]
    const regex = /href="(.*?)"/
    const match = htmlString.match(regex)

    if (match) {
      const url = "http:" + match[1]
      return c.json({ url })
    } else {
      // Return a 404 error if the URL is not found in the HTML string
      return c.json({ error: 'URL not found in the HTML string' }, 404)
    }

  } catch (error) {
    // Handle any other errors that may occur
    console.error('Error:', error)
    return c.json(
      { error: 'An error occurred while processing the request' },
      500,
    )
  }
}

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
}`

export const getPrice = async (c: any) => {
  try {
    const getUrlResponse = await getSheetUrl(c)
    if (getUrlResponse.status === 200) {
      const responseData = await getUrlResponse.json()
      const { url } = responseData
      const response = await fetch(url)
      if (!response.ok) {
        // Return a 500 error if the file download fails
        return c.json({ error: 'Failed to download the file' }, 500)
      }

      const arrayBuffer = await response.arrayBuffer()

      const workbook = XLSX.read(arrayBuffer, { type: 'array' })
      const sheetName = workbook.SheetNames[0]
      const worksheet = workbook.Sheets[sheetName]

      const fileContent = XLSX.utils.sheet_to_csv(worksheet)

      const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' })

      const result = await model.generateContent([prompt, fileContent])
      let geminiResponse = result.response.text()

      geminiResponse = geminiResponse.trim()
      if (geminiResponse.startsWith('```json')) {
        geminiResponse = geminiResponse.slice(7).trim() // Remove '```json' prefix
      }
      if (geminiResponse.endsWith('```')) {
        geminiResponse = geminiResponse.slice(0, -3)
      }
      geminiResponse = geminiResponse.trim()

      const jsonData = JSON.parse(geminiResponse)

      for (const topic in jsonData) {
        try {
            for (const subtopic in jsonData[topic]) {
                const { unit, max_price, min_price } = jsonData[topic][subtopic]
                const subtopicData = await sql`
                 UPDATE subcategories
                 SET unit = ${unit}, max_price = ${max_price}, min_price = ${min_price}, created_at = NOW()
                 WHERE subcat_name = ${subtopic}
                 RETURNING id
               `
            }

        } catch (error) {
            console.error('Error inserting price data:', error)
            return c.json({ error: 'Failed to insert price data' }, 500)
        }
      }

      return c.json(jsonData)
    } else {
      // Return error if getSheetUrl failed
      return c.json({ error: 'Failed to get sheet URL' }, getUrlResponse.status)
    }
  } catch (error) {
    // Handle any other errors that may occur
    console.error('Error:', error)
    return c.json(
      { error: 'An error occurred while processing the request' },
      500,
    )
  }
}

export const getPricesfromDB = async (c: any) => {
    try {
        let pricelist = await sql`select c.cat_name, sc.* from subcategories sc
        join categories c on sc.cat_id = c.id
        order by c.cat_name`

        // if day of created_at is today, then call getPrice function to update prices and then return pricelist
        const today = new Date()
        const todayString = today.toISOString().split('T')[0] // Get today's date in YYYY-MM-DD format

        const lastUpdated = pricelist[0]?.created_at ? new Date(pricelist[0].created_at) : null
        if (lastUpdated && lastUpdated.toISOString().split('T')[0] === todayString) {
            console.log('Prices already updated today, returning cached pricelist')
            return c.json(pricelist)
        }

        await getPrice(c)
        pricelist = await sql`select c.cat_name, sc.* from subcategories sc
        join categories c on sc.cat_id = c.id
        order by c.cat_name`

        if (pricelist.length === 0) {
            return c.json({ message: 'No prices found' }, 404)
        }
        return c.json(pricelist)
    } catch (error) {
        console.error('Error fetching prices:', error)
        return c.json({ error: 'Failed to fetch prices' }, 500)
    }
}

export default app

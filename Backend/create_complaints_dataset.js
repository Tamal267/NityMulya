import postgres from 'postgres';
import { config } from 'dotenv';

config({ path: '.env.local' });

const sql = postgres(process.env.DATABASE_URL);

// Sample data for realistic complaints
const customerNames = [
  'আব্দুল করিম', 'রহিমা খাতুন', 'মোহাম্মদ আলী', 'ফাতেমা বেগম', 'সালমা আক্তার',
  'জাহিদুল ইসলাম', 'নাজমা আহমেদ', 'করিম মিয়া', 'সাবিনা ইয়াসমিন', 'রফিক উদ্দিন',
  'Md. Rahman', 'Ayesha Siddika', 'Kamal Hossain', 'Nasrin Sultana', 'Rahim Mia',
  'শাহিন আলম', 'রুবিনা খাতুন', 'আমিনুল ইসলাম', 'সুমাইয়া পারভীন', 'জাহাঙ্গীর আলম',
  'Sharmin Akter', 'Rafiqul Islam', 'Tahmina Begum', 'Monirul Haque', 'Shahnaz Parvin'
];

const shopNames = [
  'করিম স্টোর', 'রহমান ভ্যারাইটি স্টোর', 'আলী ট্রেডার্স', 'মা ভ্যারাইটি স্টোর', 'নিউ মার্কেট স্টোর',
  'Rahman Store', 'Maa Store', 'Ali Traders', 'City Store', 'New Market',
  'সবুজ ভ্যারাইটি স্টোর', 'পপুলার ট্রেডার্স', 'সুন্দরবন স্টোর', 'আশা ভ্যারাইটি স্টোর', 'ভাই ভাই স্টোর',
  'Bismillah Store', 'Purnima Store', 'Barakah Traders', 'Shimanto Store', 'Padma Store'
];

// Complaint templates for different scenarios and languages
const complaintTemplates = {
  bangla: [
    { text: '{subcat_name} এর দাম {price} টাকা নিয়েছে, কিন্তু বাজার দর {market_price} টাকা।', priceRelated: true },
    { text: '{subcat_name} এর গুণমান খারাপ ছিল। পচা এবং দুর্গন্ধযুক্ত।', priceRelated: false },
    { text: 'দোকানদার {subcat_name} এর দাম বেশি নিয়েছে। {price} টাকা দিয়েছি কিন্তু বাজারে {market_price} টাকা।', priceRelated: true },
    { text: '{subcat_name} কেনার সময় ওজনে কম দিয়েছে। ১ কেজি চেয়েছিলাম কিন্তু ৮০০ গ্রাম দিয়েছে।', priceRelated: false },
    { text: 'দোকানদার অসভ্য আচরণ করেছে এবং {subcat_name} এর দাম অতিরিক্ত নিয়েছে।', priceRelated: true },
    { text: '{subcat_name} টা একদম তাজা না ছিল। পুরাতন এবং শুকনো।', priceRelated: false },
    { text: 'বাসি {subcat_name} বিক্রি করেছে। টাকা ফেরত চাইলে দেয়নি।', priceRelated: false },
    { text: '{subcat_name} এর মান অনুযায়ী দাম বেশি নিয়েছে। {price} টাকা নিয়েছে কিন্তু মান খারাপ।', priceRelated: true },
    { text: 'দোকানে মেয়াদ উত্তীর্ণ {subcat_name} বিক্রি করে। স্বাস্থ্যের জন্য ক্ষতিকর।', priceRelated: false },
    { text: '{subcat_name} কিনতে গিয়ে প্রতারণার শিকার হয়েছি। ভুয়া পণ্য দিয়েছে।', priceRelated: false }
  ],
  english: [
    { text: 'They charged {price} taka for {subcat_name} but market price is {market_price} taka.', priceRelated: true },
    { text: 'The {subcat_name} quality was very poor. Rotten and smelly.', priceRelated: false },
    { text: 'Shopkeeper overcharged for {subcat_name}. Paid {price} but market rate is {market_price}.', priceRelated: true },
    { text: 'They gave less weight when buying {subcat_name}. Asked for 1kg but got only 800g.', priceRelated: false },
    { text: 'Very rude behavior and overpriced {subcat_name}.', priceRelated: true },
    { text: 'The {subcat_name} was not fresh at all. Old and dried.', priceRelated: false },
    { text: 'Sold expired {subcat_name} and refused to refund money.', priceRelated: false },
    { text: 'Poor quality {subcat_name} but charged {price} taka which is too high.', priceRelated: true },
    { text: 'Selling expired {subcat_name} in the shop. Health hazard.', priceRelated: false },
    { text: 'Got cheated while buying {subcat_name}. They gave fake product.', priceRelated: false }
  ],
  banglish: [
    { text: '{subcat_name} er dam {price} taka niyeche kintu market e {market_price} taka.', priceRelated: true },
    { text: '{subcat_name} er quality khub kharap chilo. Pocha ar durgondho.', priceRelated: false },
    { text: 'Dokandar {subcat_name} er dam beshi niyeche. {price} taka diyechi kintu market rate {market_price}.', priceRelated: true },
    { text: '{subcat_name} kinbe somoy ojon e kom diyeche. 1kg cheyechilam kintu 800g diyeche.', priceRelated: false },
    { text: 'Dokandar osubyo beheibior koreche ar {subcat_name} er dam beshi niyeche.', priceRelated: true },
    { text: '{subcat_name} ta ekdom taja chilo na. Purano ar shukno.', priceRelated: false },
    { text: 'Bashi {subcat_name} bikri koreche. Taka ferot chay nai.', priceRelated: false },
    { text: '{subcat_name} er quality kharap but {price} taka niyeche jeta onek beshi.', priceRelated: true },
    { text: 'Dokane expired {subcat_name} bikri kore. Swasther jonno khotikar.', priceRelated: false },
    { text: '{subcat_name} kinte giye protoronar shikar hoyechi. Fake product diyeche.', priceRelated: false }
  ]
};

function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

function getRandomElement(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomFloat(min, max, decimals = 2) {
  return (Math.random() * (max - min) + min).toFixed(decimals);
}

async function createComplaintsTable() {
  try {
    console.log('Fetching subcategories...');
    
    // Get all subcategories
    const subcategories = await sql`
      SELECT id, subcat_name, min_price, max_price 
      FROM subcategories
    `;
    
    console.log(`Found ${subcategories.length} subcategories`);
    
    // Drop existing complaints table if exists
    console.log('Dropping existing complaints table...');
    await sql`DROP TABLE IF EXISTS complaints CASCADE`;
    
    // Create new complaints table
    console.log('Creating complaints table...');
    await sql`
      CREATE TABLE complaints (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        created_at TIMESTAMP DEFAULT NOW(),
        customer_id UUID NOT NULL,
        customer_name VARCHAR(100) NOT NULL,
        shop_id UUID NOT NULL,
        shop_name VARCHAR(100) NOT NULL,
        subcategory_id UUID REFERENCES subcategories(id),
        complaint_description TEXT NOT NULL,
        validity DECIMAL(3,2) CHECK (validity >= 0 AND validity <= 1),
        priority DECIMAL(3,2) CHECK (priority >= 0 AND priority <= 1),
        complaint_score DECIMAL(3,2) CHECK (complaint_score >= 0 AND complaint_score <= 1),
        complaint_classification VARCHAR(20) CHECK (complaint_classification IN ('weak', 'medium', 'high'))
      )
    `;
    
    console.log('Generating 500 complaint records...');
    
    const complaints = [];
    const languages = ['bangla', 'english', 'banglish'];
    
    for (let i = 0; i < 500; i++) {
      const customerId = generateUUID();
      const customerName = getRandomElement(customerNames);
      const shopId = generateUUID();
      const shopName = getRandomElement(shopNames);
      const subcat = getRandomElement(subcategories);
      const language = getRandomElement(languages);
      const template = getRandomElement(complaintTemplates[language]);
      
      // Generate price variations
      const minPrice = parseFloat(subcat.min_price);
      const maxPrice = parseFloat(subcat.max_price);
      const marketPrice = getRandomFloat(minPrice, maxPrice);
      
      // Determine if complaint is about overpricing
      let chargedPrice;
      let validity;
      
      if (template.priceRelated) {
        // 70% chance of overcharging (valid complaint)
        if (Math.random() < 0.7) {
          chargedPrice = getRandomFloat(maxPrice * 1.1, maxPrice * 1.5);
          validity = getRandomFloat(0.6, 0.95); // Valid complaint
        } else {
          // 30% chance price is within range (invalid complaint)
          chargedPrice = getRandomFloat(minPrice, maxPrice);
          validity = getRandomFloat(0.1, 0.4); // Invalid complaint
        }
      } else {
        // Non-price related complaints
        chargedPrice = marketPrice;
        // Random validity for quality/service complaints
        validity = getRandomFloat(0.3, 0.9);
      }
      
      // Generate description
      let description = template.text
        .replace(/{subcat_name}/g, subcat.subcat_name)
        .replace(/{price}/g, Math.round(chargedPrice))
        .replace(/{market_price}/g, Math.round(marketPrice));
      
      // Calculate priority based on description keywords
      let priority;
      const highPriorityKeywords = ['পচা', 'rotten', 'expired', 'মেয়াদ', 'স্বাস্থ্য', 'health', 'প্রতারণা', 'cheated', 'fake', 'ভুয়া'];
      const mediumPriorityKeywords = ['বাসি', 'old', 'শুকনো', 'dried', 'কম', 'less', 'ওজন', 'weight'];
      
      const hasHighPriority = highPriorityKeywords.some(keyword => description.includes(keyword));
      const hasMediumPriority = mediumPriorityKeywords.some(keyword => description.includes(keyword));
      
      if (hasHighPriority) {
        priority = getRandomFloat(0.7, 0.95);
      } else if (hasMediumPriority) {
        priority = getRandomFloat(0.4, 0.7);
      } else {
        priority = getRandomFloat(0.2, 0.6);
      }
      
      // Calculate complaint score (weighted average of validity and priority)
      const complaintScore = (parseFloat(validity) * 0.6 + parseFloat(priority) * 0.4).toFixed(2);
      
      // Determine classification
      let classification;
      if (parseFloat(complaintScore) >= 0.7) {
        classification = 'high';
      } else if (parseFloat(complaintScore) >= 0.4) {
        classification = 'medium';
      } else {
        classification = 'weak';
      }
      
      complaints.push({
        customer_id: customerId,
        customer_name: customerName,
        shop_id: shopId,
        shop_name: shopName,
        subcategory_id: subcat.id,
        complaint_description: description,
        validity: parseFloat(validity),
        priority: parseFloat(priority),
        complaint_score: parseFloat(complaintScore),
        complaint_classification: classification
      });
      
      if ((i + 1) % 100 === 0) {
        console.log(`Generated ${i + 1} complaints...`);
      }
    }
    
    // Insert complaints in batches
    console.log('Inserting complaints into database...');
    const batchSize = 50;
    for (let i = 0; i < complaints.length; i += batchSize) {
      const batch = complaints.slice(i, i + batchSize);
      await sql`
        INSERT INTO complaints ${sql(batch, 
          'customer_id', 
          'customer_name', 
          'shop_id', 
          'shop_name', 
          'subcategory_id', 
          'complaint_description', 
          'validity', 
          'priority', 
          'complaint_score', 
          'complaint_classification'
        )}
      `;
      console.log(`Inserted batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(complaints.length / batchSize)}`);
    }
    
    // Verify the data
    console.log('\nVerifying inserted data...');
    const count = await sql`SELECT COUNT(*) as count FROM complaints`;
    console.log(`Total complaints: ${count[0].count}`);
    
    const stats = await sql`
      SELECT 
        complaint_classification,
        COUNT(*) as count,
        ROUND(AVG(validity)::numeric, 2) as avg_validity,
        ROUND(AVG(priority)::numeric, 2) as avg_priority,
        ROUND(AVG(complaint_score)::numeric, 2) as avg_score
      FROM complaints
      GROUP BY complaint_classification
      ORDER BY complaint_classification
    `;
    console.log('\nStatistics by classification:');
    console.table(stats);
    
    const languageStats = await sql`
      SELECT 
        CASE 
          WHEN complaint_description ~ '[\\u0980-\\u09FF]' THEN 'Bangla/Banglish'
          ELSE 'English'
        END as language_type,
        COUNT(*) as count
      FROM complaints
      GROUP BY language_type
    `;
    console.log('\nLanguage distribution:');
    console.table(languageStats);
    
    // Sample records
    const samples = await sql`
      SELECT 
        customer_name,
        shop_name,
        LEFT(complaint_description, 60) as description,
        validity,
        priority,
        complaint_score,
        complaint_classification
      FROM complaints
      ORDER BY RANDOM()
      LIMIT 10
    `;
    console.log('\nSample records:');
    console.table(samples);
    
    console.log('\n✅ Complaints table created successfully with 500 records!');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sql.end();
  }
}

createComplaintsTable();

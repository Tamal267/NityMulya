import { GoogleGenerativeAI } from '@google/generative-ai';
import { Hono } from 'hono';
import fetch from 'node-fetch';
import * as XLSX from 'xlsx'; // Import the xlsx library

const GoogleApiKey = process.env.GOOGLE_API_KEY;

const genAI = new GoogleGenerativeAI(GoogleApiKey ? GoogleApiKey : '');

const app = new Hono();

const prompt = `
give me the json format of max price and min price of each subtopics under topics: 

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
`;

// URL for the XLSX file to download
// NOTE: This URL is static. You should update it for the most recent data.
const fileUrl = 'http://tcb.gov.bd/sites/default/files/files/tcb.portal.gov.bd/daily_rmp/2cd892ac_4af6_4ade_8d90_25a3d9187d99/2025-08-06-09-16-bafc27a79ed6401c3ca3147b155837e5.xlsx';

// A helper function to convert the file to a format suitable for the Gemini API
// NOTE: This function is no longer needed since we are not sending the file directly.
// We are parsing the file content to text and then sending it.
// function fileToGenerativePart(file, mimeType) {
//   return {
//     inlineData: {
//       data: Buffer.from(file).toString('base64'),
//       mimeType
//     },
//   };
// }

// Register a new GET route for fetching the price data
export const getPrice = async (c: any) => {
  try {
    // 1. Download the XLSX file from the URL
    const response = await fetch(fileUrl);
    if (!response.ok) {
      // Return a 500 error if the file download fails
      return c.json({ error: 'Failed to download the file' }, 500);
    }
    
    // Get the byte data of the file
    const arrayBuffer = await response.arrayBuffer();

    // 2. Parse the XLSX file content to a readable text format
    const workbook = XLSX.read(arrayBuffer, { type: 'array' });
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    
    // Convert the sheet data to a CSV string to send to Gemini
    const fileContent = XLSX.utils.sheet_to_csv(worksheet);

    // 3. Call the Gemini API with the text content
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    
    // API request is created with the text prompt and the text content of the file
    const result = await model.generateContent([prompt, fileContent]);
    let geminiResponse = result.response.text();

    geminiResponse = geminiResponse.trim()
    if (geminiResponse.startsWith('```json')) {
      geminiResponse = geminiResponse.slice(7).trim() // Remove '```json' prefix
    }
    if (geminiResponse.endsWith('```')) {
      geminiResponse = geminiResponse.slice(0, -3)
    }
    geminiResponse = geminiResponse.trim();

    // 4. Parse the JSON data from Gemini's response
    const jsonData = JSON.parse(geminiResponse);

    // 5. Send the JSON data as the response
    return c.json(jsonData);
  } catch (error) {
    // Handle any other errors that may occur
    console.error('Error:', error);
    return c.json({ error: 'An error occurred while processing the request' }, 500);
  }
};

// Export the Hono app for deployment
export default app;

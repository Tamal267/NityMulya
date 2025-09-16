import sql from './src/db.js';

async function testFileAccess() {
  try {
    console.log('🔍 Testing file access and URLs...');
    
    // Get a complaint with file
    const complaint = await sql`
      SELECT complaint_number, file_url, customer_name, description
      FROM complaints 
      WHERE file_url IS NOT NULL 
      LIMIT 1;
    `;
    
    if (complaint.length > 0) {
      const fileUrl = complaint[0].file_url;
      console.log('📁 Sample file URL from database:', fileUrl);
      console.log('📄 Full URL would be: http://localhost:3005' + fileUrl);
      
      // Check if uploads directory exists
      const fs = require('fs');
      const path = require('path');
      
      const uploadsDir = path.join(process.cwd(), 'public', 'uploads');
      const complaintsDir = path.join(uploadsDir, 'complaints');
      
      console.log('📂 Checking directories:');
      console.log('  Uploads dir exists:', fs.existsSync(uploadsDir));
      console.log('  Complaints dir exists:', fs.existsSync(complaintsDir));
      
      if (fs.existsSync(complaintsDir)) {
        const files = fs.readdirSync(complaintsDir);
        console.log('📋 Files in complaints directory:', files.length);
        if (files.length > 0) {
          console.log('  Sample files:', files.slice(0, 3));
        }
      }
      
      // Extract filename from URL
      const fileName = fileUrl.split('/').pop();
      const fullPath = path.join(complaintsDir, fileName);
      console.log('🎯 Full file path:', fullPath);
      console.log('📊 File exists:', fs.existsSync(fullPath));
      
    } else {
      console.log('❌ No complaints with files found');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

testFileAccess();
import postgres from 'postgres';
import { randomUUID } from 'crypto';

async function addSampleData() {
  const sql = postgres('postgresql://postgres:password@localhost:5432/nityamulya_db');

  try {
    console.log('Connected to database');

    // Insert sample reviews for ময়দা (খোলা)
    await sql`
      INSERT INTO customer_reviews (id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, delivery_rating, service_rating, helpful_count, is_verified_purchase, created_at)
      VALUES (${randomUUID()}, ${'customer1'}, ${'shop1'}, ${5}, ${'খুবই ভালো ময়দা, দাম অনুযায়ী উন্নত মানের।'}, ${'ময়দা (খোলা)'}, ${'রহিমের দোকান'}, ${5}, ${5}, ${0}, ${true}, ${new Date()})
    `;

    await sql`
      INSERT INTO customer_reviews (id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, delivery_rating, service_rating, helpful_count, is_verified_purchase, created_at)
      VALUES (${randomUUID()}, ${'customer2'}, ${'shop2'}, ${4}, ${'ময়দা ভালো ছিল, কিন্তু প্যাকেজিং আরও উন্নত হতে পারে।'}, ${'ময়দা (খোলা)'}, ${'করিমের ব্যবসা'}, ${4}, ${4}, ${1}, ${true}, ${new Date()})
    `;

    await sql`
      INSERT INTO customer_reviews (id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, delivery_rating, service_rating, helpful_count, is_verified_purchase, created_at)
      VALUES (${randomUUID()}, ${'customer3'}, ${'shop1'}, ${5}, ${'পরিষ্কার ও তাজা ময়দা। নিয়মিত কিনি।'}, ${'ময়দা (খোলা)'}, ${'রহিমের দোকান'}, ${5}, ${5}, ${2}, ${true}, ${new Date()})
    `;

    console.log('Sample reviews inserted for ময়দা (খোলা)');

    // Check if data was inserted
    const result = await sql`
      SELECT COUNT(*) as count FROM customer_reviews WHERE product_name = ${'ময়দা (খোলা)'}
    `;

    console.log(`Total reviews for ময়দা (খোলা): ${result[0].count}`);

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sql.end();
  }
}

addSampleData();

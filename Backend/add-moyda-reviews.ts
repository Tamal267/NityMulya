import postgres from "postgres";
import { randomUUID } from "crypto";

async function addReviewsForMoyda() {
  const sql = postgres(
    "postgresql://postgres:password@localhost:5432/nityamulya_db"
  );

  try {
    console.log("Adding sample reviews for ময়দা (খোলা)...");

    // Add sample reviews for ময়দা (খোলা) which the app is currently loading
    const reviews = [
      {
        id: randomUUID(),
        customer_id: "customer1",
        shop_owner_id: "shop1",
        rating: 5,
        comment: "খুবই ভালো ময়দা! দাম অনুযায়ী চমৎকার মানের।",
        product_name: "ময়দা (খোলা)",
        shop_name: "রহিম স্টোর",
        delivery_rating: 5,
        service_rating: 5,
        helpful_count: 8,
        is_verified_purchase: true,
        created_at: new Date(),
      },
      {
        id: randomUUID(),
        customer_id: "customer2",
        shop_owner_id: "shop2",
        rating: 4,
        comment: "ভালো মানের ময়দা। প্যাকেজিং আরও উন্নত হতে পারে।",
        product_name: "ময়দা (খোলা)",
        shop_name: "করিমের দোকান",
        delivery_rating: 4,
        service_rating: 4,
        helpful_count: 3,
        is_verified_purchase: true,
        created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
      },
      {
        id: randomUUID(),
        customer_id: "customer3",
        shop_owner_id: "shop3",
        rating: 5,
        comment: "চমৎকার! পরিষ্কার ও তাজা ময়দা।",
        product_name: "ময়দা (খোলা)",
        shop_name: "নিউ মার্কেট",
        delivery_rating: 5,
        service_rating: 5,
        helpful_count: 12,
        is_verified_purchase: false,
        created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 days ago
      },
    ];

    for (const review of reviews) {
      await sql`
        INSERT INTO customer_reviews (
          id, customer_id, shop_owner_id, rating, comment, 
          product_name, shop_name, delivery_rating, service_rating, 
          helpful_count, is_verified_purchase, created_at
        ) VALUES (
          ${review.id}, ${review.customer_id}, ${review.shop_owner_id}, 
          ${review.rating}, ${review.comment}, ${review.product_name}, 
          ${review.shop_name}, ${review.delivery_rating}, ${review.service_rating}, 
          ${review.helpful_count}, ${review.is_verified_purchase}, ${review.created_at}
        )
      `;
    }

    console.log(`Added ${reviews.length} sample reviews for ময়দা (খোলা)`);

    // Verify data was inserted
    const result = await sql`
      SELECT COUNT(*) as count, AVG(rating) as avg_rating 
      FROM customer_reviews 
      WHERE product_name = 'ময়দা (খোলা)'
    `;

    console.log(`Total reviews for ময়দা (খোলা): ${result[0].count}`);
    console.log(`Average rating: ${result[0].avg_rating}`);
  } catch (error) {
    console.error("Error:", error);
  } finally {
    await sql.end();
  }
}

addReviewsForMoyda();

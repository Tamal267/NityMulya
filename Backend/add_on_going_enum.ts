import sql from "./src/db";

async function addOnGoingEnumValue() {
  try {
    console.log("🔧 Adding 'on going' to order_status enum...");

    // First, let's check the current enum values
    const currentEnums = await sql`
      SELECT enumlabel 
      FROM pg_enum 
      WHERE enumtypid = (
        SELECT oid 
        FROM pg_type 
        WHERE typname = 'order_status'
      )
      ORDER BY enumsortorder;
    `;

    console.log(
      "📋 Current enum values:",
      currentEnums.map((e) => e.enumlabel)
    );

    // Check if 'on going' already exists
    const hasOnGoing = currentEnums.some((e) => e.enumlabel === "on going");

    if (hasOnGoing) {
      console.log("✅ 'on going' enum value already exists!");
      return;
    }

    // Add the new enum value
    await sql`
      ALTER TYPE order_status ADD VALUE 'on going' AFTER 'confirmed';
    `;

    console.log("✅ Successfully added 'on going' to order_status enum");

    // Verify the addition
    const updatedEnums = await sql`
      SELECT enumlabel 
      FROM pg_enum 
      WHERE enumtypid = (
        SELECT oid 
        FROM pg_type 
        WHERE typname = 'order_status'
      )
      ORDER BY enumsortorder;
    `;

    console.log(
      "📋 Updated enum values:",
      updatedEnums.map((e) => e.enumlabel)
    );
  } catch (error) {
    console.error("❌ Error adding enum value:", error);
  } finally {
    process.exit(0);
  }
}

addOnGoingEnumValue();

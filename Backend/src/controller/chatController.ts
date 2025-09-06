import sql from "../db";

// Send a chat message
export const sendChatMessage = async (c: any) => {
  try {
    const user = c.get("user");
    const userId = user.userId;
    const userRole = user.role;

    if (!userId) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const { receiver_id, receiver_type, message } = await c.req.json();

    if (!receiver_id || !receiver_type || !message) {
      return c.json(
        {
          success: false,
          message: "receiver_id, receiver_type, and message are required",
        },
        400
      );
    }

    // Determine sender type from user role
    const sender_type = userRole === "wholesaler" ? "wholesaler" : "shop_owner";

    console.log(
      `💬 Sending message from ${sender_type} ${userId} to ${receiver_type} ${receiver_id}`
    );

    const result = await sql`
      INSERT INTO chat_messages (
        sender_id, sender_type, receiver_id, receiver_type, message
      ) VALUES (
        ${userId}, ${sender_type}, ${receiver_id}, ${receiver_type}, ${message}
      )
      RETURNING id, created_at, message
    `;

    console.log("✅ Chat message sent successfully:", result[0]);

    return c.json({
      success: true,
      message: result[0],
    });
  } catch (error) {
    console.error("❌ Error sending chat message:", error);
    return c.json(
      {
        success: false,
        message: "Failed to send message",
        details: error instanceof Error ? error.message : String(error),
      },
      500
    );
  }
};

// Get chat messages between two users
export const getChatMessages = async (c: any) => {
  try {
    const user = c.get("user");
    const userId = user.userId;
    const userRole = user.role;

    if (!userId) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const contact_id = c.req.query("contact_id");
    const contact_type = c.req.query("contact_type");

    if (!contact_id || !contact_type) {
      return c.json(
        {
          success: false,
          message: "contact_id and contact_type are required",
        },
        400
      );
    }

    const sender_type = userRole === "wholesaler" ? "wholesaler" : "shop_owner";

    console.log(
      `📋 Getting messages between ${sender_type} ${userId} and ${contact_type} ${contact_id}`
    );

    const messages = await sql`
      SELECT 
        cm.*,
        CASE 
          WHEN cm.sender_type = 'wholesaler' THEN w.full_name
          WHEN cm.sender_type = 'shop_owner' THEN so.full_name
        END as sender_name,
        CASE 
          WHEN cm.receiver_type = 'wholesaler' THEN w2.full_name
          WHEN cm.receiver_type = 'shop_owner' THEN so2.full_name
        END as receiver_name
      FROM chat_messages cm
      LEFT JOIN wholesalers w ON cm.sender_id = w.id AND cm.sender_type = 'wholesaler'
      LEFT JOIN shop_owners so ON cm.sender_id = so.id AND cm.sender_type = 'shop_owner'
      LEFT JOIN wholesalers w2 ON cm.receiver_id = w2.id AND cm.receiver_type = 'wholesaler'
      LEFT JOIN shop_owners so2 ON cm.receiver_id = so2.id AND cm.receiver_type = 'shop_owner'
      WHERE (
        (cm.sender_id = ${userId} AND cm.sender_type = ${sender_type} 
         AND cm.receiver_id = ${contact_id} AND cm.receiver_type = ${contact_type})
        OR 
        (cm.sender_id = ${contact_id} AND cm.sender_type = ${contact_type} 
         AND cm.receiver_id = ${userId} AND cm.receiver_type = ${sender_type})
      )
      ORDER BY cm.created_at ASC
    `;

    console.log(`💬 Found ${messages.length} messages`);

    return c.json({
      success: true,
      messages: messages,
    });
  } catch (error) {
    console.error("❌ Error getting chat messages:", error);
    return c.json(
      {
        success: false,
        message: "Failed to get messages",
        details: error instanceof Error ? error.message : String(error),
      },
      500
    );
  }
};

// Get chat conversations for a user
export const getChatConversations = async (c: any) => {
  try {
    const user = c.get("user");
    const userId = user.userId;
    const userRole = user.role;

    if (!userId) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const sender_type = userRole === "wholesaler" ? "wholesaler" : "shop_owner";

    console.log(`📋 Getting conversations for ${sender_type} ${userId}`);

    // Get all unique conversations with the last message
    const conversations = await sql`
      WITH chat_pairs AS (
        SELECT DISTINCT
          CASE WHEN sender_id = ${userId} THEN receiver_id ELSE sender_id END as contact_id,
          CASE WHEN sender_id = ${userId} THEN receiver_type ELSE sender_type END as contact_type
        FROM chat_messages 
        WHERE sender_id = ${userId} OR receiver_id = ${userId}
      ),
      last_messages AS (
        SELECT 
          cp.contact_id,
          cp.contact_type,
          cm.message as last_message,
          cm.created_at as last_message_time,
          ROW_NUMBER() OVER (PARTITION BY cp.contact_id, cp.contact_type ORDER BY cm.created_at DESC) as rn
        FROM chat_pairs cp
        JOIN chat_messages cm ON (
          (cm.sender_id = ${userId} AND cm.receiver_id = cp.contact_id AND cm.receiver_type = cp.contact_type)
          OR 
          (cm.receiver_id = ${userId} AND cm.sender_id = cp.contact_id AND cm.sender_type = cp.contact_type)
        )
      )
      SELECT 
        lm.contact_id,
        lm.contact_type,
        lm.last_message,
        lm.last_message_time,
        CASE 
          WHEN lm.contact_type = 'wholesaler' THEN w.full_name
          WHEN lm.contact_type = 'shop_owner' THEN so.full_name
        END as contact_name,
        CASE 
          WHEN lm.contact_type = 'wholesaler' THEN w.contact
          WHEN lm.contact_type = 'shop_owner' THEN so.contact
        END as contact_phone,
        COALESCE(unread.unread_count, 0) as unread_count
      FROM last_messages lm
      LEFT JOIN wholesalers w ON lm.contact_id = w.id AND lm.contact_type = 'wholesaler'
      LEFT JOIN shop_owners so ON lm.contact_id = so.id AND lm.contact_type = 'shop_owner'
      LEFT JOIN (
        SELECT 
          sender_id, sender_type, COUNT(*) as unread_count
        FROM chat_messages 
        WHERE receiver_id = ${userId} AND receiver_type = ${sender_type} AND is_read = false
        GROUP BY sender_id, sender_type
      ) unread ON lm.contact_id = unread.sender_id AND lm.contact_type = unread.sender_type
      WHERE lm.rn = 1
      ORDER BY lm.last_message_time DESC
    `;

    console.log(`💬 Found ${conversations.length} conversations`);

    return c.json({
      success: true,
      conversations: conversations,
    });
  } catch (error) {
    console.error("❌ Error getting conversations:", error);
    return c.json(
      {
        success: false,
        message: "Failed to get conversations",
        details: error instanceof Error ? error.message : String(error),
      },
      500
    );
  }
};

// Mark messages as read
export const markMessagesAsRead = async (c: any) => {
  try {
    const user = c.get("user");
    const userId = user.userId;
    const userRole = user.role;

    if (!userId) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const { sender_id, sender_type } = await c.req.json();

    if (!sender_id || !sender_type) {
      return c.json(
        {
          success: false,
          message: "sender_id and sender_type are required",
        },
        400
      );
    }

    const receiver_type =
      userRole === "wholesaler" ? "wholesaler" : "shop_owner";

    const result = await sql`
      UPDATE chat_messages 
      SET is_read = true, updated_at = NOW()
      WHERE receiver_id = ${userId} 
        AND receiver_type = ${receiver_type}
        AND sender_id = ${sender_id}
        AND sender_type = ${sender_type}
        AND is_read = false
      RETURNING id
    `;

    console.log(`✅ Marked ${result.length} messages as read`);

    return c.json({
      success: true,
      marked_count: result.length,
    });
  } catch (error) {
    console.error("❌ Error marking messages as read:", error);
    return c.json(
      {
        success: false,
        message: "Failed to mark messages as read",
        details: error instanceof Error ? error.message : String(error),
      },
      500
    );
  }
};

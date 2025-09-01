-- Insert sample customer reviews for testing
-- First, let's assume we have some sample customers and shop_owners

-- Sample customer reviews for products
INSERT INTO
    customer_reviews (
        id,
        customer_id,
        shop_owner_id,
        order_id,
        subcat_id,
        rating,
        comment,
        product_name,
        shop_name,
        delivery_rating,
        service_rating,
        is_verified_purchase
    )
VALUES
    -- Reviews for চাল (Rice)
    (
        gen_random_uuid (),
        (
            SELECT id
            FROM customers
            LIMIT 1
        ),
        (
            SELECT id
            FROM shop_owners
            LIMIT 1
        ),
        NULL,
        (
            SELECT id
            FROM subcategories
            WHERE
                subcat_name = 'চাল'
            LIMIT 1
        ),
        5,
        'অসাধারণ মানের চাল! দাম অনুযায়ী খুবই ভালো। পরিবারের সবার পছন্দ হয়েছে।',
        'চাল',
        'রহমান গ্রোসারি',
        4,
        5,
        true
    ),
    (
        gen_random_uuid (),
        (
            SELECT id
            FROM customers
            OFFSET
                1
            LIMIT 1
        ),
        (
            SELECT id
            FROM shop_owners
            LIMIT 1
        ),
        NULL,
        (
            SELECT id
            FROM subcategories
            WHERE
                subcat_name = 'চাল'
            LIMIT 1
        ),
        4,
        'ভালো কোয়ালিটি। ডেলিভারি একটু দেরি হয়েছিল কিন্তু পণ্য ভালো।',
        'চাল',
        'করিম স্টোর',
        3,
        4,
        true
    ),
    (
        gen_random_uuid (),
        (
            SELECT id
            FROM customers
            OFFSET
                2
            LIMIT 1
        ),
        (
            SELECT id
            FROM shop_owners
            OFFSET
                1
            LIMIT 1
        ),
        NULL,
        (
            SELECT id
            FROM subcategories
            WHERE
                subcat_name = 'চাল'
            LIMIT 1
        ),
        5,
        'খুবই ভালো চাল। দামটাও যুক্তিসংগত। আবার কিনব।',
        'চাল',
        'নিউ মার্কেট শপ',
        5,
        5,
        true
    ),

-- Reviews for ডাল (Lentils)
(
    gen_random_uuid (),
    (
        SELECT id
        FROM customers
        LIMIT 1
    ),
    (
        SELECT id
        FROM shop_owners
        LIMIT 1
    ),
    NULL,
    (
        SELECT id
        FROM subcategories
        WHERE
            subcat_name = 'ডাল'
        LIMIT 1
    ),
    4,
    'ভালো ডাল। রান্না করলে নরম হয়ে যায় তাড়াতাড়ি।',
    'ডাল',
    'রহমান গ্রোসারি',
    4,
    4,
    true
),

-- Reviews for তেল (Oil)
(
    gen_random_uuid (),
    (
        SELECT id
        FROM customers
        OFFSET
            1
        LIMIT 1
    ),
    (
        SELECT id
        FROM shop_owners
        OFFSET
            1
        LIMIT 1
    ),
    NULL,
    (
        SELECT id
        FROM subcategories
        WHERE
            subcat_name = 'তেল'
        LIMIT 1
    ),
    5,
    'খাঁটি সরিষার তেল। গন্ধ এবং স্বাদ দুটোই চমৎকার।',
    'তেল',
    'করিম স্টোর',
    5,
    5,
    true
),

-- Shop reviews (without specific product)
(
    gen_random_uuid (),
    (
        SELECT id
        FROM customers
        LIMIT 1
    ),
    (
        SELECT id
        FROM shop_owners
        LIMIT 1
    ),
    NULL,
    NULL,
    5,
    'এই দোকানের সার্ভিস অসাধারণ! দোকানদার খুবই ভদ্র এবং সহায়ক।',
    NULL,
    'রহমান গ্রোসারি',
    5,
    5,
    true
),
(
    gen_random_uuid (),
    (
        SELECT id
        FROM customers
        OFFSET
            1
        LIMIT 1
    ),
    (
        SELECT id
        FROM shop_owners
        OFFSET
            1
        LIMIT 1
    ),
    NULL,
    NULL,
    4,
    'ভালো দোকান। দ্রুত ডেলিভারি। দাম একটু কমানো যেতে পারে।',
    NULL,
    'করিম স্টোর',
    5,
    3,
    true
);
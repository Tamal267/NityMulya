"""
Generate 500 Realistic Complaints Dataset
Mix of Bengali, English, and Banglish complaints
"""

import random
import json
from datetime import datetime, timedelta

# Complaint templates in Bengali
bengali_templates = [
    "আমি {shop} থেকে {product} কিনেছি কিন্তু {issue}। {action}",
    "{shop} এর {product} একদম {quality}। আমি {feeling}।",
    "গতকাল {shop} থেকে {product} কিনলাম। {problem}। দ্রুত সমাধান চাই।",
    "{shop} দোকানে {product} এর {issue}। এটা {severity}।",
    "আমার {family} {shop} থেকে {product} কিনে {problem}। {complaint}।",
]

# English templates
english_templates = [
    "I bought {product} from {shop} but {issue}. {action}",
    "The {product} from {shop} was {quality}. I am {feeling}.",
    "Yesterday I purchased {product} from {shop}. {problem}. Need urgent action.",
    "The {shop} sold me {issue} {product}. This is {severity}.",
    "My {family} bought {product} from {shop} and {problem}. {complaint}.",
]

# Banglish templates (mixed)
banglish_templates = [
    "Ami {shop} theke {product} kinechi kintu {issue}. {action}",
    "{shop} er {product} ekdom {quality}. Ami {feeling}.",
    "Gotokal {shop} theke {product} kinlam. {problem}. Taratari solution chai.",
    "{shop} dukane {product} er {issue}. Eta {severity}.",
    "Amar {family} {shop} theke {product} kine {problem}. Please {complaint}.",
    "Ei {shop} te {product} kinte giye {issue}. Very {severity}.",
    "Ami jodi {shop} theke abar {product} kini tahole {problem}. {action} korte hobe.",
]

# Data for templates
shops = {
    "bengali": ["করিম স্টোর", "রহিম ভান্ডার", "আলী ট্রেডার্স", "সাকিব মার্ট", "নুর দোকান", "হাসান এন্টারপ্রাইজ"],
    "english": ["Karim Store", "Rahim Shop", "Ali Traders", "Sakib Mart", "Nur Store", "Hasan Enterprise"],
    "banglish": ["Karim Store", "Rahim Bhandar", "Ali Traders", "Sakib Mart", "Nur Dokan", "Hasan Enterprise"]
}

products = {
    "bengali": ["চাল", "ডাল", "তেল", "চিনি", "নুন", "আলু", "পেঁয়াজ", "বিস্কুট", "দুধ", "ডিম"],
    "english": ["rice", "lentils", "oil", "sugar", "salt", "potato", "onion", "biscuit", "milk", "eggs"],
    "banglish": ["chal", "dal", "tel", "chini", "nun", "alu", "peyaj", "biscuit", "dudh", "dim"]
}

issues_bengali = [
    "মেয়াদ উত্তীর্ণ ছিল",
    "ওজন কম ছিল",
    "দাম বেশি নিয়েছে",
    "গুণগত মান খারাপ",
    "নষ্ট ছিল",
    "পচা ছিল",
    "ভেজাল মিশ্রিত",
    "দুর্গন্ধ ছিল",
]

issues_english = [
    "it was expired",
    "weight was less",
    "overcharged me",
    "quality was poor",
    "it was rotten",
    "it was damaged",
    "adulterated product",
    "bad smell",
]

issues_banglish = [
    "expired chilo",
    "ojon kom chilo",
    "dam beshi niyeche",
    "quality kharap",
    "nosto chilo",
    "pocha chilo",
    "vejal mishrito",
    "durgondho chilo",
]

quality = {
    "bengali": ["খারাপ", "ভয়ানক", "অসহনীয়", "নিম্নমানের", "বাজে"],
    "english": ["bad", "terrible", "unacceptable", "substandard", "awful"],
    "banglish": ["kharap", "bhal na", "terrible", "low quality", "baje"]
}

feelings = {
    "bengali": ["অসন্তুষ্ট", "রাগান্বিত", "হতাশ", "বিরক্ত", "ক্ষুব্ধ"],
    "english": ["dissatisfied", "angry", "disappointed", "frustrated", "upset"],
    "banglish": ["dissatisfied", "ragito", "disappointed", "birokto", "khobdho"]
}

problems = {
    "bengali": [
        "খাওয়ার পর পেট খারাপ হয়েছে",
        "স্বাস্থ্য সমস্যা হয়েছে",
        "টাকা নষ্ট হয়েছে",
        "সময় নষ্ট হয়েছে",
        "পরিবারের সবাই অসুস্থ",
    ],
    "english": [
        "got stomach problem after eating",
        "had health issues",
        "wasted money",
        "wasted time",
        "whole family got sick",
    ],
    "banglish": [
        "khawar por pet kharap hoyeche",
        "health problem hoyeche",
        "taka nosto hoyeche",
        "somoy nosto hoyeche",
        "poribar sick hoyeche",
    ]
}

severity = {
    "bengali": ["খুবই গুরুতর", "অগ্রহণযোগ্য", "বিপজ্জনক", "মারাত্মক"],
    "english": ["very serious", "unacceptable", "dangerous", "critical"],
    "banglish": ["very serious", "ogrohonjoggo", "dangerous", "marattok"]
}

actions = {
    "bengali": [
        "টাকা ফেরত চাই",
        "ব্যবস্থা নিন",
        "দোকান বন্ধ করুন",
        "শাস্তি দিন",
        "ক্ষতিপূরণ চাই",
    ],
    "english": [
        "want refund",
        "take action",
        "close the shop",
        "punish them",
        "want compensation",
    ],
    "banglish": [
        "taka ferot chai",
        "bebostha nin",
        "dokan bondho korun",
        "shasti din",
        "khotiporon chai",
    ]
}

family = {
    "bengali": ["বাচ্চা", "মা", "বাবা", "স্ত্রী", "পরিবার"],
    "english": ["child", "mother", "father", "wife", "family"],
    "banglish": ["baccha", "ma", "baba", "wife", "poribar"]
}

complaints = {
    "bengali": ["অভিযোগ করছি", "এর বিরুদ্ধে ব্যবস্থা নিন", "সমাধান চাই"],
    "english": ["filing complaint", "take action against this", "need solution"],
    "banglish": ["obhijog korchi", "bebostha nin", "solution chai"]
}


def generate_complaint(language: str, shop_id: int, customer_id: int) -> dict:
    """Generate a single complaint"""
    
    if language == "bengali":
        template = random.choice(bengali_templates)
        data = {
            "shop": random.choice(shops["bengali"]),
            "product": random.choice(products["bengali"]),
            "issue": random.choice(issues_bengali),
            "quality": random.choice(quality["bengali"]),
            "feeling": random.choice(feelings["bengali"]),
            "problem": random.choice(problems["bengali"]),
            "severity": random.choice(severity["bengali"]),
            "action": random.choice(actions["bengali"]),
            "family": random.choice(family["bengali"]),
            "complaint": random.choice(complaints["bengali"]),
        }
    elif language == "english":
        template = random.choice(english_templates)
        data = {
            "shop": random.choice(shops["english"]),
            "product": random.choice(products["english"]),
            "issue": random.choice(issues_english),
            "quality": random.choice(quality["english"]),
            "feeling": random.choice(feelings["english"]),
            "problem": random.choice(problems["english"]),
            "severity": random.choice(severity["english"]),
            "action": random.choice(actions["english"]),
            "family": random.choice(family["english"]),
            "complaint": random.choice(complaints["english"]),
        }
    else:  # banglish
        template = random.choice(banglish_templates)
        data = {
            "shop": random.choice(shops["banglish"]),
            "product": random.choice(products["banglish"]),
            "issue": random.choice(issues_banglish),
            "quality": random.choice(quality["banglish"]),
            "feeling": random.choice(feelings["banglish"]),
            "problem": random.choice(problems["banglish"]),
            "severity": random.choice(severity["banglish"]),
            "action": random.choice(actions["banglish"]),
            "family": random.choice(family["banglish"]),
            "complaint": random.choice(complaints["banglish"]),
        }
    
    description = template.format(**data)
    
    # Generate categories
    categories = [
        "পণ্যের গুণগত মান সমস্যা",
        "ভুল দাম বা অতিরিক্ত চার্জ",
        "পণ্যের ওজন কম",
        "খারাপ আচরণ",
        "মেয়াদোত্তীর্ণ পণ্য",
        "অন্যান্য",
    ]
    
    # Determine category based on issue
    if "মেয়াদ" in description or "expired" in description:
        category = "মেয়াদোত্তীর্ণ পণ্য"
    elif "ওজন" in description or "weight" in description or "ojon" in description:
        category = "পণ্যের ওজন কম"
    elif "দাম" in description or "price" in description or "dam" in description or "charge" in description:
        category = "ভুল দাম বা অতিরিক্ত চার্জ"
    elif "খারাপ" in description or "quality" in description or "kharap" in description or "নষ্ট" in description:
        category = "পণ্যের গুণগত মান সমস্যা"
    else:
        category = random.choice(categories)
    
    # Generate timestamp (last 30 days)
    days_ago = random.randint(0, 30)
    submitted_at = datetime.now() - timedelta(days=days_ago)
    
    return {
        "customer_id": f"CUST{customer_id:05d}",
        "customer_name": f"Customer {customer_id}",
        "customer_email": f"customer{customer_id}@example.com",
        "customer_phone": f"+880171234{customer_id:04d}",
        "shop_owner_id": f"SHOP{shop_id:03d}",
        "shop_name": data["shop"],
        "product_name": data["product"],
        "category": category,
        "description": description,
        "submitted_at": submitted_at.isoformat(),
        "language": language,
    }


def generate_dataset(total: int = 500) -> list:
    """Generate full dataset"""
    
    complaints = []
    
    # Distribution: 15% Bengali, 30% English, 55% Banglish
    num_bengali = int(total * 0.15)
    num_english = int(total * 0.30)
    num_banglish = total - num_bengali - num_english
    
    print(f"📊 Generating {total} complaints:")
    print(f"  - Bengali: {num_bengali}")
    print(f"  - English: {num_english}")
    print(f"  - Banglish: {num_banglish}")
    
    customer_id = 1
    shop_id = 1
    
    # Generate Bengali
    for i in range(num_bengali):
        complaint = generate_complaint("bengali", shop_id, customer_id)
        complaints.append(complaint)
        customer_id += 1
        shop_id = (shop_id % 50) + 1
    
    # Generate English
    for i in range(num_english):
        complaint = generate_complaint("english", shop_id, customer_id)
        complaints.append(complaint)
        customer_id += 1
        shop_id = (shop_id % 50) + 1
    
    # Generate Banglish
    for i in range(num_banglish):
        complaint = generate_complaint("banglish", shop_id, customer_id)
        complaints.append(complaint)
        customer_id += 1
        shop_id = (shop_id % 50) + 1
    
    # Shuffle
    random.shuffle(complaints)
    
    return complaints


if __name__ == "__main__":
    print("🚀 Generating complaints dataset...")
    
    complaints = generate_dataset(500)
    
    # Save to JSON
    output_file = "complaints_dataset.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(complaints, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Generated {len(complaints)} complaints")
    print(f"💾 Saved to {output_file}")
    
    # Print sample
    print(f"\n📝 Sample complaints:")
    for i, complaint in enumerate(complaints[:5]):
        print(f"\n{i+1}. [{complaint['language'].upper()}]")
        print(f"   {complaint['description'][:100]}...")
        print(f"   Category: {complaint['category']}")

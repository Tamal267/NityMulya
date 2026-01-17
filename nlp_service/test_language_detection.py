from preprocessor import TextPreprocessor

prep = TextPreprocessor()

examples = [
    "Ali Traders er dim ekdom bhal na. Ami khobdho.",
    "আমি আপনার দোকান থেকে কেনা চাল খেয়ে আমার পরিবারের সবাই গুরুতরভাবে অসুস্থ হয়ে পড়েছে।",
    "shop was bad",
    "The milk from Rahim Shop was unacceptable. I am disappointed.",
    "Ami Sakib Mart theke nun kinechi kintu quality kharap. bebostha nin"
]

for text in examples:
    lang = prep.detect_language(text)
    print(f"Text: {text[:30]}... -> Language: {lang}")
    
    # Debug ratios
    import re
    bengali_chars = re.findall(r'[\u0980-\u09FF]', text)
    english_chars = re.findall(r'[a-zA-Z]', text)
    
    bengali_ratio = len(bengali_chars) / max(len(text), 1)
    english_ratio = len(english_chars) / max(len(text), 1)
    
    print(f"   Bn ratio: {bengali_ratio:.2f}, En ratio: {english_ratio:.2f}")

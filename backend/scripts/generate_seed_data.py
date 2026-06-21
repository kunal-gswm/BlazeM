import json
import random
from datetime import datetime, timedelta, timezone

def generate_seed():
    now = datetime.now(timezone.utc)
    
    # Predefined company names
    companies = [
        ("Bajaj Housing Finance", "BAJAJHFL"), ("Ola Electric", "OLAELEC"),
        ("Swiggy", "SWIGGY"), ("NTPC Green", "NTPCGREEN"),
        ("Tata Technologies", "TATATECH"), ("IREDA", "IREDA"),
        ("FirstCry", "FIRSTCRY"), ("Oyo Rooms", "OYO"),
        ("Hyundai Motor India", "HYUNDAI"), ("Afcons Infrastructure", "AFCONS"),
        ("NSE India", "NSE"), ("Reliance Retail", "RELRETAIL"),
        ("Vishal Mega Mart", "VISHAL"), ("HDB Financial", "HDBFIN"),
        ("Aadhar Housing", "AADHAR")
    ]
    
    ca_companies = [
        ("TCS", "TCS"), ("Reliance", "RELIANCE"), ("Infosys", "INFY"),
        ("HDFC Bank", "HDFCBANK"), ("ITC", "ITC"), ("L&T", "LT"),
        ("Wipro", "WIPRO"), ("HUL", "HINDUNILVR"), ("SBI", "SBIN"),
        ("Bharti Airtel", "BHARTIARTL")
    ]

    sources = [
        {"id": "official_nse", "name": "NSE India", "priority": "official", "website": "https://nseindia.com", "is_active": True},
        {"id": "secondary_chittorgarh", "name": "Chittorgarh", "priority": "secondary", "website": "https://chittorgarh.com", "is_active": True},
        {"id": "unofficial_gmp", "name": "IPO Watch GMP", "priority": "unofficial", "website": "https://ipowatch.in", "is_active": True}
    ]

    ipos = []
    events = []
    
    # Helper to create meta
    def make_meta(source_idx, hours_ago):
        s = sources[source_idx]
        created = now - timedelta(hours=hours_ago + 24)
        fetched = now - timedelta(hours=hours_ago)
        return {
            "source_id": s["id"],
            "source_priority": s["priority"],
            "created_at": created.isoformat(),
            "fetched_at": fetched.isoformat(),
            "updated_at": fetched.isoformat()
        }
        
    def add_event(evt_id, evt_type, ent_type, ent_id, title, subtitle, date_val, status, importance, score, meta):
        events.append({
            "id": evt_id,
            "event_type": evt_type,
            "entity_type": ent_type,
            "entity_id": ent_id,
            "title": title,
            "subtitle": subtitle,
            "date": date_val.isoformat(),
            "status": status,
            "importance": importance,
            "importance_score": score,
            "meta": meta
        })

    # Generate 15 IPOs
    for i, (name, symbol) in enumerate(companies):
        base_date = now + timedelta(days=random.randint(-20, 20))
        open_date = base_date
        close_date = open_date + timedelta(days=2)
        allotment_date = close_date + timedelta(days=1)
        listing_date = allotment_date + timedelta(days=2)
        
        status = "completed" if listing_date < now else "active" if open_date <= now <= close_date else "upcoming"
        if status == "upcoming" and open_date < now: status = "active" # fallback
        
        issue_price = random.randint(50, 1000)
        
        ipo_id = f"ipo_{symbol.lower()}"
        ipos.append({
            "id": ipo_id,
            "company_name": name,
            "symbol": symbol,
            "issue_price_min": float(issue_price - 5),
            "issue_price_max": float(issue_price),
            "lot_size": random.randint(10, 200),
            "issue_size": float(random.randint(500, 15000)),
            "retail_quota": 35.0 if random.random() > 0.5 else 10.0,
            "status": status,
            "open_date": open_date.strftime("%Y-%m-%d"),
            "close_date": close_date.strftime("%Y-%m-%d"),
            "allotment_date": allotment_date.strftime("%Y-%m-%d"),
            "listing_date": listing_date.strftime("%Y-%m-%d"),
            "meta": make_meta(random.randint(0,1), random.randint(1, 12))
        })
        
        # IPO Events
        # Open
        days_to_open = (open_date - now).days
        o_score = 85 if days_to_open == 0 else 60 if 0 < days_to_open <= 2 else 40 if days_to_open > 0 else 10
        o_imp = "high" if o_score >= 50 else "medium" if o_score >= 25 else "low"
        
        add_event(f"evt_{ipo_id}_open", "ipo_open", "ipo", ipo_id, f"{name} IPO Opens", 
                  f"₹{issue_price-5}-{issue_price}", open_date, "completed" if now > open_date else "upcoming", 
                  o_imp, o_score, make_meta(0, 2))
                  
        # Close
        days_to_close = (close_date - now).days
        c_score = 100 if days_to_close == 0 else 65 if days_to_close == 1 else 40 if days_to_close > 0 else 10
        c_imp = "critical" if c_score >= 75 else "high" if c_score >= 50 else "medium" if c_score >= 25 else "low"
        add_event(f"evt_{ipo_id}_close", "ipo_close", "ipo", ipo_id, f"{name} IPO Closes", 
                  "Last day to apply", close_date, "completed" if now > close_date else "upcoming", 
                  c_imp, c_score, make_meta(0, 2))

        # Listing
        days_to_list = (listing_date - now).days
        l_score = 75 if 0 <= days_to_list <= 1 else 45 if days_to_list > 1 else 10
        l_imp = "high" if l_score >= 50 else "medium" if l_score >= 25 else "low"
        add_event(f"evt_{ipo_id}_list", "ipo_listing", "ipo", ipo_id, f"{name} Listing", 
                  "Expected on exchanges", listing_date, "completed" if now > listing_date else "upcoming", 
                  l_imp, l_score, make_meta(0, 2))

    # Generate 25 Corporate Actions
    cas = []
    actions = ["dividend", "bonus", "split"]
    for i in range(25):
        comp = random.choice(ca_companies)
        act = random.choice(actions)
        base_date = now + timedelta(days=random.randint(-15, 30))
        ex_date = base_date
        
        ca_id = f"ca_{comp[1].lower()}_{act}_{i}"
        
        ratio = "1:1" if act == "bonus" else "1:5" if act == "split" else f"{random.randint(2, 50)}.00"
        
        cas.append({
            "id": ca_id,
            "company_name": comp[0],
            "symbol": comp[1],
            "action_type": act,
            "ratio": ratio,
            "record_date": ex_date.strftime("%Y-%m-%d"),
            "ex_date": ex_date.strftime("%Y-%m-%d"),
            "payment_date": (ex_date + timedelta(days=15)).strftime("%Y-%m-%d") if act == "dividend" else None,
            "status": "completed" if now > ex_date else "upcoming",
            "meta": make_meta(0, random.randint(1, 24))
        })
        
        # Event
        days_to_ex = (ex_date - now).days
        e_score = 80 if 0 <= days_to_ex <= 1 else 45 if days_to_ex > 1 else 10
        e_imp = "high" if e_score >= 50 else "medium" if e_score >= 25 else "low"
        
        add_event(f"evt_{ca_id}_ex", f"{act}_ex", "corporate_action", ca_id, f"{comp[0]} Ex-{act.capitalize()}", 
                  f"Ratio/Amount: {ratio}", ex_date, "completed" if now > ex_date else "upcoming", 
                  e_imp, e_score, make_meta(0, 5))

    # Output JSON
    out = {
        "sources": sources,
        "ipos": ipos,
        "corporate_actions": cas,
        "timeline_events": events
    }
    
    with open("e:/BlazeM/mobile/assets/data/seed_data.json", "w") as f:
        json.dump(out, f, indent=2)
        
    print(f"Generated {len(ipos)} IPOs, {len(cas)} CAs, {len(events)} Events")

if __name__ == "__main__":
    generate_seed()

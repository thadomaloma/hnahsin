import csv, sys, os

ROOT = os.path.expanduser("~/mnt/Thumal Quest")
BY_CLASS_DIR = os.path.join(ROOT, "content/pilot/kumtluang/by_class")
INCOMING = os.path.join(ROOT, "content/pilot/kumtluang/_deepen_2026-09")

FIELDS = ['candidate_id','canonical_form','seed_category','tq_level','status','language_review',
          'learning_review','notes','english_gloss','meaning_mizo','example_mizo',
          'difficulty','game_modes','emoji']

def read_csv(path):
    with open(path, encoding='utf-8') as f:
        return list(csv.DictReader(f))

def write_csv(path, rows):
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=FIELDS, extrasaction='ignore')
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k,'') for k in FIELDS})

classes = ['class1','class2','class3','class4','class5','class6','class7']
before_counts = {}
after_counts = {}
total_appended = 0

for c in classes:
    by_class_path = os.path.join(BY_CLASS_DIR, f"kumtluang_{c}_vocab.csv")
    new_rows_path = os.path.join(INCOMING, f"{c}_new_rows.csv")
    existing = read_csv(by_class_path)
    new_rows = read_csv(new_rows_path)
    before_counts[c] = len(existing)
    merged = existing + new_rows
    write_csv(by_class_path, merged)
    after_counts[c] = len(merged)
    total_appended += len(new_rows)
    print(f"{c}: {len(existing)} -> {len(merged)} (+{len(new_rows)})")

print(f"\nTotal appended across 7 by_class files: {total_appended}")

# Create vartian_candidates.csv (new standalone file)
vartian_path = os.path.join(ROOT, "content/pilot/vartian_candidates.csv")
vartian_rows = read_csv(os.path.join(INCOMING, "vartian_candidates.csv"))
write_csv(vartian_path, vartian_rows)
print(f"vartian_candidates.csv created: {len(vartian_rows)} rows")

# Rebuild all_with_repeats = concat of all 7 by_class files
all_repeats_path = os.path.join(ROOT, "content/pilot/kumtluang/kumtluang_vocab_all_with_repeats.csv")
all_rows = []
for c in classes:
    all_rows.extend(read_csv(os.path.join(BY_CLASS_DIR, f"kumtluang_{c}_vocab.csv")))
write_csv(all_repeats_path, all_rows)
print(f"\nall_with_repeats rebuilt: {len(all_rows)} rows")

# Rebuild master_deduped = existing master + new master rows (already deduped by finalize.py)
master_path = os.path.join(ROOT, "content/pilot/kumtluang/kumtluang_vocab_master_deduped.csv")
existing_master = read_csv(master_path)
new_master_rows = read_csv(os.path.join(INCOMING, "master_deduped_new_rows.csv"))
merged_master = existing_master + new_master_rows
write_csv(master_path, merged_master)
print(f"master_deduped: {len(existing_master)} -> {len(merged_master)} (+{len(new_master_rows)})")

# sanity check: no duplicate candidate_id within master or within any by_class file or vartian
def check_dups(path, label):
    rows = read_csv(path)
    ids = [r['candidate_id'] for r in rows]
    dups = set(x for x in ids if ids.count(x) > 1)
    status = "OK" if not dups else f"DUPLICATES FOUND: {dups}"
    print(f"  {label}: {len(rows)} rows, {len(set(ids))} unique ids -- {status}")

print("\n=== Post-merge integrity check ===")
for c in classes:
    check_dups(os.path.join(BY_CLASS_DIR, f"kumtluang_{c}_vocab.csv"), c)
check_dups(vartian_path, "vartian_candidates.csv")
check_dups(all_repeats_path, "all_with_repeats")
check_dups(master_path, "master_deduped")

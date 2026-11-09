fn main() {
    let base = "  abcdefghijklmnopqrstuvwxyz-abcdefghijklmnopqrstuvwxyz  ";
    let clean = base.trim();

    let mut match_count = 0;
    for _ in 0..5000 {
        if clean.contains("jkl") {
            match_count += 1;
        }
        if clean.ends_with("xyz") {
            match_count += 1;
        }
        let _sub = &clean[2..10];
    }
    println!("Done. Matches: {}", match_count);
}

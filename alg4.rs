fn main() {
    let mut text = String::with_capacity(10000);
    for i in 0..2000 {
        text.push_str("abc");
        if i % 10 == 0 {
            text.push_str("-");
        }
    }
    println!("Done. Length: {}", text.len());
}

fn main() {
    let mut text: Vec<u8> = Vec::with_capacity(10000);
    
    for i in 0..2000 {
        text.push(97);
        text.push(98);
        text.push(99);
        if i % 10 == 0 {
            text.push(45);
        }
    }
    println!("String bytes processed: {}", text.len());
}

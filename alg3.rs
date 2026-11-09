fn main() {
    let mut numbers: Vec<i32> = Vec::with_capacity(5000);
    for i in 0..5000 {
        numbers.push(if i % 2 == 0 { i * 3 } else { -i * 2 });
    }
    for i in 0..5000 {
        numbers[i] = numbers[i].wrapping_add(i as i32);
    }
    println!("Done. Element 2500: {}", numbers[2500]);
}

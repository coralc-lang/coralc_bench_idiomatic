fn main() {
    // 1. Small Dynamic Allocation (1,000 integers allocated on the heap)
    let mut numbers: Vec<i32> = Vec::with_capacity(1000);

    // 2. Simple Algorithm: Populate and perform calculations
    for i in 0..1000 {
        // Alternate signs to mix up the data
        if i % 2 == 0 {
            numbers.push(i * 3);
        } else {
            numbers.push(-i * 2);
        }
    }

    // 3. Process the data (Simple Selection Sort to force CPU work)
    let len = numbers.len();
    for i in 0..len {
        for j in (i + 1)..len {
            if numbers[j] < numbers[i] {
                let temp = numbers[i];
                numbers[i] = numbers[j];
                numbers[j] = temp;
            }
        }
    }

    // Print a single value so the compiler doesn't optimize the code away
    println!("Done. Element 500: {}", numbers[500]);
}

struct Rectangle {
    width: u64,
    height: u64,
}

fn main() {
    let width1 = 30;
    let height1 = 10;
    let rec = Rectangle { width: width1, height: height1 };
    let area = area(rec.width, rec.height);
    println!("Area is {}", area);
}

fn area(width: u64, height: u64) -> u64 {
    width * height
}

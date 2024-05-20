// there are scalar and compund data types in Cairo
fn main() {
    // type casting using try_intto()
    let a: u32 = 30; // ineger type
    let b: felt252 = a.try_into().unwrap(); // try_into returns Option that must be  unwrapped
    println!("The value of b is {}", b);
    let _c: u32 = 33;
    //let d = a - c; // causes panic because values are unsigned thus no negative numbers
    // println!("the value of d is {}", d);

    // representting signed integers
    // Each signed variant can store numbers from to inclusive, where n is the number of bits
    // that variant uses. So an i8 can store numbers from to , which equals -128 to 127
    let neg_a: i8 = 30;
    let neg_c: i8 = 40;
    let neg_d = neg_a - neg_c;
    neg_d;

    // operations
    let a: u32 = addition(20, 30);
    let b: u32 = subtraction(40, 30);
    let c: u32 = multiplication(40, 30);
    let d: u32 = division(40, 30);
    let e: u32 = modulus(40, 30);

    println!("Addition: {}", a);
    println!("Subtraction: {}", b);
    println!("Multiplication: {}", c);
    println!("Division: {}", d);
    println!("Modulus: {}", e);

    // booleans
    let is_late: bool = false;
    let has_arrived = true;
    println!("Is he late? : {}", is_late);
    println!("Has he arrived? : {}", has_arrived);

    // strings
    let _greet: felt252 = 'Hello World';
    let _long_greet: ByteArray = "How are you doing today?";

    // type casting for scalar types
    let a: u32 = 30; // ineger type
    let b: felt252 = a.try_into().unwrap(); // try_into returns Option that must be  unwrapped
    let c: felt252 = a.into(); // panics when conversion isn't successful
    println!("b and c are {} and {}", b, c);

    // the tuple type
    let student: (ByteArray, u32, u32) = ("Victor Oluoch Juma", 29, 4);
    let (_x, _y, _z) = student; // pattern matching tto destructure elements of a tuple
    let (_a, _b): (u8, u8) = (10, 12); // this is also correct
// the unit type. It is the void type in Cairo with the value ()
}

fn addition(x: u32, y: u32) -> u32 {
    x + y
}

fn subtraction(x: u32, y: u32) -> u32 {
    x - y
}

fn multiplication(x: u32, y: u32) -> u32 {
    x * y
}

fn division(x: u32, y: u32) -> u32 {
    x / y
}

fn modulus(x: u32, y: u32) -> u32 {
    x % y
}

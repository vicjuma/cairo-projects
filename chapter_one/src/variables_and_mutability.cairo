use core::traits::Into;
// Cairo uses an immutable memory model, meaning that once a memory cell is written to, it can't
// be overwritten but only read from 

const PI: u32 = 314; // constant variable must be type annotated and global
const PI_Deci: u32 = consteval_int!(314 / 100); // constant variable using consteval_int!
fn main() {
    let _name: ByteArray = "Victor Oluoch"; // immuttable by default
    let mut name: ByteArray = "Victor Oluoch"; // abstracted mutabilit
    println!("My name is {}", name);
    name = "Kevin Bryne";
    println!("My name is {}", name);
    let _name: ByteArray = "Kevin Bryne"; // shadowing, type anotation required
    let num: u32 = 32;
    let num: felt252 = num.into(); // shadowing does not complain even when we change types
    println!("My name is {}", num);
}


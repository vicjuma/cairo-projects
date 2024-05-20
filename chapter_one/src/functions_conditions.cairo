fn temperature_converter(num: u32, to_degree: bool) -> u32 {
    // Cairo is an expression-based language
    // let y = 6 this statement does not return so it will not possible to so let y = z = 6 as in C languages
    let result = if to_degree {
        let fer: u32 = ((9 / 5) * num) + 32;
        fer
    } else if to_degree == false {
        let deg: u32 = (5 / 9) * (num - 32);
        deg
    } else {
        0
    };
    // most functions return the last expression implicitly
    result // expressions do not include ending semi-colons, adding it turns it into a statement 
}

fn loops_practise() -> usize {
    let mut i: usize = 0;
    loop {
        if i == 5 {
            break i; // returning a value from a loop
        }
        println!("Counter: {}", i);
        i += 1;
    }
}

fn while_practise() {
    let mut i: usize = 0;
    while i <= 5 {
        println!("While Counter: {}", i);
        i += 1;
    }
}

fn main() {
    let num: u32 = 5;
    let to_degree: bool = true;
    let temp: u32 = temperature_converter(:num, :to_degree);
    let _r: usize = loops_practise();
    while_practise();
    println!("The temperature is {}", temp);
    println!("The value of _r is {}", _r);
}

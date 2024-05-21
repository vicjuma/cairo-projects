use core::dict::Felt252DictTrait;
use core::box::BoxTrait;
use core::option::OptionTrait;
use core::array::ArrayTrait;

// storing multiple types in an array with enums
#[derive(Copy, Drop)]
enum Student {
    Integer: u32,
    Felt: felt252,
    Boolean: bool,
    Tuple: (felt252, felt252)
}

#[derive(Drop)]
struct Rectangle {
    height: u32,
    width: u32,
}

// array collextions
fn working_with_arrays() {
    // array declarations
    let mut _arr1: Array<usize> = ArrayTrait::new(); // option 1
    let mut _arr2: Array = ArrayTrait::<usize>::new(); // option 2
    let mut _arr3: Array = array![]; // option 3

    // updating an array
    _arr1.append(20);
    _arr2.append(5);
    _arr3.append(12);

    // accessing elements of an array
    let array_elem1 = *_arr1
        .at(0); // Using arr.at(index) is equivalent to using the subscripting operator arr[index] 
    let array_elem2 = *_arr2.at(0); // at() returns 
    let array_elem3 = *_arr3.at(0);

    println!("The Array elements are {}, {} and {}", array_elem1, array_elem2, array_elem3);

    // removing elemens of an array
    let val: usize = _arr1.pop_front().unwrap(); // returns Option that must be unwrapped 
    println!("Removed value is {}", val);

    let index_accesses: usize = 0;

    match _arr1.get(index_accesses) {
        Option::Some(x) => { *x.unbox(); },
        Option::None => { println!("No such element at the index {}", index_accesses); }
    }

    // array size
    let length_arr2: usize = _arr2.len();
    println!(
        "The length of the array 2 is {} but array 1 is empty? {}", length_arr2, _arr1.is_empty()
    );

    // multiple types in an array with custom data types in an enum
    let mut messages: Array<Student> = array![];
    messages.append(Student::Integer(13));
    messages.append(Student::Felt('Hello There'));
    messages.append(Student::Boolean(true));
    messages.append(Student::Tuple((10, 20)));
}

fn working_with_dictionaries() {
    let mut marks: Felt252Dict<felt252> = Default::default();
    marks.insert('vik', 93);
    marks.insert('edmond', 88);
    marks.insert('calv', 73);

    marks.get('vik');
}

fn working_with_snapshots(array_snapshot: @Array<u32>) -> u32 {
    let arr_length: u32 = array_snapshot.len();
    arr_length
}

fn working_with_desnap(rectangle: @Rectangle) -> u32 {
    let area: u32 = (*rectangle.height)
        * (*rectangle.width); // we cannot modify values in a snapshot
    area
}

fn working_with_mutable_references(ref rectangle: Rectangle) -> u32 {
    rectangle.height = 12;
    rectangle.width = 14;
    let area: u32 = (rectangle.height) * (rectangle.width); // we cannot modify values in a snapshot
    area
}

fn main() {
    working_with_arrays();
    let arr: Array<u32> = array![3, 4, 5, 6];
    working_with_snapshots(@arr);

    let mut rec = Rectangle {
        height: 30, width: 50
    }; // must be mutable to be passed as mutable reference
    working_with_desnap(@rec);
    working_with_mutable_references(ref rec); // passing ref with the value
}

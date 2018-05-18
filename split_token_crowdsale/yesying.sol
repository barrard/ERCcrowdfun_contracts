pragma solidity ^0.4.21;


contract test {

  uint public count = 0;

  struct test_struct {
    uint num_a;
    string name;
    uint value;
  }

  test_struct[] public test_struct_array;

  function make_struct(uint _num_a, string _name, uint _value){
    test_struct memory new_test_struct = test_struct_array[count];
    new_test_struct.num_a = _num_a;
    new_test_struct.name = _name;
    new_test_struct.value = _value;
    count++;

  }

  function edit_struct_value(uint _index,uint _value ){
    test_struct memory edit_test_struct = test_struct_array[_index];
    edit_test_struct.value = _value;
    test_struct_array[_index] = edit_test_struct;
  }


function test(){

}

}
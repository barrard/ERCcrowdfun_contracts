pragma solidity ^0.4.21;

import "./Ownable.sol";


contract Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool); 
    function balanceOf(address _owner) external view returns (uint256);
      event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);


}

contract Market_place is Ownable{
    
    Token token;
    
    mapping (address=>Tokens_for_sale[]) token_address_to_tokens_for_sale;
    mapping (address=>Tokens_for_sale[]) my_tokens_for_sale;
    mapping (address=>Token_Quotes[]) token_address_to_token_quotes;
    
    
    struct Tokens_for_sale{
        address seller;
        uint256 amount;
        uint256 asking_price;
        string order_type;
        uint256 time;
        
    }
    
    struct Bid_for_tokens{
        address buyer;
        uint256 amount;
        uint256 asking_price;
        string order_type;
        uint256 time;

        
    }
    
    struct Token_Quotes{
        address token_address;
        uint256 last_sold_price;
        uint256 last_sold_amount;
        uint last_sold_time;
        string last_sold_type;
    }
    
    function buy_tokens(address _addr, uint256 _index)public 
        returns(address seller,
            uint256 amount,
            uint256 asking_price,
            string order_type,
            uint256 time)
        {
        Tokens_for_sale memory tfs;
        tfs = token_address_to_tokens_for_sale[_addr][_index];
        return (tfs.seller, tfs.amount, tfs.asking_price, tfs.order_type, tfs.time);
    }
    
    //precurosr to get_tokens_for_sale_by_index(address _addr, uint256 _index)
    function get_tokens_for_sale_array_length_by_address(address _token_address) public view returns (uint256){
        return token_address_to_tokens_for_sale[_token_address].length;
    }
    
    // function Market_place(){
        
        
    // }    
    
    // function who_is_this() public view returns(address){
    //     return this;
    // }
    //     function my_balance(address _token_address) public returns(uint256){
    //         token = Token(_token_address);
    //         token.approve(this, 1);
    //         return token.balanceOf(msg.sender);
            
    // }
    //                                 //  "0x755014Da263Fc47d238078Bb47d217F743E5B6a5", 1, 2, "Market"
    function offer_tokens_for_sale(address _token_address, uint256 _amount, uint256 _asking_price, string _order_type) public{
        Tokens_for_sale memory ntfs;//new_tokens_for_sale seller, amount, asking_price per or total?

        token = Token(_token_address);
        uint256 allowance = token.allowance(msg.sender, this);
        require(allowance >= _amount);
        // token.approve(this, _amount);
        token.transferFrom(msg.sender, address(this), _amount);
        
        ntfs.seller = msg.sender;
        ntfs.amount = _amount;
        ntfs.asking_price = _asking_price;
        ntfs.order_type = _order_type;
        ntfs.time = block.timestamp;
        
        my_tokens_for_sale[msg.sender].push(ntfs);
        token_address_to_tokens_for_sale[_token_address].push(ntfs);
        // return true;
        // return _new_tokens_for_sale;
    }
    
    function get_my_tokes_for_sale_total() public view returns(uint){
        return my_tokens_for_sale[msg.sender].length;

    }
    function get_tokens_for_sale_by_index(address _addr, uint256 _index)
        public 
        view 
        returns(address, // seller,
                uint256, // amount,
                uint256, // asking_price,
                string, // order_type,
                uint256 // time
        ){
            Tokens_for_sale memory tfs = token_address_to_tokens_for_sale[_addr][_index];
            
            return (tfs.seller, tfs.amount, tfs.asking_price, tfs.order_type, tfs.time); 
                                                                    
        }
    function get_my_tokens_for_sale_by_index(address _addr, uint256 _index)
        public 
        view 
        returns(address, // seller
                uint256, // amount
                uint256, // asking_price
                string, // order_type
                uint256 // time
        ){
            Tokens_for_sale memory tfs = my_tokens_for_sale[_addr][_index];
            
            return (tfs.seller, tfs.amount, tfs.asking_price, tfs.order_type, tfs.time); 
                                                                    
    }

    function cancel_my_tokens_for_sale_by_index(address _addr, uint256 _index) public {
            Tokens_for_sale memory tfs = my_tokens_for_sale[_addr][_index];
            require(msg.sender == tfs.seller);
             token = Token(_addr);
            token.transfer(msg.sender, tfs.amount);
            if (_index >= my_tokens_for_sale[_addr].length) return;

            for (uint i = _index; i< my_tokens_for_sale[_addr].length-1; i++){
                my_tokens_for_sale[_addr][i] = my_tokens_for_sale[_addr][i+1];
            }
            my_tokens_for_sale[_addr].length--;
            
                                                                    
    }
    
    
    
    
    
    
    
    
}
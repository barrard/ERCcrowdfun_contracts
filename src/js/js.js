toastr.options.progressBar = true;
App = {
  web3Provider: null,
  contracts: {},
  address:{
    // ERC721MintableToken:"0xee308f9f50e06383ddab6e17f1e06b647794b9ee"
    ERC721MintableToken:"0x8d1f10da2f5a9c2ff4b7fc47e50ef36026f53925"//rinkeby address
  },
  data:{},
  abi:{},
  account:'',

  init: function() {

    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      // App.web3Provider = new Web3.providers.HttpProvider('http://192.168.0.93:8545');
      // App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);
    web3.eth.getAccounts(function(e, r){
        console.log(r)
        $('#ethAccountID').html(r[0])
        App.account = r[0];
        web3.eth.getBalance(r[0].toString(),function(e, r){
          if(e){console.log(e)}
          console.log(r.toNumber())
          $('#currentBalance').html(web3.fromWei(r.toNumber()))
          return App.initContract();

        })
      })
  },

  initContract: function() {
    $.getJSON('contract_abi/ERC721MintableToken.json', function(data) {
      App.abi.ERC721MintableToken = web3.eth.contract(data)
      // Set the provider for our contract
      App.contracts.ERC721MintableToken = App.abi.ERC721MintableToken.at(App.address.ERC721MintableToken)
      App.init_data();
    });
    // return App.set_UI();
    
  },
  init_data:()=>{
    //get total data for 
    var data_array = [
      'owner',
      'totalSupply',
      'get_my_tokens',
      'get_wei_balance',
      'numTokensTotal',
      'token_counter',
      "prop_token_counter", 
      "_crowdsale_counter"
      ];

    var function_call_array = [
      "get_property_by_id()", 
      "balanceOf()",
      'ownerOf()',
      'getOwnerTokens()',
      'tokenMetadata()',
      'crowdSales()',
      'get_tokens_for_property()',
    ]

    data_array.forEach((i, x)=>{
      var sidebar_el = $('.sidebar')[0];
      console.log(i)
      App.contracts.ERC721MintableToken[i]((e, r)=>{
        if(e){
          console.log(i+':'+e)
        } else{
          console.log(i+':'+r)
          App.data[i]=r
          $(sidebar_el).append(`<div>${i}: ${r}</div>`)

        }
        console.log(x)
        if(x+1==data_array.length) App.setUI();

      })
    })

  },
  setUI:()=>{
    console.log('setup the UI')
    console.log('The crowdsal counter is at '+App.data._crowdsale_counter)
    var _crowdsale_list_el = $('.crowdsale_list')[0]
    //loop through App.data._crowdsale_counter using get_property_by_id()
    for(let x = 0 ; x < App.data._crowdsale_counter; x++){
      App.contracts.ERC721MintableToken.get_property_by_id(x, (e, r)=>{
        if(e){
          console.log(e)
        }else{
          console.log(r)          
        }
      })
    }

    $('#buy_create_crowdsale_token_btn').on('click', ()=>{
      console.log('Buy tokens')
        // var _val = $('#number_of_tokens_to_buy').val()
        // console.log('buying '+_val)
        activate_spinner('#block-spinner')
        web3.eth.sendTransaction({
          from:web3.eth.coinbase,
          to:App.address.ERC721MintableToken,
          value:web3.toWei(1, "ether")
        }, function(e, txHash){
          if(e){
            hide_spinner('#block-spinner')
            toastr.warning(e, 'Failed to send Ether')
            console.log(e)
          }else if(txHash){
            playSound('ka-ching_sound_effect.m4a');
            call_when_mined(txHash, function(){
              setTimeout(function(){
                playSound('COIN_DROPPED_ON_TABLE.mp3');
                hide_spinner('#block-spinner')
                toastr.success('Your teken is delivered')

              }, 1000)

            })
            toastr.success(txHash, 'Success! Your token is on it\'s way soon')
            console.log(txHash)
          }
        })
    })
    $('#create_crowdsale_btn').on('click', ()=>{
      console.log('Create Crowdsale')
        // var _val = $('#number_of_tokens_to_buy').val()
        // console.log('buying '+_val)
        activate_spinner('#block-spinner')
        App.contracts.ERC721MintableToken.get_one_OwnerToken_id(App.account, (e, r)=>{
          if(e) {console.log('you have no tokens'); return;}
          else{
            console.log(r.toNumber());
            var _token_id = (r.toNumber());
            App.contracts.ERC721MintableToken.spend_CS_Token(_token_id, (e, r)=>{
              console.log(e)
              console.log(r)
            })

          }
        })

    })
    
    App.watch_events();
  },
  watch_events:()=>{
    var events_array = [
      'Seed_Tokes_Minted',
      'Crowdsale_initiated',
      'Prop_token_minted',
      'Transfer',
      'Approval',
      'OwnershipTransferred',
      'TokenPurchase',
      'Finalized',
      'Closed',
      'RefundsEnabled',
      'Refunded'
    ]

  }
}


$(function() {
  $(window).on('load', function() {
    console.log('load')
    App.init();
  });
});

function call_when_mined(txHash, callback){
  web3.eth.getTransactionReceipt(txHash, function(e, r){
    if(e){console.log(e)}
      else{
        if(r==null){
          setTimeout(function(){
            call_when_mined(txHash, callback)
          }, 500)
        }else{
          callback();
        }
      }
  })
}

function activate_spinner(_spinner){
  $(_spinner).css({display:'block'})
}
function hide_spinner(_spinner){
  $(_spinner).css({display:'none'})
}

function playSound(filename){   
    document.getElementById("sound").innerHTML=`
    <audio autoplay="autoplay"><source src=" ${filename}"  /></audio>
    `;
}
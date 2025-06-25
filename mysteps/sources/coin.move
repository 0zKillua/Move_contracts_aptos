module 0xBAC::mycoin{
        use std::signer;
        use std::debug;


    const MODULE_OWNER: address=@named_addr;

    const ENOT_MODULE_OWNER:u64=0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;

    struct Coin has store{
        value:u64,
    }
    struct Balance has key{
        coin: Coin
    }
    //;step 1
    // public entry fun mint(account:&signer,value:u64){
    //     let mintCoin= Coin{value: value};
    //     move_to(account,Balance{coin:mintCoin}) 
    // }

    //; will publish resource:Balance to given address
    public fun publish_balance(account:&signer){
        let empty_coin= Coin{value:0};
         assert!(!exists<Balance>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        move_to(account,Balance{coin: empty_coin});
    }

    public fun mint(module_owner:&signer,mint_addr:address,amount:u64) acquires Balance{ 
        assert!(signer::address_of(module_owner)==MODULE_OWNER,ENOT_MODULE_OWNER);

        deposit(mint_addr,Coin{value:amount});

    }

    //;acquires is needed whenever resource needs to be read from global storage

    public fun balance_of(owner: address):u64 acquires Balance{

        borrow_global<Balance>(owner).coin.value //;this is returned

    }

    public fun transfer(from:&signer,to:address,amount:u64) acquires Balance{
            let balance_check=balance_of(signer::address_of(from));
                debug::print(&balance_check);

            //withdraw first
            let w_coin=withdraw(signer::address_of(from),amount);

            //deposit next
            deposit(to,w_coin);


    }

    public fun withdraw(addr:address,amount:u64): Coin acquires Balance{
        let balance=balance_of(addr);
        assert!(balance>=amount,EINSUFFICIENT_BALANCE);
        let bal_ref= &mut borrow_global_mut<Balance>(addr).coin.value;
        *bal_ref=balance-amount;
        Coin{value:amount}
    }

     fun deposit(addr:address,coin:Coin) acquires Balance{
        let Coin{value:_amount} = coin;
        let bal_ref= &mut borrow_global_mut<Balance>(addr).coin.value;
        *bal_ref+=_amount;
     }


//;step 2
// #[test(account=@0xABC)]
// fun test_mint(account:&signer) acquires Balance{
// let addr= 0x1::signer::address_of(account);
// mint(account,5);
// assert!(borrow_global<Balance>(addr).coin.value == 5,0);
// transfer(account); 

// }

#[test(account=@0xABC)]
#[expected_failure(abort_code = EALREADY_HAS_BALANCE)]
fun test_publish_balance(account:&signer){
    let addr=signer::address_of(account);
    assert!(!exists<Balance>(addr),EALREADY_HAS_BALANCE);

    publish_balance(account);
    assert!(!exists<Balance>(addr),EALREADY_HAS_BALANCE);   

}

#[test(non_owner=@0x123,to=@0xABC)]
#[expected_failure(abort_code=ENOT_MODULE_OWNER)]
fun test_mint_non_owner(non_owner:&signer,to:address) acquires Balance{
    mint(non_owner,to,100);
}

#[test(owner=@named_addr,to=@0xABC)]
fun test_mint_only_owner(owner:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
    publish_balance(to);
    mint(owner,to_addr,100);
}

#[test(owner=@named_addr,to=@0xABC)]
fun test_balance_of(owner:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
    publish_balance(to);
    let bal= balance_of(to_addr);
    debug::print(&bal);
    
    assert!(balance_of(to_addr)==0);
    mint(owner,to_addr,100);
    assert!(balance_of(to_addr)==100);

}


#[test(owner=@named_addr,to=@0xABC)]
fun test_withdraw(owner:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
    publish_balance(to);
    mint(owner,to_addr,100);
    assert!(balance_of(to_addr)==100);
    let w_coin= withdraw(to_addr,10);
    assert!(balance_of(to_addr)==90);
    //;cannot drop this coin so just consume it. 
    Coin{value:_}=w_coin;

}

#[test(owner=@named_addr,to=@0xABC)]
#[expected_failure]
fun test_withdraw_excess(owner:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
    publish_balance(to);
    mint(owner,to_addr,100);
    assert!(balance_of(to_addr)==100);
    let w_coin= withdraw(to_addr,120);
    assert!(balance_of(to_addr)==90);
    //;cannot drop this coin so just consume it. 
    Coin{value:_}=w_coin;

}

#[test(owner=@named_addr,to=@0xABC)]
fun test_deposit(owner:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
   
    publish_balance(to);
    mint(owner,to_addr,100);
    let extra_coin=Coin{value: 25};
    

    deposit(to_addr,extra_coin);
    assert!(balance_of(to_addr)==125);
   

}
#[test(owner=@named_addr,from=@0xDEF,to=@0xABC)]
fun test_transfer(owner:&signer,from:&signer,to:&signer) acquires Balance{
    let to_addr=signer::address_of(to);
     let from_addr=signer::address_of(from);
    publish_balance(to);
    publish_balance(from);

    mint(owner,to_addr,100);  
    mint(owner,from_addr,100);
    assert!(balance_of(to_addr)==100);
    assert!(balance_of(from_addr)==100);
   
    transfer(from,to_addr,25);
    assert!(balance_of(to_addr)==125);
    assert!(balance_of(from_addr)==75);


}




}

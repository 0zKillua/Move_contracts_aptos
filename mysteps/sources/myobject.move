module named_addr::object_playground{
    use std::signer;
    use std::string::{Self,String};

    use aptos_framework::object::{Self,ObjectCore};

     /// Seed for my named object, must be globally unique to the creating account
    const NAME: vector<u8> = b"MyAwesomeObject";

    struct S1 has key{
        message:String
    }

    struct S2 has key{
        message:String
    }

    public fun create_transfer(caller:&signer,destination:address){

        let caller_addr=signer::address_of(caller);
        let constructor_ref=object::create_object(caller_addr);

        let object_signer=object::generate_signer(&constructor_ref); 
        let r1=S1{message:string::utf8(b"hello")};
        let r2=S2{message:string::utf8(b"world!")};

        move_to(&object_signer,r1);
        move_to(&object_signer,r2);

        //;transfer todestination

        
        let object = object::object_from_constructor_ref<ObjectCore>(
      &constructor_ref
    );
        object::transfer(caller,object,destination);
    }


 entry fun create_my_object(caller: &signer) {
    let caller_address = signer::address_of(caller);

     //;not deletable,random address
    let constructor_ref1=object::create_object(caller_addr);
    //;deletable,deterministic address
    let constructor_ref2 = object::create_named_object(caller, NAME);
    //;not deletable,random address
    let constructor_ref3 = object::create_sticky_object(caller_address);

    // ...
  }
    #[view]
  fun has_object(creator: address): bool {
    let object_address = object::create_object_address(&creator, NAME);
    object::object_exists<0x1::object::ObjectCore>(object_address)
  }
}
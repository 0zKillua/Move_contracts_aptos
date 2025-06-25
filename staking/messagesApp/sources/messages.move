module owner::Message
{
    use std::signer;
    use std::string::{String,Self};
    use aptos_framework::account;
    use std::debug;

    struct MessageResource has key{
        message:    String
    }

    public entry fun create_message(account:&signer,msg: String) acquires MessageResource{
        let acc_address=signer::address_of(account);
        let exists=exists<MessageResource>(acc_address);
        if(!exists){
            let message= MessageResource{
                message: msg
            };
            //;takes signer not address. 
            move_to(account,message);
            }
        else{
            //if resource already exists then borrow and modify
            //;borrow global takes address not signer.
            let message=borrow_global_mut<MessageResource>(acc_address);
            //change message now
            message.message=msg;
        }
    }//eof

    public fun get_message(user:address):String acquires MessageResource{
        assert!(exists<MessageResource>(user),0);
        let message=borrow_global<MessageResource>(user);
        message.message
    }


#[test(account=@0x123)]
public fun test_create(account:&signer) acquires MessageResource{

    let acc_address=signer::address_of(account);
    let msg=string::utf8(b"hello moto");
    create_message(account,msg);
    let return_str=get_message(acc_address);
    debug::print(&return_str);
}

}
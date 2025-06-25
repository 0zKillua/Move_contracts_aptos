module owner::todolist{
    use std::signer;
    use aptos_std::table::{Self, Table}; 
    use aptos_framework::event;
    use aptos_framework::account;

    use std::string::{String,Self};
    use std::debug;


 struct Task has store,drop,copy{
    task_id:u32,
    name:String,
    completed:bool,

 }

 struct TaskList has key{
    tasks:Table<u32,Task>,
    set_task_event:event::EventHandle<Task>,
    task_counter:u32,

 }

 public fun create_list(account:&signer){
    let task_holder=TaskList{
        tasks:table::new(),
        set_task_event: account::new_event_handle<Task>(account),
        task_counter:0,
    };
    move_to(account,task_holder);
 }



public fun create_task(account:&signer,name:String) acquires TaskList{
    //;get address from signer
    //;check if tasklist exists abort otherwise
    //;get counter from tasklist and use it in task id
    //; create task
    //; add it to tasklist table

    let acc_address=signer::address_of(account);
    assert!(exists<TaskList>(acc_address),0);
    let task_list=borrow_global_mut<TaskList>(acc_address);
    let counter=task_list.task_counter+1;
    let new_task=Task{
        task_id:counter,
        name: name,
        completed:false,
    };
    table::upsert(&mut task_list.tasks,counter,new_task);
    task_list.task_counter=counter;
    event::emit_event<Task>(&mut borrow_global_mut<TaskList>(acc_address).set_task_event,new_task);

}

public fun toggle_task_status(account:&signer,task_id:u32,status:bool) acquires TaskList{
    let acc_address=signer::address_of(account);
    assert!(exists<TaskList>(acc_address),0);
    let task_list=borrow_global_mut<TaskList>(acc_address);
    assert!(table::contains(&task_list.tasks,task_id),0);
    let task=table::borrow_mut(&mut task_list.tasks,task_id);

    task.completed=status;

}

#[view]
public fun task_getter(account:&signer,task_id:u32):(String,bool) acquires TaskList{
    let acc_address=signer::address_of(account);
    assert!(exists<TaskList>(acc_address),0);

    let task_list=borrow_global_mut<TaskList>(acc_address);
    assert!(table::contains(&task_list.tasks,task_id),0);

    let task=table::borrow(&mut task_list.tasks,task_id);
    (task.name,task.completed)
}



#[test(user=@0xABC)]
public fun test_flow(user:&signer) acquires TaskList{
    let user_address=signer::address_of(user);
    
    account::create_account_for_test(user_address);

    assert!(!exists<TaskList>(user_address),0);
   //;1
    create_list(user);
    assert!(exists<TaskList>(user_address),0);
    
    let task_name=string::utf8(b"complete move codes");
    //;2
    create_task(user,task_name);
    let (name,_)= task_getter(user, 1);
    debug::print(&name);

    let task_id=1;
    let task_status=true;
    //;3
    toggle_task_status(user,task_id,task_status);

    let (name,status)= task_getter(user, 1);

    debug::print(&name);
    debug::print(&status);

    
}





}
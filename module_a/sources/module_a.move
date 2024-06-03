module module_a::module_a {

    use std::option;
    use std::signer;
    use aptos_framework::event;

    const ENOT_AUTHORIZED: u64 = 1;

    struct HotPotato {
        stamp: option::Option<address>
    }

    #[event]
    struct MessageReceived has store, drop {
        address: address
    }

    public fun receive_message(): HotPotato {
        HotPotato { stamp: option::none() }
    }

    public fun stamp(caller: &signer, hot_potato: HotPotato): HotPotato {
        option::fill(&mut hot_potato.stamp, signer::address_of(caller) );
        hot_potato
    }

    public fun complete_receive_message(caller: &signer, hot_potato: HotPotato) {
        assert!(signer::address_of(caller) == *option::borrow(&hot_potato.stamp), ENOT_AUTHORIZED);
        event::emit(MessageReceived {address: signer::address_of(caller)});
        let HotPotato { stamp: _ } = hot_potato;
    }

    #[test(caller = @module_a)]
    fun test_receive_message_sucess(caller: &signer) {
        let hot_potato = receive_message();
        let stamped_hot_potato = stamp(caller, hot_potato);
        complete_receive_message(caller, stamped_hot_potato);
        assert!(event::was_event_emitted(&MessageReceived{address: signer::address_of(caller)}) == true, 1);
    }

    #[test(caller = @module_a)]
    #[expected_failure]
    fun test_receive_message_fail(caller: &signer) {
        let hot_potato = receive_message();
        complete_receive_message(caller, hot_potato);
    }

    #[test(caller = @module_a, not_receiver = @0xfaa)]
    #[expected_failure(abort_code=ENOT_AUTHORIZED)]
    fun test_receive_message_not_receiver(caller: &signer, not_receiver: &signer) {
        let hot_potato = receive_message();
        let stamped_hot_potato = stamp(not_receiver, hot_potato);
        complete_receive_message(caller, stamped_hot_potato);
    }

}
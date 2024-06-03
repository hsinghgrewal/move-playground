module module_b::module_b {

    use module_a::module_a::{Self, HotPotato};

    public fun handle_receive(caller: &signer, hot_potato: HotPotato): HotPotato {
        module_a::stamp(caller, hot_potato)
    }

    #[test(caller = @module_b)]
    fun test_handle_receive_success(caller: &signer) {
        let hot_potato = module_a::receive_message();
        let stamped_hot_potato = handle_receive(caller, hot_potato);
        module_a::complete_receive_message(caller, stamped_hot_potato);
    }

}
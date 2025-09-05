/// Comprehensive tests for DAO functionality
/// 
/// Test coverage:
/// - Basic DAO creation and funding
/// - Proposal creation and management
/// - Voting mechanisms and validation
/// - Proposal execution
/// - Edge cases and error conditions
#[test_only]
module dao_financing::dao_tests {
    use dao_financing::dao::{Self, DAO, Proposal, GovernanceToken};
    use sui::test_scenario::{Self, Scenario};
    use sui::coin;
    use sui::sui::SUI;
    use std::string;

    // === TEST CONSTANTS ===
    const ADMIN: address = @0xA11CE;
    const USER1: address = @0xB0B;
    const USER2: address = @0xCAFE;
    const USER3: address = @0xFACE;

    // === HELPER FUNCTIONS ===

    /// Create a test scenario with an admin
    fun setup_test(): Scenario {
        test_scenario::begin(ADMIN)
    }

    /// Create a funded DAO for testing
    fun create_funded_dao(scenario: &mut Scenario): object::ID {
        // Create DAO
        dao::create_dao(
            string::utf8(b"Test DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        
        // Get the DAO
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let dao_id = object::id(&dao);
        
        // Fund the DAO with 10 SUI
        let payment = coin::mint_for_testing<SUI>(10_000_000_000, test_scenario::ctx(scenario));
        dao::fund_dao(&mut dao, payment);
        
        test_scenario::return_shared(dao);
        dao_id
    }

    /// Create a governance token for a user
    fun create_token_for_user(scenario: &mut Scenario, _dao_id: object::ID, user: address, power: u64) {
        test_scenario::next_tx(scenario, ADMIN);
        let dao = test_scenario::take_shared<DAO>(scenario);
        
        dao::mint_governance_token(&dao, user, power, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(dao);
    }

    // === BASIC FUNCTIONALITY TESTS ===

    #[test]
    fun test_create_dao_success() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create DAO
        dao::create_dao(
            string::utf8(b"My Test DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        
        // Verify DAO was created and shared
        assert!(test_scenario::has_most_recent_shared<DAO>(), 0);
        
        let dao = test_scenario::take_shared<DAO>(scenario);
        let (name, treasury_balance, proposal_count, active) = dao::get_dao_info(&dao);
        
        // Verify DAO properties
        assert!(name == string::utf8(b"My Test DAO"), 1);
        assert!(treasury_balance == 0, 2);
        assert!(proposal_count == 0, 3);
        assert!(active == true, 4);
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_fund_dao() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create DAO
        dao::create_dao(
            string::utf8(b"Funding Test DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        
        // Create payment and fund DAO
        let payment = coin::mint_for_testing<SUI>(5_000_000_000, test_scenario::ctx(scenario)); // 5 SUI
        dao::fund_dao(&mut dao, payment);
        
        // Verify treasury balance
        let (_, treasury_balance, _, _) = dao::get_dao_info(&dao);
        assert!(treasury_balance == 5_000_000_000, 0);
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_governance_token() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        
        // Mint token for USER1
        create_token_for_user(scenario, dao_id, USER1, 500);
        
        test_scenario::next_tx(scenario, USER1);
        
        // Verify token was created and transferred
        assert!(test_scenario::has_most_recent_for_sender<GovernanceToken>(scenario), 0);
        
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let (token_dao_id, voting_power) = dao::get_token_info(&token);
        
        assert!(token_dao_id == dao_id, 1);
        assert!(voting_power == 500, 2);
        
        test_scenario::return_to_sender(scenario, token);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_proposal() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let _dao_id = create_funded_dao(scenario);
        
        test_scenario::next_tx(scenario, USER1);
        
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        
        // Create proposal
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Build Website"),
            string::utf8(b"Create a website for our community"),
            2_000_000_000, // 2 SUI
            test_scenario::ctx(scenario)
        );
        
        let (_, _, proposal_count, _) = dao::get_dao_info(&dao);
        assert!(proposal_count == 1, 0);
        
        test_scenario::return_shared(dao);
        test_scenario::next_tx(scenario, USER1);
        
        // Verify proposal was created and shared
        assert!(test_scenario::has_most_recent_shared<Proposal>(), 1);
        
        let proposal = test_scenario::take_shared<Proposal>(scenario);
        let (title, amount, proposer, executed, status) = dao::get_proposal_info(&proposal);
        
        assert!(title == string::utf8(b"Build Website"), 2);
        assert!(amount == 2_000_000_000, 3);
        assert!(proposer == USER1, 4);
        assert!(executed == false, 5);
        assert!(status == 0, 6); // PROPOSAL_ACTIVE
        
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    // === VOTING TESTS ===

    #[test]
    fun test_cast_vote_success() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 500);
        
        // Create proposal
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Test Proposal"),
            string::utf8(b"Description"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        test_scenario::next_tx(scenario, USER1);
        
        // Get token and proposal
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        // Cast vote
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        
        // Verify vote was recorded
        assert!(dao::has_voted(&proposal, USER1), 0);
        
        let (votes_for, votes_against) = dao::get_proposal_votes(&proposal);
        assert!(votes_for == 500, 1);
        assert!(votes_against == 0, 2);
        
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_multiple_votes() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 500);
        create_token_for_user(scenario, dao_id, USER2, 300);
        create_token_for_user(scenario, dao_id, USER3, 200);
        
        // Create proposal
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Multi Vote Test"),
            string::utf8(b"Testing multiple votes"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        // USER1 votes YES
        test_scenario::next_tx(scenario, USER1);
        let token1 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token1, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token1);
        test_scenario::return_shared(proposal);
        
        // USER2 votes NO
        test_scenario::next_tx(scenario, USER2);
        let token2 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token2, false, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token2);
        test_scenario::return_shared(proposal);
        
        // USER3 votes YES
        test_scenario::next_tx(scenario, USER3);
        let token3 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token3, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token3);
        
        // Verify final vote counts
        let (votes_for, votes_against) = dao::get_proposal_votes(&proposal);
        assert!(votes_for == 700, 0); // 500 + 200
        assert!(votes_against == 300, 1);
        assert!(dao::can_execute(&proposal), 2);
        
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_execute_proposal_success() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 1000);
        
        // Create proposal
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Execution Test"),
            string::utf8(b"Test proposal execution"),
            3_000_000_000, // 3 SUI
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        // Vote in favor
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        
        // Execute proposal
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        dao::execute_proposal(&mut dao, &mut proposal, test_scenario::ctx(scenario));
        
        // Verify execution
        let (_, _, _, executed, status) = dao::get_proposal_info(&proposal);
        assert!(executed == true, 0);
        assert!(status == 3, 1); // PROPOSAL_EXECUTED
        
        // Verify treasury was reduced
        let (_, treasury_balance, _, _) = dao::get_dao_info(&dao);
        assert!(treasury_balance == 7_000_000_000, 2); // 10 - 3 = 7 SUI
        
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    // === ERROR CONDITION TESTS ===

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_ALREADY_VOTED)]
    fun test_double_vote_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 500);
        
        // Create proposal
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Double Vote Test"),
            string::utf8(b"Testing double vote prevention"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        // First vote - should succeed
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        
        // Second vote - should fail with E_ALREADY_VOTED
        dao::cast_vote(&mut proposal, &token, false, test_scenario::ctx(scenario));
        
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_WRONG_DAO_TOKEN)]
    fun test_wrong_dao_token_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create first DAO and get its ID
        dao::create_dao(
            string::utf8(b"First DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao1 = test_scenario::take_shared<DAO>(scenario);
        let dao1_id = object::id(&dao1);
        
        // Fund the first DAO
        let payment1 = coin::mint_for_testing<SUI>(10_000_000_000, test_scenario::ctx(scenario));
        dao::fund_dao(&mut dao1, payment1);
        
        // Create token for first DAO
        dao::mint_governance_token(&dao1, USER1, 500, test_scenario::ctx(scenario));
        test_scenario::return_shared(dao1);
        
        // Create second DAO
        test_scenario::next_tx(scenario, ADMIN);
        dao::create_dao(
            string::utf8(b"Second DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao2 = test_scenario::take_shared<DAO>(scenario);
        let dao2_id = object::id(&dao2);
        
        // Make sure we have two different DAOs
        assert!(dao1_id != dao2_id, 999);
        
        // Fund the second DAO
        let payment2 = coin::mint_for_testing<SUI>(10_000_000_000, test_scenario::ctx(scenario));
        dao::fund_dao(&mut dao2, payment2);
        test_scenario::return_shared(dao2);
        
        // Create proposal in second DAO
        test_scenario::next_tx(scenario, USER2);
        let mut dao2 = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao2,
            string::utf8(b"Wrong DAO Test"),
            string::utf8(b"Testing wrong DAO token"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao2);
        
        // Try to vote on DAO2 proposal with DAO1 token - should fail
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        // This should fail with E_WRONG_DAO_TOKEN
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_INSUFFICIENT_FUNDS)]
    fun test_insufficient_funds_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create DAO with only 1 SUI
        dao::create_dao(
            string::utf8(b"Poor DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let dao_id = object::id(&dao);
        
        // Fund with only 1 SUI
        let payment = coin::mint_for_testing<SUI>(1_000_000_000, test_scenario::ctx(scenario));
        dao::fund_dao(&mut dao, payment);
        test_scenario::return_shared(dao);
        
        create_token_for_user(scenario, dao_id, USER1, 500);
        
        // Create proposal asking for 5 SUI (more than available)
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Expensive Proposal"),
            string::utf8(b"Asking for too much money"),
            5_000_000_000, // 5 SUI
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        // Vote in favor
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        
        // Try to execute - should fail with E_INSUFFICIENT_FUNDS
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        dao::execute_proposal(&mut dao, &mut proposal, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_PROPOSAL_REJECTED)]
    fun test_rejected_proposal_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 300);
        create_token_for_user(scenario, dao_id, USER2, 700);
        
        // Create proposal
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Rejected Proposal"),
            string::utf8(b"This will be rejected"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        // USER1 votes YES (300 power)
        test_scenario::next_tx(scenario, USER1);
        let token1 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token1, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token1);
        test_scenario::return_shared(proposal);
        
        // USER2 votes NO (700 power) - this should make proposal lose
        test_scenario::next_tx(scenario, USER2);
        let token2 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token2, false, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token2);
        test_scenario::return_shared(proposal);
        
        // Try to execute rejected proposal - should fail
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        dao::execute_proposal(&mut dao, &mut proposal, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_ALREADY_EXECUTED)]
    fun test_double_execution_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 1000);
        
        // Create and vote on proposal
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Double Execution Test"),
            string::utf8(b"Testing double execution prevention"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        
        // First execution - should succeed
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::execute_proposal(&mut dao, &mut proposal, test_scenario::ctx(scenario));
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
        
        // Second execution - should fail with E_ALREADY_EXECUTED
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        
        dao::execute_proposal(&mut dao, &mut proposal, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_INVALID_AMOUNT)]
    fun test_zero_amount_proposal_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let _dao_id = create_funded_dao(scenario);
        
        test_scenario::next_tx(scenario, USER1);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        
        // Try to create proposal with 0 amount - should fail
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Zero Amount"),
            string::utf8(b"Proposal with zero amount"),
            0, // This should cause failure
            test_scenario::ctx(scenario)
        );
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_ZERO_VOTING_POWER)]
    fun test_zero_voting_power_fails() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let _dao_id = create_funded_dao(scenario);
        
        test_scenario::next_tx(scenario, ADMIN);
        let dao = test_scenario::take_shared<DAO>(scenario);
        
        // Try to mint token with zero voting power - should fail
        dao::mint_governance_token(&dao, USER1, 0, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    // === QUERY FUNCTION TESTS ===

    #[test]
    fun test_query_functions() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 500);
        
        // Create and vote on proposal
        test_scenario::next_tx(scenario, USER2);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Query Test"),
            string::utf8(b"Testing query functions"),
            2_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        test_scenario::next_tx(scenario, USER1);
        let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token, true, test_scenario::ctx(scenario));
        
        // Test query functions
        assert!(dao::has_voted(&proposal, USER1), 0);
        assert!(!dao::has_voted(&proposal, USER2), 1);
        assert!(dao::can_execute(&proposal), 2);
        
        let (votes_for, votes_against) = dao::get_proposal_votes(&proposal);
        assert!(votes_for == 500, 3);
        assert!(votes_against == 0, 4);
        
        let _vote_ref = dao::get_vote(&proposal, USER1);
        // Vote reference should exist and be accessible
        
        test_scenario::return_to_sender(scenario, token);
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    // === EDGE CASE TESTS ===

    #[test]
    fun test_tie_vote_rejected() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        let dao_id = create_funded_dao(scenario);
        create_token_for_user(scenario, dao_id, USER1, 500);
        create_token_for_user(scenario, dao_id, USER2, 500);
        
        // Create proposal
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Tie Vote Test"),
            string::utf8(b"Testing tie vote scenario"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(dao);
        
        // USER1 votes YES, USER2 votes NO (equal power)
        test_scenario::next_tx(scenario, USER1);
        let token1 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token1, true, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token1);
        test_scenario::return_shared(proposal);
        
        test_scenario::next_tx(scenario, USER2);
        let token2 = test_scenario::take_from_sender<GovernanceToken>(scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(scenario);
        dao::cast_vote(&mut proposal, &token2, false, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, token2);
        
        // Tie vote should not be executable (needs votes_for > votes_against)
        assert!(!dao::can_execute(&proposal), 0);
        
        let (votes_for, votes_against) = dao::get_proposal_votes(&proposal);
        assert!(votes_for == 500, 1);
        assert!(votes_against == 500, 2);
        
        test_scenario::return_shared(proposal);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_dao_pause_functionality() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create DAO
        dao::create_dao(
            string::utf8(b"Pausable DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        
        // Pause DAO
        dao::set_dao_active(&mut dao, false);
        
        let (_, _, _, active) = dao::get_dao_info(&dao);
        assert!(active == false, 0);
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = dao_financing::dao::E_DAO_NOT_ACTIVE)]
    fun test_paused_dao_rejects_proposals() {
        let mut scenario_val = setup_test();
        let scenario = &mut scenario_val;
        
        // Create and pause DAO
        dao::create_dao(
            string::utf8(b"Paused DAO"),
            100,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::next_tx(scenario, ADMIN);
        let mut dao = test_scenario::take_shared<DAO>(scenario);
        dao::set_dao_active(&mut dao, false);
        
        // Try to create proposal on paused DAO - should fail
        dao::create_proposal(
            &mut dao,
            string::utf8(b"Should Fail"),
            string::utf8(b"This should not work"),
            1_000_000_000,
            test_scenario::ctx(scenario)
        );
        
        test_scenario::return_shared(dao);
        test_scenario::end(scenario_val);
    }

    // === TESTS FOR NEW v3 FUNCTIONS ===

    #[test]
    fun test_get_dao_stats() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Create DAO
        {
            let ctx = test_scenario::ctx(&mut scenario);
            dao::create_dao(string::utf8(b"Test DAO"), 100, ctx);
        };
        test_scenario::next_tx(&mut scenario, ADMIN);

        // Get the DAO and test initial stats
        {
            let mut dao = test_scenario::take_shared<DAO>(&scenario);
            let (treasury, proposals, active, min_voting) = dao::get_dao_stats(&dao);
            assert!(treasury == 0, 0);
            assert!(proposals == 0, 1);
            assert!(active == true, 2);
            assert!(min_voting == 100, 3);

            // Add some treasury
            let ctx = test_scenario::ctx(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(1000, ctx);
            dao::fund_dao(&mut dao, payment);

            // Create a proposal to increment count
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Test Proposal"),
                string::utf8(b"Test Description"),
                500,
                ctx
            );

            // Test updated stats
            let (treasury2, proposals2, active2, min_voting2) = dao::get_dao_stats(&dao);
            assert!(treasury2 == 1000, 4);
            assert!(proposals2 == 1, 5);
            assert!(active2 == true, 6);
            assert!(min_voting2 == 100, 7);

            test_scenario::return_shared(dao);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_treasury_balance() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Create DAO
        {
            let ctx = test_scenario::ctx(&mut scenario);
            dao::create_dao(string::utf8(b"Test DAO"), 100, ctx);
        };
        test_scenario::next_tx(&mut scenario, ADMIN);

        {
            let mut dao = test_scenario::take_shared<DAO>(&scenario);
            
            // Test initial balance
            assert!(dao::get_treasury_balance(&dao) == 0, 0);

            // Add funds
            let ctx = test_scenario::ctx(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(2500, ctx);
            dao::fund_dao(&mut dao, payment);

            // Test updated balance
            assert!(dao::get_treasury_balance(&dao) == 2500, 1);

            test_scenario::return_shared(dao);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_has_sufficient_funds() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Create DAO
        {
            let ctx = test_scenario::ctx(&mut scenario);
            dao::create_dao(string::utf8(b"Test DAO"), 100, ctx);
        };
        test_scenario::next_tx(&mut scenario, ADMIN);

        {
            let mut dao = test_scenario::take_shared<DAO>(&scenario);
            
            // Test with empty treasury
            assert!(dao::has_sufficient_funds(&dao, 100) == false, 0);
            assert!(dao::has_sufficient_funds(&dao, 0) == true, 1);

            // Add funds
            let ctx = test_scenario::ctx(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(1000, ctx);
            dao::fund_dao(&mut dao, payment);

            // Test with funded treasury
            assert!(dao::has_sufficient_funds(&dao, 500) == true, 2);
            assert!(dao::has_sufficient_funds(&dao, 1000) == true, 3);
            assert!(dao::has_sufficient_funds(&dao, 1001) == false, 4);
            assert!(dao::has_sufficient_funds(&dao, 2000) == false, 5);

            test_scenario::return_shared(dao);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_new_functions_integration() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Create DAO
        {
            let ctx = test_scenario::ctx(&mut scenario);
            dao::create_dao(string::utf8(b"Integration Test DAO"), 500, ctx);
        };
        test_scenario::next_tx(&mut scenario, ADMIN);

        {
            let mut dao = test_scenario::take_shared<DAO>(&scenario);
            
            // Test initial state with all new functions
            let (treasury, proposals, active, min_voting) = dao::get_dao_stats(&dao);
            assert!(treasury == dao::get_treasury_balance(&dao), 0);
            assert!(dao::has_sufficient_funds(&dao, treasury), 1);
            assert!(proposals == 0, 2);
            assert!(active == true, 3);
            assert!(min_voting == 500, 4);

            // Fund DAO and create proposal
            let ctx = test_scenario::ctx(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(10000, ctx);
            dao::fund_dao(&mut dao, payment);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Integration Proposal"),
                string::utf8(b"Testing all new functions together"),
                5000,
                ctx
            );

            // Test final state
            let (treasury_final, proposals_final, _, _) = dao::get_dao_stats(&dao);
            assert!(treasury_final == 10000, 5);
            assert!(treasury_final == dao::get_treasury_balance(&dao), 6);
            assert!(proposals_final == 1, 7);
            assert!(dao::has_sufficient_funds(&dao, 5000), 8);
            assert!(dao::has_sufficient_funds(&dao, 15000) == false, 9);

            test_scenario::return_shared(dao);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_treasury_operations_comprehensive() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Create DAO
        {
            let ctx = test_scenario::ctx(&mut scenario);
            dao::create_dao(string::utf8(b"Treasury Test DAO"), 1000, ctx);
        };
        test_scenario::next_tx(&mut scenario, ADMIN);

        {
            let mut dao = test_scenario::take_shared<DAO>(&scenario);
            
            // Test multiple funding operations
            let ctx = test_scenario::ctx(&mut scenario);
            let payment1 = coin::mint_for_testing<SUI>(1000, ctx);
            dao::fund_dao(&mut dao, payment1);
            assert!(dao::get_treasury_balance(&dao) == 1000, 0);
            assert!(dao::has_sufficient_funds(&dao, 1000), 1);

            let payment2 = coin::mint_for_testing<SUI>(500, ctx);
            dao::fund_dao(&mut dao, payment2);
            assert!(dao::get_treasury_balance(&dao) == 1500, 2);
            assert!(dao::has_sufficient_funds(&dao, 1500), 3);

            // Test edge cases
            assert!(dao::has_sufficient_funds(&dao, 1501) == false, 4);
            assert!(dao::has_sufficient_funds(&dao, 0), 5);

            // Verify stats consistency
            let (treasury, _, _, _) = dao::get_dao_stats(&dao);
            assert!(treasury == dao::get_treasury_balance(&dao), 6);
            assert!(treasury == 1500, 7);

            test_scenario::return_shared(dao);
        };
        test_scenario::end(scenario);
    }
}

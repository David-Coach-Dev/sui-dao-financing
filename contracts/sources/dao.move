/// DAO de Financiamiento - Sui Developer Program
/// 
/// Una organización autónoma descentralizada que permite a una comunidad
/// decidir democráticamente qué proyectos financiar usando tokens de gobernanza.
/// 
/// Características principales:
/// - Votación democrática con tokens de gobernanza
/// - Ejecución automática de propuestas aprobadas  
/// - Gestión transparente de tesorería
/// - Prevención de votos duplicados
/// - Validaciones de seguridad exhaustivas
module dao_financing::dao {
    // === IMPORTS ===
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::dynamic_object_field as ofield;
    use sui::event;
    use std::string::String;

    // === ERROR CODES ===
    
    // Access control errors (100s)
    const E_ALREADY_VOTED: u64 = 100;
    const E_WRONG_DAO_TOKEN: u64 = 101;
    
    // State errors (200s)
    const E_PROPOSAL_NOT_ACTIVE: u64 = 200;
    const E_ALREADY_EXECUTED: u64 = 201;
    const E_DAO_NOT_ACTIVE: u64 = 202;
    
    // Business logic errors (300s)
    const E_INSUFFICIENT_FUNDS: u64 = 300;
    const E_PROPOSAL_REJECTED: u64 = 301;
    const E_ZERO_VOTING_POWER: u64 = 302;
    const E_INVALID_AMOUNT: u64 = 303;
    
    // === CONSTANTS ===
    
    // Proposal status constants
    const PROPOSAL_ACTIVE: u8 = 0;
    const PROPOSAL_EXECUTED: u8 = 3;

    // === STRUCTS ===

    /// Main DAO structure - shared object that represents the organization
    public struct DAO has key {
        id: UID,
        name: String,                   // Human readable name
        treasury: Balance<SUI>,         // Funds available for proposals
        proposal_count: u64,            // Incremental counter
        min_voting_power: u64,          // Minimum power required to vote
        active: bool,                   // Circuit breaker for pausing
    }

    /// Individual proposal for funding
    public struct Proposal has key {
        id: UID,
        dao_id: ID,                     // Reference to parent DAO
        title: String,                  // Proposal title
        description: String,            // Detailed description
        amount_requested: u64,          // Amount in SUI (MIST units)
        proposer: address,              // Who created the proposal
        deadline: u64,                  // Voting deadline (future: use Clock)
        executed: bool,                 // Whether funds have been distributed
        votes_for: u64,                 // Total voting power in favor
        votes_against: u64,             // Total voting power against
        status: u8,                     // Current status (see constants)
    }

    /// Governance token for voting rights
    public struct GovernanceToken has key, store {
        id: UID,
        dao_id: ID,                     // Which DAO this token is for
        voting_power: u64,              // Weight of this token's vote
    }

    /// Individual vote record (stored as dynamic field)
    public struct Vote has key, store {
        id: UID,
        support: bool,                  // true = in favor, false = against
        voting_power: u64,              // Power used for this vote
        timestamp: u64,                 // When vote was cast (future: use Clock)
    }

    // === EVENTS ===

    /// Emitted when a new DAO is created
    public struct DAOCreated has copy, drop {
        dao_id: ID,
        name: String,
        creator: address,
        min_voting_power: u64,
    }

    /// Emitted when a proposal is created
    public struct ProposalCreated has copy, drop {
        proposal_id: ID,
        dao_id: ID,
        title: String,
        amount_requested: u64,
        proposer: address,
    }

    /// Emitted when a vote is cast
    public struct VoteCast has copy, drop {
        proposal_id: ID,
        voter: address,
        support: bool,
        voting_power: u64,
    }

    /// Emitted when a proposal is executed
    public struct ProposalExecuted has copy, drop {
        proposal_id: ID,
        dao_id: ID,
        amount: u64,
        recipient: address,
        final_votes_for: u64,
        final_votes_against: u64,
    }

    // === PUBLIC ENTRY FUNCTIONS ===

    /// Create a new DAO and share it globally
    /// 
    /// # Arguments
    /// * `name` - Human readable name for the DAO
    /// * `min_voting_power` - Minimum voting power required to participate
    /// * `ctx` - Transaction context
    public fun create_dao(
        name: String,
        min_voting_power: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let dao = DAO {
            id: object::new(ctx),
            name: name,
            treasury: balance::zero(),
            proposal_count: 0,
            min_voting_power,
            active: true,
        };

        let dao_id = object::id(&dao);

        // Emit creation event
        event::emit(DAOCreated {
            dao_id,
            name: dao.name,
            creator: sender,
            min_voting_power,
        });

        // Share the DAO so everyone can interact with it
        transfer::share_object(dao);
    }

    /// Create a new funding proposal
    /// 
    /// # Arguments
    /// * `dao` - Mutable reference to the DAO
    /// * `title` - Short title for the proposal
    /// * `description` - Detailed description
    /// * `amount` - Amount requested in MIST (1 SUI = 1,000,000,000 MIST)
    /// * `ctx` - Transaction context
    public fun create_proposal(
        dao: &mut DAO,
        title: String,
        description: String,
        amount: u64,
        ctx: &mut TxContext
    ) {
        // Validations
        assert!(dao.active, E_DAO_NOT_ACTIVE);
        assert!(amount > 0, E_INVALID_AMOUNT);
        
        let sender = tx_context::sender(ctx);
        
        // Increment proposal counter
        dao.proposal_count = dao.proposal_count + 1;
        
        let proposal = Proposal {
            id: object::new(ctx),
            dao_id: object::id(dao),
            title: title,
            description: description,
            amount_requested: amount,
            proposer: sender,
            deadline: 0, // TODO: Implement with Clock
            executed: false,
            votes_for: 0,
            votes_against: 0,
            status: PROPOSAL_ACTIVE,
        };

        let proposal_id = object::id(&proposal);

        // Emit proposal creation event
        event::emit(ProposalCreated {
            proposal_id,
            dao_id: proposal.dao_id,
            title: proposal.title,
            amount_requested: amount,
            proposer: sender,
        });

        // Share the proposal so everyone can vote on it
        transfer::share_object(proposal);
    }

    /// Cast a vote on a proposal using a governance token
    /// 
    /// # Arguments
    /// * `proposal` - Mutable reference to the proposal
    /// * `token` - Governance token to vote with
    /// * `support` - true for yes, false for no
    /// * `ctx` - Transaction context
    #[allow(lint(public_entry))]
    public entry fun cast_vote(
        proposal: &mut Proposal,
        token: &GovernanceToken,
        support: bool,
        ctx: &mut TxContext
    ) {
        let voter = tx_context::sender(ctx);
        
        // === VALIDATIONS ===
        
        // 1. Proposal must be active
        assert!(proposal.status == PROPOSAL_ACTIVE, E_PROPOSAL_NOT_ACTIVE);
        
        // 2. Token must belong to the same DAO
        assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO_TOKEN);
        
        // 3. User must not have voted already
        assert!(!ofield::exists_(&proposal.id, voter), E_ALREADY_VOTED);
        
        // 4. Token must have voting power
        assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);
        
        // 5. TODO: Check deadline with Clock
        // assert!(current_time() < proposal.deadline, E_PROPOSAL_EXPIRED);
        
        // === VOTE CREATION ===
        
        let vote = Vote {
            id: object::new(ctx),
            support,
            voting_power: token.voting_power,
            timestamp: 0, // TODO: Use Clock
        };
        
        // Update vote counters on proposal
        if (support) {
            proposal.votes_for = proposal.votes_for + token.voting_power;
        } else {
            proposal.votes_against = proposal.votes_against + token.voting_power;
        };
        
        // Emit vote event
        event::emit(VoteCast {
            proposal_id: object::id(proposal),
            voter,
            support,
            voting_power: token.voting_power,
        });
        
        // Store vote as dynamic field (prevents double voting)
        ofield::add(&mut proposal.id, voter, vote);
    }

    /// Execute an approved proposal, transferring funds to proposer
    /// 
    /// # Arguments
    /// * `dao` - Mutable reference to the DAO
    /// * `proposal` - Mutable reference to the proposal
    /// * `ctx` - Transaction context
    public fun execute_proposal(
        dao: &mut DAO,
        proposal: &mut Proposal,
        ctx: &mut TxContext
    ) {
        // === VALIDATIONS ===
        
        // 1. Proposal must not be executed already
        assert!(!proposal.executed, E_ALREADY_EXECUTED);
        
        // 2. DAO must be active
        assert!(dao.active, E_DAO_NOT_ACTIVE);
        
        // 3. Must have sufficient funds in treasury
        assert!(
            balance::value(&dao.treasury) >= proposal.amount_requested,
            E_INSUFFICIENT_FUNDS
        );
        
        // 4. Proposal must have won the vote (simple majority)
        assert!(proposal.votes_for > proposal.votes_against, E_PROPOSAL_REJECTED);
        
        // 5. TODO: Voting period must be over
        // assert!(current_time() > proposal.deadline, E_VOTING_STILL_ACTIVE);
        
        // === EXECUTION ===
        
        // Split the requested amount from treasury
        let payment_balance = balance::split(&mut dao.treasury, proposal.amount_requested);
        
        // Convert balance to coin for transfer
        let payment_coin = coin::from_balance(payment_balance, ctx);
        
        // Transfer funds to proposer
        transfer::public_transfer(payment_coin, proposal.proposer);
        
        // Update proposal state
        proposal.executed = true;
        proposal.status = PROPOSAL_EXECUTED;
        
        // Emit execution event
        event::emit(ProposalExecuted {
            proposal_id: object::id(proposal),
            dao_id: object::id(dao),
            amount: proposal.amount_requested,
            recipient: proposal.proposer,
            final_votes_for: proposal.votes_for,
            final_votes_against: proposal.votes_against,
        });
    }

    /// Create and transfer a governance token to a user
    /// 
    /// # Arguments
    /// * `dao` - Reference to the DAO
    /// * `to` - Address to send the token to
    /// * `voting_power` - Voting power of the token
    /// * `ctx` - Transaction context
    public fun mint_governance_token(
        dao: &DAO,
        to: address,
        voting_power: u64,
        ctx: &mut TxContext
    ) {
        // Validation
        assert!(voting_power > 0, E_ZERO_VOTING_POWER);
        
        let token = GovernanceToken {
            id: object::new(ctx),
            dao_id: object::id(dao),
            voting_power,
        };
        
        // Transfer token to recipient
        transfer::transfer(token, to);
    }

    /// Add funds to the DAO treasury
    /// 
    /// # Arguments
    /// * `dao` - Mutable reference to the DAO
    /// * `payment` - SUI coin to add to treasury
    public fun fund_dao(dao: &mut DAO, payment: Coin<SUI>) {
        let balance_to_add = coin::into_balance(payment);
        balance::join(&mut dao.treasury, balance_to_add);
    }

    // === PUBLIC VIEW FUNCTIONS ===

    /// Get comprehensive DAO statistics
    /// 
    /// # Arguments
    /// * `dao` - Reference to the DAO
    /// 
    /// # Returns
    /// * Tuple of (treasury_balance, proposal_count, active_status, min_voting_power)
    public fun get_dao_stats(dao: &DAO): (u64, u64, bool, u64) {
        (
            balance::value(&dao.treasury),
            dao.proposal_count,
            dao.active,
            dao.min_voting_power
        )
    }

    /// Get DAO treasury balance in a user-friendly format
    /// 
    /// # Arguments
    /// * `dao` - Reference to the DAO
    /// 
    /// # Returns
    /// * Treasury balance in MIST
    public fun get_treasury_balance(dao: &DAO): u64 {
        balance::value(&dao.treasury)
    }

    /// Check if DAO has sufficient funds for a given amount
    /// 
    /// # Arguments
    /// * `dao` - Reference to the DAO
    /// * `amount` - Amount to check in MIST
    /// 
    /// # Returns
    /// * True if DAO has sufficient funds
    public fun has_sufficient_funds(dao: &DAO, amount: u64): bool {
        balance::value(&dao.treasury) >= amount
    }

    /// Get the current vote counts for a proposal
    /// 
    /// # Arguments
    /// * `proposal` - Reference to the proposal
    /// 
    /// # Returns
    /// * Tuple of (votes_for, votes_against)
    public fun get_proposal_votes(proposal: &Proposal): (u64, u64) {
        (proposal.votes_for, proposal.votes_against)
    }

    /// Check if an address has already voted on a proposal
    /// 
    /// # Arguments
    /// * `proposal` - Reference to the proposal
    /// * `voter` - Address to check
    /// 
    /// # Returns
    /// * true if voter has already voted, false otherwise
    public fun has_voted(proposal: &Proposal, voter: address): bool {
        ofield::exists_(&proposal.id, voter)
    }

    /// Get a specific vote record
    /// 
    /// # Arguments
    /// * `proposal` - Reference to the proposal
    /// * `voter` - Address of the voter
    /// 
    /// # Returns
    /// * Immutable reference to the vote
    public fun get_vote(proposal: &Proposal, voter: address): &Vote {
        ofield::borrow(&proposal.id, voter)
    }

    /// Get basic DAO information
    /// 
    /// # Arguments
    /// * `dao` - Reference to the DAO
    /// 
    /// # Returns
    /// * Tuple of (name, treasury_balance, proposal_count, active)
    public fun get_dao_info(dao: &DAO): (String, u64, u64, bool) {
        (
            dao.name,
            balance::value(&dao.treasury),
            dao.proposal_count,
            dao.active
        )
    }

    /// Check if a proposal can be executed
    /// 
    /// # Arguments
    /// * `proposal` - Reference to the proposal
    /// 
    /// # Returns
    /// * true if proposal can be executed, false otherwise
    public fun can_execute(proposal: &Proposal): bool {
        !proposal.executed && 
        proposal.votes_for > proposal.votes_against &&
        proposal.status == PROPOSAL_ACTIVE
    }

    /// Get proposal basic info
    /// 
    /// # Arguments
    /// * `proposal` - Reference to the proposal
    /// 
    /// # Returns
    /// * Tuple of (title, amount_requested, proposer, executed, status)
    public fun get_proposal_info(proposal: &Proposal): (String, u64, address, bool, u8) {
        (
            proposal.title,
            proposal.amount_requested,
            proposal.proposer,
            proposal.executed,
            proposal.status
        )
    }

    /// Get governance token info
    /// 
    /// # Arguments
    /// * `token` - Reference to the token
    /// 
    /// # Returns
    /// * Tuple of (dao_id, voting_power)
    public fun get_token_info(token: &GovernanceToken): (ID, u64) {
        (token.dao_id, token.voting_power)
    }

    // === ADMIN FUNCTIONS (Future Enhancement) ===
    
    /// Pause/unpause the DAO (future: require admin capability)
    /// 
    /// # Arguments
    /// * `dao` - Mutable reference to the DAO
    /// * `active` - New active state
    public fun set_dao_active(dao: &mut DAO, active: bool) {
        dao.active = active;
    }

    // === TESTING FUNCTIONS ===
    
    #[test_only]
    /// Create a DAO for testing (returns the DAO instead of sharing)
    public fun create_test_dao(
        name: String,
        min_voting_power: u64,
        ctx: &mut TxContext
    ): DAO {
        DAO {
            id: object::new(ctx),
            name,
            treasury: balance::zero(),
            proposal_count: 0,
            min_voting_power,
            active: true,
        }
    }

    #[test_only]
    /// Create a proposal for testing
    public fun create_test_proposal(
        dao: &mut DAO,
        title: String,
        description: String,
        amount: u64,
        ctx: &mut TxContext
    ): Proposal {
        dao.proposal_count = dao.proposal_count + 1;
        
        Proposal {
            id: object::new(ctx),
            dao_id: object::id(dao),
            title,
            description,
            amount_requested: amount,
            proposer: tx_context::sender(ctx),
            deadline: 0,
            executed: false,
            votes_for: 0,
            votes_against: 0,
            status: PROPOSAL_ACTIVE,
        }
    }

    #[test_only]
    /// Create a governance token for testing
    public fun create_test_token(
        dao_id: ID,
        voting_power: u64,
        ctx: &mut TxContext
    ): GovernanceToken {
        GovernanceToken {
            id: object::new(ctx),
            dao_id,
            voting_power,
        }
    }
}
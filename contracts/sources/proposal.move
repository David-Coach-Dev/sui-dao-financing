/// Módulo de Propuestas - Sistema de solicitudes de financiamiento
/// 
/// Este módulo maneja la creación, gestión y estado de las propuestas
/// de financiamiento dentro de la DAO.
module dao_financing::proposal {
    use sui::event;
    use std::string::String;
    use dao_financing::governance::GovernanceToken;

    // === ERROR CODES ===
    const E_PROPOSAL_NOT_ACTIVE: u64 = 200;
    const E_ALREADY_EXECUTED: u64 = 201;
    const E_INVALID_AMOUNT: u64 = 303;

    // === CONSTANTS ===
    const PROPOSAL_ACTIVE: u8 = 0;
    const PROPOSAL_APPROVED: u8 = 1;
    const PROPOSAL_REJECTED: u8 = 2;
    const PROPOSAL_EXECUTED: u8 = 3;

    // === STRUCTS ===

    /// Estructura que representa una propuesta de financiamiento
    public struct Proposal has key, store {
        id: UID,                    // Identificador único
        dao_id: ID,                 // ID de la DAO propietaria
        title: String,              // Título de la propuesta
        amount: u64,                // Cantidad solicitada en MIST
        recipient: address,         // Destinatario de los fondos
        proposer: address,          // Creador de la propuesta
        votes_for: u64,             // Votos a favor (weighted)
        votes_against: u64,         // Votos en contra (weighted)
        executed: bool,             // Flag de ejecución
        status: u8,                 // Estado actual
    }

    // === EVENTS ===

    /// Evento emitido cuando se crea una nueva propuesta
    public struct ProposalCreated has copy, drop {
        proposal_id: ID,
        dao_id: ID,
        title: String,
        amount: u64,
        proposer: address,
    }

    /// Evento emitido cuando se ejecuta una propuesta
    public struct ProposalExecuted has copy, drop {
        proposal_id: ID,
        amount: u64,
        recipient: address,
    }

    // === PUBLIC FUNCTIONS ===

    /// Crear una nueva propuesta de financiamiento
    public fun create_proposal(
        dao_id: ID,
        title: String,
        amount: u64,
        recipient: address,
        token: &GovernanceToken,
        ctx: &mut TxContext
    ): ID {
        // Validar que el token tiene poder de voto
        assert!(dao_financing::governance::get_voting_power(token) > 0, E_INVALID_AMOUNT);
        
        // Validar que el token pertenece a la DAO
        assert!(dao_financing::governance::get_dao_id(token) == dao_id, dao_financing::governance::get_wrong_dao_token_error());

        let proposal = Proposal {
            id: object::new(ctx),
            dao_id,
            title,
            amount,
            recipient,
            proposer: tx_context::sender(ctx),
            votes_for: 0,
            votes_against: 0,
            executed: false,
            status: PROPOSAL_ACTIVE,
        };

        let proposal_id = object::id(&proposal);

        // Emitir evento
        event::emit(ProposalCreated {
            proposal_id,
            dao_id,
            title,
            amount,
            proposer: tx_context::sender(ctx),
        });

        // Hacer la propuesta pública
        transfer::share_object(proposal);
        
        proposal_id
    }

    /// Actualizar votos de una propuesta
    public fun add_vote(
        proposal: &mut Proposal,
        support: bool,
        voting_power: u64
    ) {
        assert!(proposal.status == PROPOSAL_ACTIVE, E_PROPOSAL_NOT_ACTIVE);
        
        if (support) {
            proposal.votes_for = proposal.votes_for + voting_power;
        } else {
            proposal.votes_against = proposal.votes_against + voting_power;
        }
    }

    /// Marcar propuesta como ejecutada
    public fun mark_executed(proposal: &mut Proposal) {
        assert!(!proposal.executed, E_ALREADY_EXECUTED);
        proposal.executed = true;
        proposal.status = PROPOSAL_EXECUTED;

        // Emitir evento de ejecución
        event::emit(ProposalExecuted {
            proposal_id: object::id(proposal),
            amount: proposal.amount,
            recipient: proposal.recipient,
        });
    }

    /// Verificar si una propuesta puede ejecutarse
    public fun can_execute(proposal: &Proposal): bool {
        proposal.status == PROPOSAL_ACTIVE &&
        !proposal.executed &&
        proposal.votes_for > proposal.votes_against
    }

    // === GETTER FUNCTIONS ===

    /// Obtener información básica de la propuesta
    public fun get_proposal_info(proposal: &Proposal): (String, u64, address, bool, u8) {
        (proposal.title, proposal.amount, proposal.proposer, proposal.executed, proposal.status)
    }

    /// Obtener conteo de votos
    public fun get_proposal_votes(proposal: &Proposal): (u64, u64) {
        (proposal.votes_for, proposal.votes_against)
    }

    /// Obtener ID de la DAO propietaria
    public fun get_dao_id(proposal: &Proposal): ID {
        proposal.dao_id
    }

    /// Obtener cantidad solicitada
    public fun get_amount(proposal: &Proposal): u64 {
        proposal.amount
    }

    /// Obtener destinatario
    public fun get_recipient(proposal: &Proposal): address {
        proposal.recipient
    }

    /// Verificar si está ejecutada
    public fun is_executed(proposal: &Proposal): bool {
        proposal.executed
    }

    /// Obtener estado actual
    public fun get_status(proposal: &Proposal): u8 {
        proposal.status
    }

    // === CONSTANTS ACCESSORS ===

    public fun proposal_active(): u8 { PROPOSAL_ACTIVE }
    public fun proposal_approved(): u8 { PROPOSAL_APPROVED }
    public fun proposal_rejected(): u8 { PROPOSAL_REJECTED }
    public fun proposal_executed(): u8 { PROPOSAL_EXECUTED }
}

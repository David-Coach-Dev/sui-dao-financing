/// Módulo de Sistema de Votación - Gestión democrática de decisiones
/// 
/// Este módulo maneja todo el sistema de votación de la DAO,
/// incluyendo la creación de votos y validación de resultados.
module dao_financing::voting {
    use sui::event;
    use dao_financing::governance::{Self, GovernanceToken};

    // === ERROR CODES ===
    const E_VOTING_NOT_STARTED: u64 = 401;
    const E_VOTING_ENDED: u64 = 402;
    const E_INVALID_VOTE_TYPE: u64 = 403;
    const E_ALREADY_VOTED: u64 = 404;

    // === STRUCTS ===

    /// Voto individual emitido por un miembro
    public struct Vote has key, store {
        id: UID,                    // Identificador único
        proposal_id: ID,            // ID de la propuesta
        voter: address,             // Dirección del votante
        vote_type: u8,              // 0 = En contra, 1 = A favor
        voting_power: u64,          // Poder de voto utilizado
        timestamp: u64,             // Marca de tiempo del voto
    }

    /// Registro de votación para una propuesta
    public struct VotingRecord has key, store {
        id: UID,                    // Identificador único
        proposal_id: ID,            // ID de la propuesta
        yes_votes: u64,             // Total votos a favor
        no_votes: u64,              // Total votos en contra
        total_votes: u64,           // Total de votos emitidos
        voters: vector<address>,    // Lista de votantes
    }

    // === EVENTS ===

    /// Evento emitido cuando se crea un voto
    public struct VoteCast has copy, drop {
        vote_id: ID,
        proposal_id: ID,
        voter: address,
        vote_type: u8,
        voting_power: u64,
        timestamp: u64,
    }

    /// Evento emitido cuando se inicializa un registro de votación
    public struct VotingRecordCreated has copy, drop {
        record_id: ID,
        proposal_id: ID,
    }

    // === PUBLIC FUNCTIONS ===

    /// Crear un nuevo registro de votación para una propuesta
    public fun create_voting_record(
        proposal_id: ID,
        ctx: &mut TxContext
    ): ID {
        let record = VotingRecord {
            id: object::new(ctx),
            proposal_id,
            yes_votes: 0,
            no_votes: 0,
            total_votes: 0,
            voters: vector::empty(),
        };

        let record_id = object::id(&record);

        // Emitir evento
        event::emit(VotingRecordCreated {
            record_id,
            proposal_id,
        });

        // Transferir al sistema
        transfer::share_object(record);
        
        record_id
    }

    /// Emitir un voto en una propuesta
    public fun cast_vote(
        record: &mut VotingRecord,
        proposal_id: ID,
        token: &GovernanceToken,
        vote_type: u8,
        voter: address,
        timestamp: u64,
        ctx: &mut TxContext
    ): ID {
        // Validar tipo de voto
        assert!(vote_type <= 1, E_INVALID_VOTE_TYPE);
        
        // Validar que el registro corresponde a la propuesta
        assert!(record.proposal_id == proposal_id, E_INVALID_VOTE_TYPE);

        // Verificar que no ha votado antes
        assert!(!vector::contains(&record.voters, &voter), E_ALREADY_VOTED);

        // Validar el token de gobernanza
        governance::validate_voting_power(token);
        
        let voting_power = governance::get_voting_power(token);

        // Crear el voto
        let vote = Vote {
            id: object::new(ctx),
            proposal_id,
            voter,
            vote_type,
            voting_power,
            timestamp,
        };

        let vote_id = object::id(&vote);

        // Actualizar el registro de votación
        if (vote_type == 1) {
            record.yes_votes = record.yes_votes + voting_power;
        } else {
            record.no_votes = record.no_votes + voting_power;
        };

        record.total_votes = record.total_votes + voting_power;
        vector::push_back(&mut record.voters, voter);

        // Emitir evento
        event::emit(VoteCast {
            vote_id,
            proposal_id,
            voter,
            vote_type,
            voting_power,
            timestamp,
        });

        // Transferir el voto al votante
        transfer::public_transfer(vote, voter);
        
        vote_id
    }

    /// Verificar si una dirección ya ha votado
    public fun has_voted(record: &VotingRecord, voter: address): bool {
        vector::contains(&record.voters, &voter)
    }

    /// Calcular el resultado de la votación
    public fun calculate_result(record: &VotingRecord): (bool, u64, u64, u64) {
        let passed = record.yes_votes > record.no_votes;
        (passed, record.yes_votes, record.no_votes, record.total_votes)
    }

    // === GETTER FUNCTIONS ===

    /// Obtener información del voto
    public fun get_vote_info(vote: &Vote): (ID, address, u8, u64, u64) {
        (vote.proposal_id, vote.voter, vote.vote_type, vote.voting_power, vote.timestamp)
    }

    /// Obtener estadísticas del registro de votación
    public fun get_voting_stats(record: &VotingRecord): (ID, u64, u64, u64, u64) {
        (
            record.proposal_id,
            record.yes_votes,
            record.no_votes,
            record.total_votes,
            vector::length(&record.voters)
        )
    }

    /// Obtener ID de la propuesta del voto
    public fun get_proposal_id(vote: &Vote): ID {
        vote.proposal_id
    }

    /// Obtener votante del voto
    public fun get_voter(vote: &Vote): address {
        vote.voter
    }

    /// Obtener tipo de voto
    public fun get_vote_type(vote: &Vote): u8 {
        vote.vote_type
    }

    /// Obtener poder de voto utilizado
    public fun get_voting_power_used(vote: &Vote): u64 {
        vote.voting_power
    }

    /// Obtener timestamp del voto
    public fun get_vote_timestamp(vote: &Vote): u64 {
        vote.timestamp
    }

    // === ERROR CODE ACCESSORS ===
    
    public fun get_voting_not_started_error(): u64 { E_VOTING_NOT_STARTED }
    public fun get_voting_ended_error(): u64 { E_VOTING_ENDED }
    public fun get_invalid_vote_type_error(): u64 { E_INVALID_VOTE_TYPE }
    public fun get_already_voted_error(): u64 { E_ALREADY_VOTED }
}

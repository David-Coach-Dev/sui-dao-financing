/// Módulo de Tokens de Gobernanza - Sistema de participación democrática
/// 
/// Este módulo maneja los tokens que otorgan derecho a voto en la DAO.
/// Cada token tiene un poder de voto específico y está vinculado a una DAO.
module dao_financing::governance {
    use sui::event;

    // === ERROR CODES ===
    const E_WRONG_DAO_TOKEN: u64 = 101;
    const E_ZERO_VOTING_POWER: u64 = 302;

    // === STRUCTS ===

    /// Token de gobernanza que otorga derecho a voto
    public struct GovernanceToken has key, store {
        id: UID,                    // Identificador único
        dao_id: ID,                 // ID de la DAO a la que pertenece
        voting_power: u64,          // Poder de voto del token
    }

    // === EVENTS ===

    /// Evento emitido cuando se crea un nuevo token de gobernanza
    public struct GovernanceTokenMinted has copy, drop {
        token_id: ID,
        dao_id: ID,
        recipient: address,
        voting_power: u64,
    }

    // === PUBLIC FUNCTIONS ===

    /// Crear un nuevo token de gobernanza
    public fun mint_token(
        dao_id: ID,
        recipient: address,
        voting_power: u64,
        ctx: &mut TxContext
    ): ID {
        // Validar que el poder de voto es válido
        assert!(voting_power > 0, E_ZERO_VOTING_POWER);

        let token = GovernanceToken {
            id: object::new(ctx),
            dao_id,
            voting_power,
        };

        let token_id = object::id(&token);

        // Emitir evento
        event::emit(GovernanceTokenMinted {
            token_id,
            dao_id,
            recipient,
            voting_power,
        });

        // Transferir al destinatario
        transfer::public_transfer(token, recipient);
        
        token_id
    }

    /// Validar que un token pertenece a una DAO específica
    public fun validate_token_for_dao(token: &GovernanceToken, dao_id: ID) {
        assert!(token.dao_id == dao_id, E_WRONG_DAO_TOKEN);
    }

    /// Validar que un token tiene poder de voto
    public fun validate_voting_power(token: &GovernanceToken) {
        assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);
    }

    // === GETTER FUNCTIONS ===

    /// Obtener información del token
    public fun get_token_info(token: &GovernanceToken): (ID, u64) {
        (token.dao_id, token.voting_power)
    }

    /// Obtener ID de la DAO
    public fun get_dao_id(token: &GovernanceToken): ID {
        token.dao_id
    }

    /// Obtener poder de voto
    public fun get_voting_power(token: &GovernanceToken): u64 {
        token.voting_power
    }

    // === ERROR CODE ACCESSORS ===
    
    public fun get_wrong_dao_token_error(): u64 { E_WRONG_DAO_TOKEN }
    public fun get_zero_voting_power_error(): u64 { E_ZERO_VOTING_POWER }
}

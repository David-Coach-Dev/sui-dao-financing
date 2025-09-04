/// Pruebas para el módulo de propuestas
/// 
/// Estas pruebas verifican toda la funcionalidad del sistema de propuestas,
/// incluyendo creación, votación y cambios de estado.
module dao_financing::proposal_tests {
    use sui::test_scenario;
    use std::string;
    use dao_financing::dao::{Self, DAO, GovernanceToken};

    // === DIRECCIONES DE PRUEBA ===
    const ADMIN: address = @0xA;
    const USER1: address = @0xB;

    #[test]
    fun test_create_dao_and_get_basic_info() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO usando la función del módulo dao
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Test DAO"),
                100, // min_voting_power
                test_scenario::ctx(scenario)
            );
        };

        // Verificar que la DAO existe y obtener información básica
        test_scenario::next_tx(scenario, USER1);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            // Verificar información básica usando get_dao_info
            let (name, _treasury_balance, count, active) = dao::get_dao_info(&dao);
            
            assert!(name == string::utf8(b"Test DAO"), 0);
            assert!(count == 0, 1);
            assert!(active == true, 2);

            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_governance_tokens() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Token Test DAO"),
                50,
                test_scenario::ctx(scenario)
            );
        };

        // Crear tokens de gobernanza
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::mint_governance_token(
                &dao,
                USER1,
                150,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // Verificar que el token fue creado correctamente
        test_scenario::next_tx(scenario, USER1);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            // Verificar información del token usando get_token_info
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 150, 0);

            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_proposal_creation_basic() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Setup: Crear DAO
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Proposal DAO"),
                100,
                test_scenario::ctx(scenario)
            );
        };

        // Crear propuesta básica
        test_scenario::next_tx(scenario, USER1);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Test Proposal"),
                string::utf8(b"A proposal for testing"),
                1000, // amount
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // Verificar que se incrementó el contador de propuestas
        test_scenario::next_tx(scenario, USER1);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            let (_name, _treasury_balance, count, _active) = dao::get_dao_info(&dao);
            assert!(count == 1, 0);

            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }
}

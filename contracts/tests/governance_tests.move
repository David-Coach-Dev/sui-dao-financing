/// Tests específicos para el sistema de gobernanza
/// 
/// Estas pruebas se enfocan en validar el sistema de tokens de gobernanza,
/// incluyendo emisión, validación y uso en el contexto de la DAO.
module dao_financing::governance_tests {
    use sui::test_scenario;
    use std::string;
    use dao_financing::dao::{Self, DAO, GovernanceToken};

    // === DIRECCIONES DE PRUEBA ===
    const ADMIN: address = @0xA;
    const USER1: address = @0xB;
    const USER2: address = @0xC;
    const USER3: address = @0xD;

    #[test]
    fun test_basic_token_creation() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // === 1. CREAR DAO ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Governance Test DAO"),
                100, // min_voting_power
                test_scenario::ctx(scenario)
            );
        };

        // === 2. EMITIR TOKEN DE GOBERNANZA ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::mint_governance_token(
                &dao,
                USER1,
                250,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // === 3. VERIFICAR TOKEN CREADO ===
        test_scenario::next_tx(scenario, USER1);
        {
            assert!(test_scenario::has_most_recent_for_sender<GovernanceToken>(scenario), 0);
            
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            
            assert!(voting_power == 250, 1);

            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_multiple_tokens_different_powers() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Multi Power DAO"),
                50,
                test_scenario::ctx(scenario)
            );
        };

        // Emitir tokens con diferentes poderes
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            // USER1: Alto poder de voto
            dao::mint_governance_token(&dao, USER1, 500, test_scenario::ctx(scenario));
            // USER2: Poder medio
            dao::mint_governance_token(&dao, USER2, 200, test_scenario::ctx(scenario));
            // USER3: Poder mínimo
            dao::mint_governance_token(&dao, USER3, 50, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // Verificar USER1 (poder alto)
        test_scenario::next_tx(scenario, USER1);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 500, 0);
            test_scenario::return_to_sender(scenario, token);
        };

        // Verificar USER2 (poder medio)
        test_scenario::next_tx(scenario, USER2);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 200, 1);
            test_scenario::return_to_sender(scenario, token);
        };

        // Verificar USER3 (poder mínimo)
        test_scenario::next_tx(scenario, USER3);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 50, 2);
            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_token_dao_association() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // === CREAR PRIMERA DAO ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"DAO One"),
                100,
                test_scenario::ctx(scenario)
            );
        };

        let dao1_id;
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            dao1_id = object::id(&dao);
            
            dao::mint_governance_token(&dao, USER1, 300, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // === CREAR SEGUNDA DAO ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"DAO Two"),
                100,
                test_scenario::ctx(scenario)
            );
        };

        let dao2_id;
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            dao2_id = object::id(&dao);
            
            dao::mint_governance_token(&dao, USER2, 400, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // Verificar que el token de USER1 pertenece a DAO1
        test_scenario::next_tx(scenario, USER1);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (token_dao_id, voting_power) = dao::get_token_info(&token);
            
            assert!(token_dao_id == dao1_id, 0);
            assert!(voting_power == 300, 1);

            test_scenario::return_to_sender(scenario, token);
        };

        // Verificar que el token de USER2 pertenece a DAO2
        test_scenario::next_tx(scenario, USER2);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (token_dao_id, voting_power) = dao::get_token_info(&token);
            
            assert!(token_dao_id == dao2_id, 2);
            assert!(voting_power == 400, 3);

            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_token_voting_power_validation() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO con poder mínimo alto
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"High Threshold DAO"),
                200, // poder mínimo alto
                test_scenario::ctx(scenario)
            );
        };

        // Emitir tokens con diferentes niveles
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            // USER1: Por encima del mínimo (puede crear propuestas)
            dao::mint_governance_token(&dao, USER1, 250, test_scenario::ctx(scenario));
            // USER2: Justo en el mínimo (puede crear propuestas)
            dao::mint_governance_token(&dao, USER2, 200, test_scenario::ctx(scenario));
            // USER3: Por debajo del mínimo (no puede crear propuestas)
            dao::mint_governance_token(&dao, USER3, 150, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // USER1 con poder suficiente puede crear propuesta
        test_scenario::next_tx(scenario, USER1);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"High Power Proposal"),
                string::utf8(b"Proposal from high power user"),
                1000,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // USER2 en el límite también puede crear propuesta
        test_scenario::next_tx(scenario, USER2);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Minimum Power Proposal"),
                string::utf8(b"Proposal from minimum power user"),
                800,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // Verificar que se crearon 2 propuestas
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            let (_name, _treasury, proposal_count, _active) = dao::get_dao_info(&dao);
            assert!(proposal_count == 2, 0);
            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_token_power_levels() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO con poder mínimo alto
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Power Level DAO"),
                300, // poder mínimo alto
                test_scenario::ctx(scenario)
            );
        };

        // Emitir tokens con diferentes niveles
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            // USER1: Por encima del mínimo
            dao::mint_governance_token(&dao, USER1, 400, test_scenario::ctx(scenario));
            // USER2: Por debajo del mínimo  
            dao::mint_governance_token(&dao, USER2, 250, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // Verificar que los tokens se crearon con los poderes correctos
        test_scenario::next_tx(scenario, USER1);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 400, 0);
            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 250, 1);
            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_governance_token_info_functions() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Setup básico
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Info Test DAO"),
                100,
                test_scenario::ctx(scenario)
            );
        };

        let dao_id;
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            dao_id = object::id(&dao);
            
            dao::mint_governance_token(&dao, USER1, 375, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // Verificar todas las funciones de información del token
        test_scenario::next_tx(scenario, USER1);
        {
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            // Probar get_token_info
            let (token_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(token_dao_id == dao_id, 0);
            assert!(voting_power == 375, 1);

            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }
}

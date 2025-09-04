/// Pruebas de integración para todo el sistema DAO
/// 
/// Estas pruebas verifican que todos los módulos funcionen correctamente
/// en conjunto, simulando flujos de trabajo reales.
module dao_financing::integration_tests {
    use sui::test_scenario;
    use std::string;
    use dao_financing::dao::{Self, DAO, GovernanceToken};

    // === DIRECCIONES DE PRUEBA ===
    const ADMIN: address = @0xA;
    const USER1: address = @0xB;
    const USER2: address = @0xC;
    const USER3: address = @0xD;

    #[test]
    fun test_complete_dao_lifecycle() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // === 1. CREACIÓN DE DAO ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Complete DAO"),
                100, // min_voting_power
                test_scenario::ctx(scenario)
            );
        };

        // === 2. EMISIÓN DE TOKENS DE GOBERNANZA ===
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            // Emitir tokens a diferentes usuarios
            dao::mint_governance_token(&dao, USER1, 300, test_scenario::ctx(scenario));
            dao::mint_governance_token(&dao, USER2, 200, test_scenario::ctx(scenario));
            dao::mint_governance_token(&dao, USER3, 150, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // === 3. CREACIÓN DE PROPUESTA ===
        test_scenario::next_tx(scenario, USER1);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Funding Request"),
                string::utf8(b"Request for project funding"),
                5000, // amount
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // === 4. VERIFICAR CONTEO DE PROPUESTAS ===
        test_scenario::next_tx(scenario, USER1);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            let (_name, _treasury_balance, count, _active) = dao::get_dao_info(&dao);
            assert!(count == 1, 0);

            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_multiple_users_interaction() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Multi-User DAO"),
                50,
                test_scenario::ctx(scenario)
            );
        };

        // Emitir tokens a múltiples usuarios
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::mint_governance_token(&dao, USER1, 100, test_scenario::ctx(scenario));
            dao::mint_governance_token(&dao, USER2, 80, test_scenario::ctx(scenario));
            dao::mint_governance_token(&dao, USER3, 60, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // User1 crea una propuesta
        test_scenario::next_tx(scenario, USER1);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Multi-User Proposal"),
                string::utf8(b"Testing multiple user interactions"),
                2000,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // User2 crea otra propuesta
        test_scenario::next_tx(scenario, USER2);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"Second Proposal"),
                string::utf8(b"Another proposal from USER2"),
                1500,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(dao);
        };

        // Verificar que hay 2 propuestas
        test_scenario::next_tx(scenario, USER3);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            let (_name, _treasury_balance, count, _active) = dao::get_dao_info(&dao);
            assert!(count == 2, 0);

            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_token_verification() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear DAO
        test_scenario::next_tx(scenario, ADMIN);
        {
            dao::create_dao(
                string::utf8(b"Token Test DAO"),
                75,
                test_scenario::ctx(scenario)
            );
        };

        // Emitir tokens con diferentes poderes de voto
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            dao::mint_governance_token(&dao, USER1, 100, test_scenario::ctx(scenario));
            dao::mint_governance_token(&dao, USER2, 200, test_scenario::ctx(scenario));

            test_scenario::return_shared(dao);
        };

        // USER1 intenta crear propuesta (poder de voto suficiente)
        test_scenario::next_tx(scenario, USER1);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            // Verificar poder de voto antes de crear propuesta
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 100, 0);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"USER1 Proposal"),
                string::utf8(b"Proposal from USER1"),
                1000,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(dao);
        };

        // USER2 también crea propuesta (poder de voto mayor)
        test_scenario::next_tx(scenario, USER2);
        {
            let mut dao = test_scenario::take_shared<DAO>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            let (_dao_id, voting_power) = dao::get_token_info(&token);
            assert!(voting_power == 200, 1);
            
            dao::create_proposal(
                &mut dao,
                string::utf8(b"USER2 Proposal"),
                string::utf8(b"Proposal from USER2 with higher voting power"),
                2000,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(dao);
        };

        // Verificar que ambas propuestas fueron creadas
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao = test_scenario::take_shared<DAO>(scenario);
            
            let (_name, _treasury_balance, count, _active) = dao::get_dao_info(&dao);
            assert!(count == 2, 2);

            test_scenario::return_shared(dao);
        };

        test_scenario::end(scenario_val);
    }
}

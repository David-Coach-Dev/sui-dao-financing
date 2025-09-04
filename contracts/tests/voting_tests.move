/// Tests para el módulo de votación
/// 
/// Estas pruebas verifican el sistema de votación independiente,
/// incluyendo creación de registros y emisión de votos.
module dao_financing::voting_tests {
    use sui::test_scenario;
    use dao_financing::voting::{Self, VotingRecord, Vote};
    use dao_financing::governance::{Self, GovernanceToken};

    // === DIRECCIONES DE PRUEBA ===
    const ADMIN: address = @0xA;
    const VOTER1: address = @0xB;
    const VOTER2: address = @0xC;
    const VOTER3: address = @0xD;

    #[test]
    fun test_create_voting_record() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        // Crear un ID de propuesta ficticio
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ctx = test_scenario::ctx(scenario);
            let proposal_id = object::id_from_address(@0x123);
            
            // Crear registro de votación
            let record_id = voting::create_voting_record(proposal_id, ctx);
            
            // Verificar que se retorna un ID válido
            assert!(object::id_to_address(&record_id) != @0x0, 0);
        };

        // Verificar que el registro existe
        test_scenario::next_tx(scenario, ADMIN);
        {
            let record = test_scenario::take_shared<VotingRecord>(scenario);
            
            let (_proposal_id, yes_votes, no_votes, total_votes, voter_count) = 
                voting::get_voting_stats(&record);
            
            // Verificar estado inicial
            assert!(yes_votes == 0, 1);
            assert!(no_votes == 0, 2);
            assert!(total_votes == 0, 3);
            assert!(voter_count == 0, 4);

            test_scenario::return_shared(record);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_voting_workflow() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        let proposal_id = object::id_from_address(@0x456);

        // Crear registro de votación
        test_scenario::next_tx(scenario, ADMIN);
        {
            voting::create_voting_record(proposal_id, test_scenario::ctx(scenario));
        };

        // Crear token de gobernanza para el votante
        test_scenario::next_tx(scenario, ADMIN);
        {
            let dao_id = object::id_from_address(@0x789);
            governance::mint_token(dao_id, VOTER1, 100, test_scenario::ctx(scenario));
        };

        // Emitir voto
        test_scenario::next_tx(scenario, VOTER1);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            voting::cast_vote(
                &mut record,
                proposal_id,
                &token,
                1, // voto a favor
                VOTER1,
                1000, // timestamp
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        // Verificar que el voto fue registrado
        test_scenario::next_tx(scenario, VOTER1);
        {
            let record = test_scenario::take_shared<VotingRecord>(scenario);
            let vote = test_scenario::take_from_sender<Vote>(scenario);
            
            // Verificar registro actualizado
            let (_, yes_votes, no_votes, total_votes, voter_count) = 
                voting::get_voting_stats(&record);
            
            assert!(yes_votes == 100, 0);
            assert!(no_votes == 0, 1);
            assert!(total_votes == 100, 2);
            assert!(voter_count == 1, 3);
            
            // Verificar información del voto
            let (vote_proposal_id, voter, vote_type, voting_power, timestamp) = 
                voting::get_vote_info(&vote);
            
            assert!(vote_proposal_id == proposal_id, 4);
            assert!(voter == VOTER1, 5);
            assert!(vote_type == 1, 6);
            assert!(voting_power == 100, 7);
            assert!(timestamp == 1000, 8);

            test_scenario::return_to_sender(scenario, vote);
            test_scenario::return_shared(record);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_multiple_votes() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        let proposal_id = object::id_from_address(@0x111);
        let dao_id = object::id_from_address(@0x222);

        // Crear registro de votación
        test_scenario::next_tx(scenario, ADMIN);
        {
            voting::create_voting_record(proposal_id, test_scenario::ctx(scenario));
        };

        // Crear tokens para múltiples votantes
        test_scenario::next_tx(scenario, ADMIN);
        {
            governance::mint_token(dao_id, VOTER1, 100, test_scenario::ctx(scenario));
            governance::mint_token(dao_id, VOTER2, 150, test_scenario::ctx(scenario));
            governance::mint_token(dao_id, VOTER3, 75, test_scenario::ctx(scenario));
        };

        // VOTER1 vota a favor
        test_scenario::next_tx(scenario, VOTER1);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            voting::cast_vote(&mut record, proposal_id, &token, 1, VOTER1, 1001, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        // VOTER2 vota en contra
        test_scenario::next_tx(scenario, VOTER2);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            voting::cast_vote(&mut record, proposal_id, &token, 0, VOTER2, 1002, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        // VOTER3 vota a favor
        test_scenario::next_tx(scenario, VOTER3);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            voting::cast_vote(&mut record, proposal_id, &token, 1, VOTER3, 1003, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        // Verificar resultados finales
        test_scenario::next_tx(scenario, ADMIN);
        {
            let record = test_scenario::take_shared<VotingRecord>(scenario);
            
            let (passed, yes_votes, no_votes, total_votes) = voting::calculate_result(&record);
            
            // Votos a favor: 100 + 75 = 175
            // Votos en contra: 150
            // Total: 325
            assert!(yes_votes == 175, 0);
            assert!(no_votes == 150, 1);
            assert!(total_votes == 325, 2);
            assert!(passed == true, 3); // 175 > 150, la propuesta pasa

            // Verificar que todos han votado
            assert!(voting::has_voted(&record, VOTER1), 4);
            assert!(voting::has_voted(&record, VOTER2), 5);
            assert!(voting::has_voted(&record, VOTER3), 6);

            test_scenario::return_shared(record);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = 404, location = dao_financing::voting)]
    fun test_double_vote_fails() {
        let mut scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;

        let proposal_id = object::id_from_address(@0x333);
        let dao_id = object::id_from_address(@0x444);

        // Setup
        test_scenario::next_tx(scenario, ADMIN);
        {
            voting::create_voting_record(proposal_id, test_scenario::ctx(scenario));
            governance::mint_token(dao_id, VOTER1, 100, test_scenario::ctx(scenario));
        };

        // Primer voto (debería funcionar)
        test_scenario::next_tx(scenario, VOTER1);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            voting::cast_vote(&mut record, proposal_id, &token, 1, VOTER1, 1000, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        // Segundo voto (debería fallar)
        test_scenario::next_tx(scenario, VOTER1);
        {
            let mut record = test_scenario::take_shared<VotingRecord>(scenario);
            let token = test_scenario::take_from_sender<GovernanceToken>(scenario);
            
            // Este debería abortar con E_ALREADY_VOTED
            voting::cast_vote(&mut record, proposal_id, &token, 0, VOTER1, 1001, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(record);
        };

        test_scenario::end(scenario_val);
    }
}

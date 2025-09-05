// Temporary script to call vote function
script {
    use 0x14ec0be57af2469670b0872ea2eae821388336769a5338e8847b06c3a4d4d8b3::dao;
    use 0x14ec0be57af2469670b0872ea2eae821388336769a5338e8847b06c3a4d4d8b3::governance::GovernanceToken;

    fun vote_on_proposal(proposal: &mut dao::Proposal, token: &GovernanceToken, ctx: &mut TxContext) {
        dao::cast_vote(proposal, token, true, ctx);
    }
}

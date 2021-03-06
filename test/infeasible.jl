using Test

@testset "Infeasible" begin

    using QPALM
    using Random
    using LinearAlgebra
    using SparseArrays
    

    Random.seed!(0)

    n, m = 10, 20

    @testset "Primal infeasible" for _ in 1:5

        F = randn(n, n-1)
        Q = sparse(F*F' + 1e-3*I)
        q = randn(n)
        A = randn(m, n)
        x = randn(n)
        b = A*x
        A = sparse([A; -A])
        b = [b - ones(m); -(b + ones(m))]

        model = QPALM.Model()
        QPALM.setup!(model, Q=Q, q=q, A=A, bmax=b; Dict{Symbol,Any}(:max_iter=>100)...)
        results = QPALM.solve!(model)

        @test results.info.status == :Primal_infeasible

    end

    q_dual_infeasible = [
        [[zeros(k); 1; zeros(n-k-1)] for k in 0:2];
        [[-ones(k); 1; -ones(n-k-1)] for k in 0:2];
        [[-rand(k); rand(); -rand(n-k-1)] for k in 0:2];
    ]

    @testset "Dual infeasible" for q in q_dual_infeasible

        A = sparse(I, n, n)
        b = zeros(n)

        model = QPALM.Model()
        QPALM.setup!(model, q=q, A=A, bmax=b; Dict{Symbol,Any}(:max_iter=>100)...)
        results = QPALM.solve!(model)

        @test results.info.status == :Dual_infeasible

    end

end

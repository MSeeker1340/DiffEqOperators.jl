using PDEOperators
using Base.Test

L = 100
d_order = 2
approx_order = 2
x = collect(1:1.0:L).^2
A = LinearOperator{Float64}(2,2)
boundary_points = A.boundary_point_count

res = A*x
@test res[boundary_points + 1: L - boundary_points] == 2.0*ones(L - 2*boundary_points);

L = 1000
d_order = 4
approx_order = 10
y = collect(1:1.0:L).^4 - 2*collect(1:1.0:L).^3 + collect(1:1.0:L).^2;

A = LinearOperator{Float64}(d_order,approx_order)
boundary_points = A.boundary_point_count

res = A*y
@test_approx_eq_eps res[boundary_points + 1: L - boundary_points] 24.0*ones(L - 2*boundary_points) 10.0^-1; # Float64 is less stable

A = LinearOperator{BigFloat}(d_order,approx_order)
res = A*y
@test_approx_eq_eps res[boundary_points + 1: L - boundary_points] 24.0*ones(L - 2*boundary_points) 10.0^-approx_order;

y = convert(Array{Rational, 1}, y)
res = A*y
@test_approx_eq_eps res[boundary_points + 1: L - boundary_points] 24.0*ones(L - 2*boundary_points) 10.0^-approx_order;

# tests for full and sparse_full function
d_order = 2
approx_order = 2
A = LinearOperator{Float64}(d_order,approx_order)
using SpecialMatrices
@test full(A, 10) == -Strang(10); # Strang Matrix is defined with the center term +ve
@test full(A, 10) == sparse_full(A, 10);

# testing correctness
L = 1000
d_order = 4
approx_order = 10
y = collect(1:1.0:L).^4 - 2*collect(1:1.0:L).^3 + collect(1:1.0:L).^2;

A = LinearOperator{BigFloat}(d_order,approx_order)
boundary_points = A.boundary_point_count
mat = full(A, L)
smat = full(A, L)

res = A*y
@test_approx_eq_eps res[boundary_points + 1: L - boundary_points] 24.0*ones(L - 2*boundary_points) 10.0^-approx_order;
@time @test_approx_eq_eps A*y mat*y 10.0^-approx_order;
@time @test_approx_eq_eps A*y smat*y 10.0^-approx_order;
@time @test_approx_eq_eps smat*y mat*y 10.0^-approx_order;
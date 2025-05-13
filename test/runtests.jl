using Test, Aqua, LibAwsCommon
import LibAwsCommon: FieldRef, StructRef, Future

mutable struct Job
    name::String
    wage::Float64
end

@testset "LibAwsCommon" begin
    @testset "aqua" begin
        Aqua.test_all(LibAwsCommon, ambiguities=false)
        Aqua.test_ambiguities(LibAwsCommon)
    end
    @testset "basic usage to test the library loads" begin
        allocator = aws_default_allocator()
        LibAwsCommon.init(allocator)
        logpath = joinpath(mktempdir(), "log.txt")
        GC.@preserve logpath begin
            logger = Ref(aws_logger(C_NULL, C_NULL, C_NULL))
            logger_options = Ref(aws_logger_standard_options(AWS_LL_TRACE, Base.unsafe_convert(Ptr{Cchar}, logpath), C_NULL))
            aws_logger_init_standard(logger, allocator, logger_options)
            aws_logger_set(logger)
            aws_logger_clean_up(logger)
            @test isfile(logpath) # might as well check this but we're mainly testing we don't crash
        end
    end
    @testset "FieldRef/StructRef" begin
        job = Job("plumber", 50000.0)
        GC.@preserve job begin
            @test_throws AssertionError FieldRef(job, :name)
            wage_field = FieldRef(job, :wage)
            @test pointer(wage_field) isa Ptr{Float64}
            @test unsafe_load(pointer(wage_field)) == 50000.0
            @test_throws AssertionError StructRef(Ptr{Any}(pointer_from_objref(job)))
            job_ref = StructRef(Ptr{Job}(pointer_from_objref(job)))
            @test job_ref.wage == 50000.0
        end
    end
    @testset "Future" begin
        f = Future{Int}()
        t = Threads.@spawn wait(f)
        @test !istaskdone(t)
        notify(f, 10)
        @test fetch(t) == 10
        @test wait(f) == 10
        f2 = Future{Int}()
        t2 = Threads.@spawn wait(f2)
        @test !istaskdone(t2)
        notify(f2, ArgumentError("Error!"))
        @test_throws TaskFailedException fetch(t2)
        @test_throws ArgumentError wait(f2)
    end
end

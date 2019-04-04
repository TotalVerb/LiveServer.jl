const tmpdir = mktempdir()
const file1 = joinpath(tmpdir, "file1")
const file2 = joinpath(tmpdir, "file2")

@testset "WatchedFile struct          " begin
    wf1 = LS.WatchedFile(file1)
    wf2 = LS.WatchedFile(file2)

    # Basic struct
    @test wf1.path == file1
    @test wf2.path == file2
    @test wf1.mtime == mtime(file1)
    @test wf2.mtime == mtime(file2)

    # Check if changed
    t1 = time()
    write(file1, "hello")
    @test LS.has_changed(wf1)
    @test !LS.has_changed(wf2)

    # Set state as unchanged
    LS.set_unchanged!(wf1)
    @test !LS.has_changed(wf1)
    @test wf1.mtime > t1
end

@testset "SimpleWatcher struct        " begin

    sw  = LS.SimpleWatcher()
    sw1 = LS.SimpleWatcher(identity, sleeptime=0.0)

    # Base constructor check
    @test sw.callback === nothing
    @test sw.task === nothing
    @test sw.sleeptime == 0.1
    @test isempty(sw.filelist)
    @test eltype(sw.filelist) == LS.WatchedFile

    @test sw1.sleeptime == 0.05 # via the clamping
    @test sw1.callback(2) == 2 # identity function
    @test sw1.callback("blah") == "blah"
    @test isempty(sw1.filelist)
    @test sw1.task === nothing
end
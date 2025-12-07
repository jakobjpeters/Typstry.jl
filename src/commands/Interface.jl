
module Interface

import Base: read, run

using ..Commands: TypstCommandError, TypstCommand

read(typst_command::TypstCommand, ::Type{String}) = String(read(typst_command))
function read(typst_command::TypstCommand)
    io_buffer = IOBuffer()
    run_typst(command -> pipeline(command; stdout = io_buffer), typst_command)
    take!(io_buffer)
end

run(typst_command::TypstCommand, args...; wait::Bool = true) = run_typst(typst_command) do command
    run(command, args...; wait)
end

function run_typst(callback, typst_command::TypstCommand)
    process = callback(ignorestatus(Cmd(typst_command)))
    typst_command.ignore_status || success(process) || throw(TypstCommandError(typst_command))
    process
end

end # Interface

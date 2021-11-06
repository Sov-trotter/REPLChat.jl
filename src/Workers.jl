module Workers

# introduces a way to spawn threaded tasks on any but main thread


# WORK_QUEUE is an unbuffered channel
# if we try to put a task on but there's noone's ready, then put!
# will be blocked
# main thread is our putter
const WORK_QUEUE = Channel{Task}(0)

macro async(thunk)
    esc(quote
        tsk = @task $thunk
        tsk.storage = current_task().storage
        put!(Workers.WORK_QUEUE, tsk)
        tsk
    end)
end

# starts an async task on all the available threads
# that will pull tasks form a shared work queue
# each thread has it's own task that is trying to pull
# task off that shared work queue
# it then schedules and wait for it to finish
function init()
    println(Threads.nthreads())
    tids = Threads.nthreads() == 1 ? (1:1) : 2:Threads.nthreads()
    Threads.@threads for tid in 1:Threads.nthreads()
        if tid in tids
            Base.@async begin
                for task in WORK_QUEUE
                    schedule(task)
                    wait(task)
                end
            end
        end
    end
    return
end


# - - - - - - - - - - - - - - -              - - - - - - - - - - - - - - -             
# |                          |              |                           |    
# |    main thread           |----------->  |   tasks in worker threads | 
# |(puts tasks on the queue) |----------->  |   (pull tasks from queue) |    
# |                          |              |                           |                    
# - - - - - - - - - - - - - - -             - - - - - - - - - - - - - - -
end # module 
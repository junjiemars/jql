local na = #ARGV
local cnt = 10
local m = nil
local level = redis.LOG_NOTICE

local table_exists = function(t) 
    if (1 == redis.call('sismember', '_T_N_', t)) then
        return true
    end
    return false
end

local to_int = function(n)
    local i = tonumber(n)
    if i then
        return math.floor(i)
    end
    return nil
end

local find_pk = function(t)
    local pkd = string.format('_T_[%s]_C_PK_', t)
    local cd = redis.call('get', pkd)
    if (nil == cd) then
        return nil
    end
    local d = string.format('_T_[%s]_C_[%s]_', t, cd)
    local v = redis.call('hmget', d, 'PRIMARY_KEY', 'TYPE')
    if (nil == v) then
        return nil
    end
    return {n=cd, pk=v[1], t=v[2]}
end

if (2 > na) then
    m = "should provides enough arguments(>=2)"
    redis.log(level, m)
    return {-1, m}
end

local t = ARGV[1]
if (not table_exists(t)) then
    m = string.format('table: %s does not exist', t)
    redis.log(level, m)
    return {-00942, m}
end

local i = to_int(ARGV[2])
if (not i) then
    m = string.format('invalid cursor [%s]', ARGV[2])
    redis.log(level, m)
    return {-01001, m}
end

local pk = find_pk(t)
if (nil == pk) then
    m = string.format('primary key does not exists in table:%s', t)
    redis.log(level, m)
    return {-02270, m}
end

local pkd = string.format('_T_[%s]:[%s]_', t, pk['n'])
local pks = nil
if ('STRING' == pk['t']) then
    pks = redis.call('zrangebylex', pkd, '-', '+', 'limit', i, cnt)
else
    pks = redis.call('zrange', pkd, i, cnt)
end

local rows = {}
rows[#rows+1] = {i, #pks}
for j=1,#pks  do
    local r = string.format('_T_[%s]:[%s]:<%s>_', t, pk['n'], pks[j])
    rows[#rows+1] = redis.call('hgetall', r)
end
redis.log(level, string.format('retrived [%s %s]', i, #pks))

return rows
